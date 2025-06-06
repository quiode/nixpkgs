{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "zeekscript";
  version = "1.2.8";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-v0PJY0Ahxa4k011AwtWSIAWBXvt3Aybrd382j1SIT6M=";
  };

  postPatch = ''
    sed -i '/name = "zeekscript"/a version = "${version}"' pyproject.toml
  '';

  nativeBuildInputs = with python3.pkgs; [
    setuptools
    wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    tree-sitter
  ];

  pythonImportsCheck = [
    "zeekscript"
  ];

  meta = {
    description = "Zeek script formatter and analyzer";
    homepage = "https://github.com/zeek/zeekscript";
    changelog = "https://github.com/zeek/zeekscript/blob/v${version}/CHANGES";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [
      fab
      tobim
    ];
    # Incompatible with tree-sitter > 0.21.
    broken = true;
  };
}
