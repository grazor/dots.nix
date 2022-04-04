{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let

  toolchain = builtins.toFile "rust-toolchain" "nightly-x86_64-unknown-linux-gnu";

  rust_version = "1.59.0.1";

  xtensa = stdenv.mkDerivation rec {
    name = "rust-xtensa";
    version = rust_version;

    src = fetchurl {
        url = "https://github.com/esp-rs/rust-build/releases/download/v${version}/rust-${version}-x86_64-unknown-linux-gnu.tar.xz";
        sha256 = "1h88da3d46wfzmv2f74rzxz73acps414mx0212lw68c039w801qq";
    };

    buildInputs = [
      openssl
      pkg-config
      zlib.out
      stdenv.cc.cc.lib
    ];

    nativeBuildInputs = [ autoPatchelfHook ];

    postPatch = ''
        patchShebangs install.sh
    '';

    installPhase = ''
        ./install.sh --destdir=$out --prefix=/
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
    ];

    RUSTC_VERSION = lib.readFile toolchain;
    LIBCLANG_PATH= lib.makeLibraryPath [ llvmPackages_latest.libclang.lib ];

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
      export PATH=$PATH:~/.cargo/bin
      export PATH=$PATH:~/.rustup/toolchains/$RUSTC_VERSION-x86_64-unknown-linux-gnu/bin/

      echo rm rust-toolchain
      echo ln -s ${toolchain} rust-toolchain

      rustup toolchain link esp ${xtensa.out}
      rustup toolchain list
      rustc +esp --print target-list | grep xtensa
    '';
}

