{ lib
, fetchFromGitHub

, makeWrapper
, swift
, swiftPackages
, swiftpm
, swiftpm2nix
, tree-sitter

, curl
, git
, mercurial
, muon
, patch
, subversion
}:

let
  generated = swiftpm2nix.helpers ./generated;
in
swift.stdenv.mkDerivation rec {
  pname = "swift-mesonlsp";
  version = "3.1.3";

  src = fetchFromGitHub {
    owner = "JCWasmx86";
    repo = "Swift-MesonLSP";
    rev = "v${version}";
    hash = "sha256-Y3/5Qv8da8s//uP6/3529siVU9ehLfdG/yATnjn16Fg=";
  };

  nativeBuildInputs = [
    makeWrapper
    swift
    swiftpm
  ];

  checkInputs = [
    swiftPackages.XCTest
  ];

  nativeRuntimeInputs = lib.makeBinPath [
    curl
    git
    mercurial
    muon
    patch
    subversion
  ];

  # Expects to find `libIndexStore.so`
  doCheck = false;

  configurePhase = generated.configure + ''
    runHook preConfigure

    swiftpmMakeMutable SwiftTreeSitter
    rm -rf .build/checkouts/SwiftTreeSitter/tree-sitter
    ln -s ${tree-sitter.src} .build/checkouts/SwiftTreeSitter/tree-sitter

    runHook postConfigure
  '';

  installPhase = ''
    runHook preInstall

    install -D -m 0755 $(swiftpmBinPath)/Swift-MesonLSP $out/bin/Swift-MesonLSP
    wrapProgram $out/bin/Swift-MesonLSP --prefix PATH : ${nativeRuntimeInputs}

    runHook postInstall
  '';

  meta = with lib; {
    description = "An unofficial, unendorsed language server for Meson written in Swift";
    homepage = "https://github.com/JCWasmx86/Swift-MesonLSP";
    license = licenses.gpl3Plus;
    inherit (swift.meta) platforms badPlatforms;
    mainProgram = "Swift-MesonLSP";
    maintainers = with maintainers; [ paveloom ];
  };
}
