{
  lib,
  stdenv,
  buildPackages,
  buildGo124Module,
  fetchFromGitHub,
  installShellFiles,
  testers,
  trivy,
}:

buildGo124Module rec {
  pname = "trivy";
  version = "0.62.1";

  src = fetchFromGitHub {
    owner = "aquasecurity";
    repo = "trivy";
    tag = "v${version}";
    hash = "sha256-STu/xkKC2Ci5HbUi+gdz3ZXB+xgpkh6bs/lB/pG2Uig=";
  };

  # Hash mismatch on across Linux and Darwin
  proxyVendor = true;

  vendorHash = "sha256-0/nM0mcTWF4OPIZvHd6fOPfYMMDw5d96acNuw4kM7Tw=";

  subPackages = [ "cmd/trivy" ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/aquasecurity/trivy/pkg/version/app.ver=${version}"
  ];

  nativeBuildInputs = [ installShellFiles ];

  # Tests require network access
  doCheck = false;

  postInstall =
    let
      trivy =
        if stdenv.buildPlatform.canExecute stdenv.hostPlatform then
          placeholder "out"
        else
          buildPackages.trivy;
    in
    ''
      installShellCompletion --cmd trivy \
        --bash <(${trivy}/bin/trivy completion bash) \
        --fish <(${trivy}/bin/trivy completion fish) \
        --zsh <(${trivy}/bin/trivy completion zsh)
    '';

  doInstallCheck = true;

  passthru.tests.version = testers.testVersion {
    package = trivy;
    command = "trivy --version";
    version = "Version: ${version}";
  };

  meta = with lib; {
    description = "Simple and comprehensive vulnerability scanner for containers, suitable for CI";
    homepage = "https://github.com/aquasecurity/trivy";
    changelog = "https://github.com/aquasecurity/trivy/releases/tag/v${version}";
    longDescription = ''
      Trivy is a simple and comprehensive vulnerability scanner for containers
      and other artifacts. A software vulnerability is a glitch, flaw, or
      weakness present in the software or in an Operating System. Trivy detects
      vulnerabilities of OS packages (Alpine, RHEL, CentOS, etc.) and
      application dependencies (Bundler, Composer, npm, yarn, etc.).
    '';
    mainProgram = "trivy";
    license = licenses.asl20;
    maintainers = with maintainers; [
      fab
      jk
    ];
  };
}
