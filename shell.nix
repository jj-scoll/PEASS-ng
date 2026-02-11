{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    python3
    mono
    msbuild
    nuget
    git
  ];

  shellHook = ''
    echo "PEASS-ng development environment"
    echo ""
    echo "Build LinPEAS:"
    echo "  cd linPEAS && python3 -m builder.linpeas_builder --all-no-fat --output /tmp/linpeas.sh"
    echo ""
    echo "Build WinPEAS:"
    echo "  cd winPEAS/winPEASexe && nuget restore winPEAS.sln && msbuild winPEAS.sln"
  '';
}
