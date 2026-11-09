"""Exercise SSH mode changes with a real isolated tmux server and client.

Optionally set TMUX_TEST_CONFIG to an evaluated programs.tmux.extraConfig file.
Only the SSH transport is replaced; no network connections are made.
"""

import fcntl
import os
from pathlib import Path
import pty
import select
import shlex
import shutil
import struct
import subprocess
import tempfile
import termios
import time
import unittest


ROOT = Path(__file__).resolve().parents[1]
OPTIONS = ("prefix", "key-table", "mouse", "status")


class TmuxSshTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.config = os.environ.get("TMUX_TEST_CONFIG")
        if cls.config is None:
            temp = tempfile.TemporaryDirectory(prefix="tmux-ssh-config-")
            cls.addClassCleanup(temp.cleanup)
            cls.config = str(Path(temp.name) / "tmux.conf")
            evaluated = subprocess.check_output(
                ["nix", "eval", "--raw",
                 ".#darwinConfigurations.mac.config.home-manager.users.smporyvaev.programs.tmux.extraConfig"],
                cwd=ROOT, text=True,
            )
            Path(cls.config).write_text(evaluated)

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="tmux-ssh-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.socket = str(self.root / "socket")
        self.ready = self.root / "ready"
        self.release = self.root / "release"
        self.result = self.root / "result"
        self.ssh_source = Path(os.environ.get(
            "TMUX_SSH_SOURCE", ROOT / "modules/home/data/tmux-ssh.zsh"
        ))
        fakebin = self.root / "bin"
        fakebin.mkdir()
        fake = fakebin / "ssh"
        fake.write_text(
            '#!/bin/sh\n: > "$TEST_READY"\n'
            'while [ ! -f "$TEST_RELEASE" ]; do sleep 0.02; done\n'
            'exit "$(cat "$TEST_RELEASE")"\n'
        )
        fake.chmod(0o755)
        self.env = dict(
            os.environ, HOME=str(self.root), ZDOTDIR=str(self.root),
            TMUX="", TERM="xterm-256color",
            PATH=f"{fakebin}:{os.environ['PATH']}",
            TEST_READY=str(self.ready), TEST_RELEASE=str(self.release),
        )
        self.tmux("-f", "/dev/null", "new-session", "-d", "-s", "test",
                  shlex.join([shutil.which("zsh"), "-df"]))
        self.addCleanup(lambda: self.tmux("kill-server", check=False))
        self.tmux("source-file", self.config)
        for name, value in zip(OPTIONS, ("C-b", "root", "on", "on")):
            self.tmux("set-option", "-g", name, value)
        self.master, slave = pty.openpty()
        fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 30, 100, 0, 0))

        def controlling_terminal():
            os.setsid()
            fcntl.ioctl(0, termios.TIOCSCTTY, 0)

        self.client = subprocess.Popen(
            [shutil.which("tmux"), "-S", self.socket, "attach-session", "-t", "test"],
            stdin=slave, stdout=slave, stderr=slave, env=self.env,
            preexec_fn=controlling_terminal,
        )
        os.close(slave)
        self.addCleanup(self.close_client)
        self.wait_for(lambda: bool(self.tmux("list-clients").strip()))

    def close_client(self):
        self.client.kill()
        os.close(self.master)
        self.client.wait(timeout=5)

    def tmux(self, *args, check=True):
        return subprocess.run(
            [shutil.which("tmux"), "-S", self.socket, *args],
            env=self.env, check=check, text=True,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        ).stdout

    def wait_for(self, predicate):
        deadline = time.monotonic() + 5
        while not predicate():
            if time.monotonic() >= deadline:
                self.fail("Timed out; pane contains:\n" + self.tmux("capture-pane", "-p"))
            if select.select([self.master], [], [], 0.02)[0]:
                os.read(self.master, 65536)

    def options(self, inherited=False):
        return {
            name: self.tmux("show-options", "-qAv" if inherited else "-qv",
                            "-t", "test", name).strip()
            for name in OPTIONS
        }

    def start_ssh(self):
        self.original = self.options()
        self.effective_original = self.options(inherited=True)
        invocation = (
            f"source {shlex.quote(str(self.ssh_source))}; "
            f"ssh example; print -r -- $? > {shlex.quote(str(self.result))}"
        )
        self.tmux("send-keys", "-l", invocation)
        self.tmux("send-keys", "Enter")
        self.wait_for(self.ready.exists)
        self.assertEqual(self.options(inherited=True), {
            "prefix": "None", "key-table": "nested", "mouse": "off", "status": "off"
        })

    def finish_ssh(self, exit_code=0):
        self.release.write_text(str(exit_code))
        self.wait_for(lambda: self.result.exists() and self.result.read_text().strip())
        self.assertEqual(self.result.read_text().strip(), str(exit_code))
        self.assertEqual(self.options(), self.original)
        self.assertEqual(self.options(inherited=True), self.effective_original)

    def test_connect_and_disconnect_restore_inherited_options(self):
        self.start_ssh()
        self.finish_ssh()

    def test_disconnect_after_one_manual_toggle_stays_local(self):
        self.start_ssh()
        os.write(self.master, b"\x1d")
        self.wait_for(lambda: self.options(inherited=True) == self.effective_original)
        self.finish_ssh()

    def test_disconnect_after_two_manual_toggles_restores_local(self):
        self.start_ssh()
        os.write(self.master, b"\x1d")
        self.wait_for(lambda: self.options(inherited=True)["key-table"] == "root")
        os.write(self.master, b"\x1d")
        self.wait_for(lambda: self.options(inherited=True)["key-table"] == "nested")
        self.finish_ssh()

    def test_failed_connection_restores_options_and_exit_code(self):
        self.start_ssh()
        self.finish_ssh(255)

    def test_disconnect_restores_custom_session_options(self):
        for name, value in (("prefix", "C-a"), ("mouse", "off"), ("status", "2")):
            self.tmux("set-option", "-t", "test", name, value)
        self.start_ssh()
        os.write(self.master, b"\x1d")
        self.wait_for(lambda: self.options(inherited=True)["key-table"] == "root")
        self.finish_ssh()

    def test_ctrl_c_restores_local_options(self):
        self.start_ssh()
        os.write(self.master, b"\x03")
        self.wait_for(lambda: self.options() == self.original)
        self.assertEqual(self.options(inherited=True), self.effective_original)

    def test_existing_remote_mode_is_preserved(self):
        for name, value in zip(OPTIONS, ("None", "nested", "off", "off")):
            self.tmux("set-option", "-t", "test", name, value)
        self.start_ssh()
        self.finish_ssh()

    def test_piped_ssh_leaves_tmux_untouched(self):
        original = self.options()
        env = dict(self.env, TMUX=f"{self.socket},0,0", TMUX_PANE="%0")
        proc = subprocess.Popen(
            [shutil.which("zsh"), "-dfc",
             f"source {shlex.quote(str(self.ssh_source))}; ssh example"],
            env=env, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        try:
            self.wait_for(self.ready.exists)
            self.assertEqual(self.options(), original)
            self.release.write_text("17")
            proc.communicate(timeout=5)
            self.assertEqual(proc.returncode, 17)
        finally:
            if proc.poll() is None:
                proc.kill()
                proc.communicate(timeout=5)


if __name__ == "__main__":
    unittest.main()
