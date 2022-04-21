{ pkgs ? import <nixpkgs> {} }:

let

  toolchain = builtins.toFile "rust-toolchain" "nightly-x86_64-unknown-linux-gnu";

in

pkgs.mkShell rec {
    buildInputs = with pkgs; [
      llvmPackages_latest.llvm
      llvmPackages_latest.bintools
      zlib.out
      openssl
      rustup
      xorriso
      rust-analyzer
      pkg-config
      grub2
      qemu
      llvmPackages_latest.lld
      python3
    ];
    RUSTC_VERSION = pkgs.lib.readFile toolchain;
    LIBCLANG_PATH= pkgs.lib.makeLibraryPath [ pkgs.llvmPackages_latest.libclang.lib ];

    # Add libvmi precompiled library to rustc search path
    RUSTFLAGS = (builtins.map (a: ''-L ${a}/lib'') [
      pkgs.libvmi
    ]);

    # Add libvmi, glibc, clang, glib headers to bindgen search path
    #
    BINDGEN_EXTRA_CLANG_ARGS = 
    # Includes with normal include path
    (builtins.map (a: ''-I"${a}/include"'') [
      pkgs.libvmi
      pkgs.glibc.dev 
    ])
    # Includes with special directory paths
    ++ [
      ''-I"${pkgs.llvmPackages_latest.libclang.lib}/lib/clang/${pkgs.llvmPackages_latest.libclang.version}/include"''
      ''-I"${pkgs.glib.dev}/include/glib-2.0"''
      ''-I${pkgs.glib.out}/lib/glib-2.0/include/''
    ];

    shellHook = ''
      export PATH=$PATH:~/.cargo/bin
      export PATH=$PATH:~/.rustup/toolchains/$RUSTC_VERSION-x86_64-unknown-linux-gnu/bin/
        cat ${toolchain} > rust-toolchain
    '';
}
