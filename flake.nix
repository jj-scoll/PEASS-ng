{
  description = "PEASS-ng - Privilege Escalation Awesome Scripts Suite";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        packages = {
          # LinPEAS - Download official prebuilt version
          linpeas = pkgs.stdenvNoCC.mkDerivation {
            pname = "linpeas";
            version = "latest";

            src = pkgs.fetchurl {
              url = "https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh";
              sha256 = "sha256-HKwu/f3NEgK+zlNhJVv3EvszfYaDpMgYf4e3KEr7UU0=";
            };

            dontUnpack = true;
            dontBuild = true;

            installPhase = ''
              mkdir -p $out/bin
              cp $src $out/bin/linpeas
              chmod +x $out/bin/linpeas
            '';

            meta = with pkgs.lib; {
              description = "Linux Privilege Escalation Awesome Script";
              homepage = "https://github.com/peass-ng/PEASS-ng";
              license = licenses.gpl3;
              platforms = platforms.unix;
            };
          };

          # WinPEAS using Mono
          winpeas = pkgs.stdenv.mkDerivation {
            pname = "winpeas";
            version = "master";

            src = ./.;

            nativeBuildInputs = with pkgs; [
              mono
              msbuild
              nuget
            ];

            configurePhase = ''
              cd winPEAS/winPEASexe
              # Restore NuGet packages
              nuget restore winPEAS.sln -SolutionDirectory .
            '';

            buildPhase = ''
              # Build with msbuild
              msbuild winPEAS.sln /p:Configuration=Release /p:Platform="Any CPU" /p:TargetFrameworkVersion=v4.8
            '';

            installPhase = ''
              mkdir -p $out/bin

              # Find and copy the actual exe
              find . -name "winPEAS.exe" -type f -exec cp {} $out/bin/ \;
            '';

            meta = with pkgs.lib; {
              description = "Windows Privilege Escalation Awesome Script (compiled with Mono)";
              homepage = "https://github.com/peass-ng/PEASS-ng";
              license = licenses.gpl3;
              platforms = platforms.unix;
            };
          };

          default = self.packages.${system}.linpeas;
        };

        # Development shell with all tools needed
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            (python3.withPackages (ps: with ps; [ pyyaml requests dbus-python ]))
            mono
            msbuild
            nuget
            git
          ];

          shellHook = ''
            echo "PEASS-ng development environment"
            echo ""
            echo "Available commands:"
            echo "  - Build LinPEAS: cd linPEAS && python3 -m builder.linpeas_builder --all-no-fat --output /tmp/linpeas.sh"
            echo "  - Build WinPEAS: cd winPEAS/winPEASexe && nuget restore winPEAS.sln && msbuild winPEAS.sln"
            echo ""
            echo "Or use: nix build .#linpeas or nix build .#winpeas"
          '';
        };

        # Security research and testing shell
        devShells.security = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Core PEASS-ng tools
            (python3.withPackages (ps: with ps; [ pyyaml requests dbus-python ]))

            # System enumeration
            lynis              # Security auditing tool
            chkrootkit         # Rootkit detection

            # Network security
            nmap               # Port scanning
            wireshark          # Network analysis
            tcpdump            # Packet capture
            netcat-gnu         # Network testing

            # D-Bus security testing
            dbus               # D-Bus tools (dbus-send, dbus-monitor)

            # Binary analysis
            binwalk            # Firmware analysis
            file               # File type identification
            hexyl              # Hex viewer
            radare2            # Reverse engineering

            # Privilege escalation testing
            patchelf           # ELF binary modification
            strace             # System call tracing
            ltrace             # Library call tracing

            # Credential hunting
            john               # Password cracking
            hashcat            # Advanced password recovery

            # Container security
            podman             # Container alternative

            # Misc security tools
            gnupg              # GPG encryption
            openssh            # SSH client/tools
            socat              # Network relay
            expect             # Automation
          ];

          shellHook = ''
            echo "════════════════════════════════════════════════════════"
            echo "  PEASS-ng Security Research Environment"
            echo "════════════════════════════════════════════════════════"
            echo ""
            echo "📦 Available Security Tools:"
            echo ""
            echo "System Auditing:"
            echo "  lynis            - Full system security audit"
            echo "  chkrootkit       - Rootkit detection"
            echo ""
            echo "Network Analysis:"
            echo "  nmap             - Port/service scanning"
            echo "  wireshark        - GUI network analyzer"
            echo "  tcpdump          - Packet capture"
            echo "  netcat           - Network Swiss Army knife"
            echo ""
            echo "D-Bus Security:"
            echo "  dbus-send        - Send D-Bus messages"
            echo "  dbus-monitor     - Monitor D-Bus traffic"
            echo "  gdbus            - Modern D-Bus tool"
            echo ""
            echo "Binary Analysis:"
            echo "  radare2          - Reverse engineering framework"
            echo "  binwalk          - Firmware analysis"
            echo "  strace           - System call tracing"
            echo "  ltrace           - Library call tracing"
            echo ""
            echo "Password Tools:"
            echo "  john             - Password cracker"
            echo "  hashcat          - GPU password recovery"
            echo ""
            echo "🚀 Quick Start Commands:"
            echo "  lynis audit system              - Run full security audit"
            echo "  nmap -sV localhost              - Scan local services"
            echo "  dbus-monitor --session          - Monitor session D-Bus"
            echo "  ./result/bin/linpeas            - Run LinPEAS"
            echo ""
            echo "Build PEASS tools with: nix build .#linpeas"
            echo "════════════════════════════════════════════════════════"
          '';
        };

        # Blue team / defensive security shell
        devShells.blueteam = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Monitoring & logging
            sysstat            # System performance (sar, iostat)
            procps             # Process monitoring (ps, top)
            htop               # Interactive process viewer
            iftop              # Network bandwidth monitoring
            nethogs            # Per-process network monitor

            # Security monitoring
            aide               # File integrity monitoring
            fail2ban           # Brute force protection

            # Log analysis
            goaccess           # Web log analyzer
            multitail          # Multi-file tail viewer
            lnav               # Log file navigator

            # Network monitoring
            tcpdump            # Packet capture
            wireshark          # Network protocol analyzer
            tshark             # CLI wireshark
            nmap               # Network discovery

            # Incident response
            sleuthkit          # Forensic analysis
            volatility3        # Memory forensics

            # SIEM / detection
            osquery            # SQL-powered endpoint visibility

            # Hardening verification
            lynis              # Security auditing

            # Automation
            (python3.withPackages (ps: with ps; [
              pyyaml
              requests
              elasticsearch
              scapy            # Packet manipulation
            ]))

            # Misc
            gnupg              # Encryption
            git                # Version control for configs
          ];

          shellHook = ''
            echo "════════════════════════════════════════════════════════"
            echo "  Blue Team / Defensive Security Environment"
            echo "════════════════════════════════════════════════════════"
            echo ""
            echo "🛡️  Monitoring & Detection:"
            echo "  osquery          - Query system state with SQL"
            echo "  htop             - Real-time process monitoring"
            echo "  iftop            - Network bandwidth by connection"
            echo "  nethogs          - Network usage by process"
            echo ""
            echo "🔍 Log Analysis:"
            echo "  lnav             - Advanced log file navigator"
            echo "  multitail        - Monitor multiple log files"
            echo "  goaccess         - Web server log analysis"
            echo ""
            echo "🚨 Intrusion Detection:"
            echo "  aide             - File integrity monitoring"
            echo "  fail2ban         - Automated IP blocking"
            echo ""
            echo "🔬 Forensics & Incident Response:"
            echo "  sleuthkit        - Disk forensics (fls, icat, etc)"
            echo "  volatility3      - Memory analysis"
            echo "  tcpdump          - Packet capture for analysis"
            echo "  wireshark/tshark - Deep packet inspection"
            echo ""
            echo "🔒 Hardening & Auditing:"
            echo "  lynis            - Security configuration audit"
            echo "  nmap             - Port & service enumeration"
            echo ""
            echo "🚀 Quick Start:"
            echo "  sudo lynis audit system          - Full security audit"
            echo "  osqueryi                         - Interactive SQL queries"
            echo "  sudo aide --init                 - Initialize file integrity DB"
            echo "  sudo tcpdump -i any -w capture.pcap  - Capture traffic"
            echo "  lnav /var/log/syslog             - Analyze system logs"
            echo "  htop                             - Monitor processes"
            echo ""
            echo "════════════════════════════════════════════════════════"
          '';
        };

        apps = {
          # Default app - run linpeas
          default = {
            type = "app";
            program = "${self.packages.${system}.linpeas}/bin/linpeas";
          };

          # Run linpeas
          linpeas = {
            type = "app";
            program = "${self.packages.${system}.linpeas}/bin/linpeas";
          };
        };
      }
    );
}
