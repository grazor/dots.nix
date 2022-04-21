{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let

  toolchain = builtins.toFile "rust-toolchain" "nightly-x86_64-unknown-linux-gnu";

  rust_version = "1.59.0";
  rust_version_minor = "1";

  xtensa = stdenv.mkDerivation rec {
    name = "xtensa-rust";
    version = (rust_version + "." + rust_version_minor);

    srcs = [
        (fetchurl {
            url = "https://github.com/esp-rs/rust-build/releases/download/v${version}/rust-${version}-x86_64-unknown-linux-gnu.tar.xz";
            sha256 = "1h88da3d46wfzmv2f74rzxz73acps414mx0212lw68c039w801qq";
        })
        (fetchurl {
            url = "https://github.com/esp-rs/rust-build/releases/download/v${version}/rust-src-${version}.tar.xz";
            sha256 = "0wq3mjllg17z4m7p94zsck4h0la7rzf0m7i7xjn4alf00ixmlr70";
        })
    ];

    sourceRoot = ".";

    buildInputs = [
      openssl
      pkg-config
      zlib.out
      stdenv.cc.cc.lib
    ];

    nativeBuildInputs = [ autoPatchelfHook ];

    postPatch = ''
        patchShebangs rust-${rust_version}-dev-x86_64-unknown-linux-gnu/install.sh
        patchShebangs rust-src-${rust_version}-dev/install.sh
    '';

    installPhase = ''
        rust-${rust_version}-dev-x86_64-unknown-linux-gnu/install.sh --destdir=$out --prefix=/ --without=rust-docs
        rust-src-${rust_version}-dev/install.sh --destdir=$out --prefix=/ --without=rust-docs
    '';
  };

  xtensa_clang = stdenv.mkDerivation rec {
    name = "xtensa-clang";
    version = rust_version;

    src = fetchurl {
        url = "https://github.com/espressif/llvm-project/releases/download/esp-13.0.0-20211203/xtensa-esp32-elf-llvm13_0_0-esp-13.0.0-20211203-linux-amd64.tar.xz";
        sha256 = "17dzisyp3kq3sx5bja2kdpwxag0czc4lsrgjx086n1k50wz8naii";
    };

    buildInputs = [
      python27
      zlib.out
      stdenv.cc.cc.lib
    ];

    nativeBuildInputs = [ autoPatchelfHook ];

    installPhase = ''
        cp -r . $out
    '';
  };

in

mkShell rec {
    buildInputs = [
      llvmPackages_latest.bintools
      llvmPackages_latest.lld
      llvmPackages_latest.llvm
      openssl
      pkg-config
      python3
      qemu
      rust-analyzer
      rustup
      xorriso
      zlib.out

      xtensa
      xtensa_clang
    ];

    RUSTC_VERSION = lib.readFile toolchain;
    LIBCLANG_PATH= lib.makeLibraryPath [ xtensa_clang ];

    # Add libvmi precompiled library to rustc search path
    RUSTFLAGS = (builtins.map (a: ''-L ${a}/lib'') [ libvmi ]);

    # Add libvmi, glibc, clang, glib headers to bindgen search path
    # Includes with normal include path
    # + Includes with special directory paths
    BINDGEN_EXTRA_CLANG_ARGS = (builtins.map (a: ''-I"${a}/include"'') [
      libvmi
      glibc.dev 
    ]) ++ [
      ''-I"${llvmPackages_latest.libclang.lib}/lib/clang/${llvmPackages_latest.libclang.version}/include"''
      ''-I"${glib.dev}/include/glib-2.0"''
      ''-I${glib.out}/lib/glib-2.0/include/''
    ];

    shellHook = ''
      export PATH=${xtensa_clang.out}/bin/:$PATH:~/.cargo/bin
      export PATH=$PATH:~/.rustup/toolchains/$RUSTC_VERSION-x86_64-unknown-linux-gnu/bin/
      export PIP_USER="no"

      # toolchains
      rustup toolchain install stable
      rustup toolchain install nightly

      rustup component add rustfmt --toolchain stable
      rustup component add rustfmt --toolchain nightly

      rustup toolchain uninstall esp
      rustup toolchain link esp ${xtensa.out}
      rustup default esp

      # dependencies
      cargo install ldproxy
    '';
}

