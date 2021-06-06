with import <nixpkgs> { };

stdenv.mkDerivation rec {
  name = "pth";
  env = buildEnv {
    name = name;
    paths = buildInputs;
  };

  buildInputs = [
    #github:DavHau/mach-nix
    python38
    pipenv
    python38Packages.six
    python38Packages.pynvim
    python38Packages.pyspark
    nodejs
    kafkacat
    jupyter
    python38Packages.pandas
    python38Packages.numpy
    python38Packages.psycopg2
    python38Packages.grpcio-tools
    zlib
    openssl
    stdenv.cc.cc.lib
    libffi
    python38Packages.python-snappy
  ];

  # Set Environment Variables
  shellHook = ''
    SOURCE_DATE_EPOCH=$(date +%s) # required for python wheels

    local venv=$(pipenv --bare --venv &>> /dev/null)

    if [[ -z $venv || ! -d $venv ]]; then
      pipenv install --python 3.8 --dev &>> /dev/null
    fi

    export VIRTUAL_ENV=$(pipenv --venv)
    export PIPENV_ACTIVE=1
    export PYTHONPATH="$VIRTUAL_ENV/${python3.sitePackages}:$PYTHONPATH"
    export PATH="$VIRTUAL_ENV/bin:$PATH"

    which poetry || pip install poetry
  '';
}
