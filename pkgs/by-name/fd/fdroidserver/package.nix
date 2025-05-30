{
  lib,
  fetchFromGitLab,
  python3Packages,
  python3,
  fetchPypi,
  apksigner,
  installShellFiles,
}:

python3Packages.buildPythonApplication rec {
  pname = "fdroidserver";
  version = "2.4.0";

  pyproject = true;

  src = fetchFromGitLab {
    owner = "fdroid";
    repo = "fdroidserver";
    tag = version;
    hash = "sha256-PQZz3dyX6vCS0axHfSINMMX5ETdVs44K9XjR87gtd3s=";
  };

  pythonRelaxDeps = [
    "androguard"
    "pyasn1"
    "pyasn1-modules"
  ];

  pythonRemoveDeps = [
    "puremagic" # Only used as a fallback when magic is not installed
  ];

  postPatch = ''
    substituteInPlace fdroidserver/common.py \
      --replace-fail "FDROID_PATH = os.path.realpath(os.path.join(os.path.dirname(__file__), '..'))" "FDROID_PATH = '$out/bin'"
  '';

  preConfigure = ''
    ${python3.pythonOnBuildForHost.interpreter} setup.py compile_catalog
  '';

  postInstall = ''
    patchShebangs gradlew-fdroid
    install -m 0755 gradlew-fdroid $out/bin
    installShellCompletion --cmd fdroid \
      --bash completion/bash-completion
  '';

  nativeBuildInputs = [ installShellFiles ];

  build-system = with python3Packages; [
    setuptools
    babel
  ];

  dependencies = with python3Packages; [
    androguard
    biplist
    clint
    defusedxml
    gitpython
    libcloud
    libvirt
    magic
    mwclient
    oscrypto
    paramiko
    pillow
    platformdirs
    pyasn1
    pyasn1-modules
    pycountry
    python-vagrant
    pyyaml
    qrcode
    requests
    (ruamel-yaml.overrideAttrs (old: {
      src = fetchPypi {
        pname = "ruamel.yaml";
        version = "0.17.21";
        hash = "sha256-i3zml6LyEnUqNcGsQURx3BbEJMlXO+SSa1b/P10jt68=";
      };
    }))
    sdkmanager
    yamllint
  ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${lib.makeBinPath [ apksigner ]}"
  ];

  # no tests
  doCheck = false;

  pythonImportsCheck = [ "fdroidserver" ];

  meta = {
    homepage = "https://gitlab.com/fdroid/fdroidserver";
    changelog = "https://gitlab.com/fdroid/fdroidserver/-/blob/${version}/CHANGELOG.md";
    description = "Server and tools for F-Droid, the Free Software repository system for Android";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [
      linsui
      jugendhacker
    ];
    mainProgram = "fdroid";
  };
}
