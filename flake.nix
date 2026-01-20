{
  description = "Project dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    supportedSystems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # Parse deps.toml
    deps = builtins.fromTOML (builtins.readFile ./deps.toml);

    # =========================================================================
    # Tool Bundles
    # =========================================================================
    # These are pre-defined collections of commonly useful tools.
    # Include them via deps.toml: [bundles] include = ["baseline"]

    # baseline: Modern terminal essentials (28 tools)
    # A curated set of standalone CLI tools (no Python/Perl/Ruby runtimes)
    baselineTools = [
      # Core replacements
      "ripgrep" "fd" "bat" "eza" "sd" "dust" "duf" "bottom" "difftastic"
      # Navigation & search
      "zoxide" "fzf" "broot" "tree"
      # Git
      "delta" "lazygit"
      # Data processing
      "jq" "yq-go" "csvtk" "htmlq" "miller"
      # Shell enhancement
      "atuin" "direnv" "just"
      # Utilities
      "tealdeer" "curlie" "glow" "entr" "pv"
    ];

    # complete: Comprehensive dev environment (58 tools)
    # Everything in baseline plus additional tools for a fully-equipped shell
    completeTools = baselineTools ++ [
      # Additional core replacements
      "procs" "choose"
      # Git & GitHub
      "gh" "git-extras" "tig"
      # Data processing
      "fx"
      # Shell enhancement
      "shellcheck" "starship"
      # File operations
      "rsync" "trash-cli" "watchexec" "renameutils"
      # Networking
      "curl" "wget" "httpie"
      # Archives
      "unzip" "p7zip" "zstd"
      # System utilities
      "tmux" "watch" "less" "file" "lsof" "moreutils"
      # Development utilities
      "hyperfine" "tokei" "navi"
      # Clipboard
      "xclip" "wl-clipboard"
      # Logs
      "lnav"
    ];

    bundles = {
      baseline = baselineTools;
      complete = completeTools;
    };

    # =========================================================================
    # Tool Resolution
    # =========================================================================

    # Map "tool = version" to nixpkgs package
    mapTool = pkgs: name: version: let

      # Explicit version mappings for tools with non-standard naming
      versionMap = {
        python = {
          "3.10" = pkgs.python310;
          "3.11" = pkgs.python311;
          "3.12" = pkgs.python312;
          "3.13" = pkgs.python313;
        };
        nodejs = {
          "18" = pkgs.nodejs_18;
          "20" = pkgs.nodejs_20;
          "22" = pkgs.nodejs_22;
        };
        go = {
          "1.21" = pkgs.go_1_21;
          "1.22" = pkgs.go_1_22;
          "1.23" = pkgs.go_1_23;
        };
        rust = {
          "stable" = pkgs.rustup;
          "*" = pkgs.rustup;
        };
      };

      # Look up in version map, fall back to direct pkgs lookup
      fromVersionMap = versionMap.${name}.${version} or null;
      fromPkgs = pkgs.${name} or null;

    in
      if fromVersionMap != null then fromVersionMap
      else if fromPkgs != null then fromPkgs
      else throw "Unknown package: ${name} (version: ${version})";

    # Resolve a tool name to a package (for bundles, always use latest)
    resolveTool = pkgs: name: mapTool pkgs name "*";

  in {
    devShells = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      # Get included bundles from deps.toml
      includedBundles = deps.bundles.include or [];

      # Collect all tool names from included bundles
      bundleToolNames = builtins.concatLists (
        map (name: bundles.${name} or []) includedBundles
      );

      # Resolve bundle tools to packages
      bundlePackages = map (resolveTool pkgs) bundleToolNames;

      # Map explicit tools from deps.toml
      explicitTools = builtins.attrValues (
        builtins.mapAttrs (mapTool pkgs) (deps.tools or {})
      );

      # Platform-specific: Linux needs libstdc++ for Python native extensions
      linuxDeps = pkgs.lib.optionals pkgs.stdenv.isLinux [
        pkgs.stdenv.cc.cc.lib
      ];

    in {
      default = pkgs.mkShell {
        # Explicit tools first so they take precedence in PATH
        packages = explicitTools ++ bundlePackages ++ linuxDeps;

        # Linux: ensure native extensions can find libstdc++
        LD_LIBRARY_PATH = pkgs.lib.optionalString pkgs.stdenv.isLinux
          "${pkgs.stdenv.cc.cc.lib}/lib";

        shellHook = ''
          echo "Dev environment loaded."
          ${if includedBundles != [] then ''echo "Bundles: ${builtins.concatStringsSep ", " includedBundles}"'' else ""}
        '';
      };
    });
  };
}
