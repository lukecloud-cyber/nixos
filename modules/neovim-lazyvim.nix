{ config, pkgs, ... }:

let
  # Bundle parsers into Tree-sitter so LazyVim never downloads them at runtime.
  treesitterWithParsers = pkgs.vimPlugins.nvim-treesitter.withPlugins (
    parsers: with parsers; [
      bash # Shell scripts.
      c # C source and headers.
      diff # Unified and context diffs.
      html # HTML documents.
      javascript # JavaScript source.
      jsdoc # JavaScript documentation comments.
      json # JSON data.
      lua # Lua source used by Neovim configuration.
      luadoc # Lua documentation comments.
      luap # Lua patterns embedded in strings.
      markdown # Markdown block structure.
      markdown_inline # Inline Markdown emphasis, links, and code.
      nix # Nix expressions and modules.
      printf # printf-style format strings.
      python # Python source.
      query # Tree-sitter query files.
      regex # Regular expressions embedded in other languages.
      toml # TOML configuration.
      tsx # TypeScript with JSX syntax.
      typescript # TypeScript source.
      vim # Vimscript source.
      vimdoc # Vim help documentation.
      xml # XML documents.
      yaml # YAML data and configuration.
    ]
  );
in
{
  # LazyVim is managed through the system Neovim module. Core plugins and
  # editor tooling come from nixpkgs; Lazy remains available for its UI.
  programs.neovim = {
    enable = true; # Install Neovim and expose its NixOS integration.
    defaultEditor = true; # Set EDITOR to Neovim.
    viAlias = true; # Point `vi` at Neovim.
    vimAlias = true; # Point `vim` at Neovim.
    withNodeJs = true; # Supply Node.js for JavaScript-based providers/plugins.
    withPython3 = true; # Supply Python 3 for Python-based providers/plugins.
    withRuby = false; # Skip the unused Ruby provider.

    configure = {
      # Put all LazyVim runtime plugins on Neovim's native start package path.
      packages.lazyvim.start = with pkgs.vimPlugins; [
        lazy-nvim # Plugin manager and LazyVim configuration engine.
        LazyVim # Opinionated Neovim distribution and default plugin spec.

        blink-cmp # Fast completion menu and completion engine.
        blink-compat # Adapter for nvim-cmp completion sources.
        bufferline-nvim # Tab-like list of open buffers.
        catppuccin-nvim # Catppuccin color scheme.
        conform-nvim # Formatter runner with per-filetype selection.
        flash-nvim # Label-based navigation to visible text.
        friendly-snippets # Shared snippets for common languages.
        gitsigns-nvim # Git change markers and actions in the gutter.
        grug-far-nvim # Project-wide search and replace interface.
        lazydev-nvim # Lua language support aware of Neovim APIs.
        lualine-nvim # Configurable status line.
        mason-lspconfig-nvim # Bridge between Mason and nvim-lspconfig.
        mason-nvim # UI for external editor tools; downloads are disabled below.
        mini-ai # Text objects for arguments, quotes, brackets, and more.
        mini-icons # Filetype and UI icons.
        mini-pairs # Automatic bracket and quote pairing.
        neo-tree-nvim # File, buffer, and Git-status explorer.
        noice-nvim # Rich command-line, message, and popup UI.
        nui-nvim # UI component library required by several plugins.
        nvim-lint # Asynchronous linter runner.
        nvim-lspconfig # Configurations for Neovim's built-in LSP client.
        nvim-treesitter-textobjects # Syntax-aware selections and motions.
        nvim-ts-autotag # Automatically close and rename paired markup tags.
        persistence-nvim # Save and restore editor sessions.
        plenary-nvim # Shared Lua utility library for Neovim plugins.
        render-markdown-nvim # Render Markdown structure inside buffers.
        SchemaStore-nvim # Catalog of JSON schemas for language servers.
        snacks-nvim # LazyVim utility collection and UI components.
        todo-comments-nvim # Highlight and search TODO-style annotations.
        tokyonight-nvim # Tokyo Night color scheme.
        treesitterWithParsers # Tree-sitter engine plus the parsers listed above.
        trouble-nvim # Navigable diagnostics and reference lists.
        ts-comments-nvim # Language-aware comment strings for embedded syntax.
        which-key-nvim # Popup guide for available key mappings.
        yanky-nvim # Enhanced yank history and put operations.
      ];

      # Tell Lazy which Nix store path backs each plugin repository.
      customLuaRC = ''
        local function nix_plugin(repo, dir)
          return { repo, dir = dir }
        end

        require("lazy").setup({
          spec = {
            nix_plugin("folke/lazy.nvim", "${pkgs.vimPlugins.lazy-nvim}"),
            nix_plugin("LazyVim/LazyVim", "${pkgs.vimPlugins.LazyVim}"),
            nix_plugin("folke/snacks.nvim", "${pkgs.vimPlugins.snacks-nvim}"),
            nix_plugin("saghen/blink.cmp", "${pkgs.vimPlugins.blink-cmp}"),
            nix_plugin("saghen/blink.compat", "${pkgs.vimPlugins.blink-compat}"),
            nix_plugin("rafamadriz/friendly-snippets", "${pkgs.vimPlugins.friendly-snippets}"),
            nix_plugin("akinsho/bufferline.nvim", "${pkgs.vimPlugins.bufferline-nvim}"),
            nix_plugin("catppuccin/nvim", "${pkgs.vimPlugins.catppuccin-nvim}"),
            nix_plugin("stevearc/conform.nvim", "${pkgs.vimPlugins.conform-nvim}"),
            nix_plugin("folke/flash.nvim", "${pkgs.vimPlugins.flash-nvim}"),
            nix_plugin("lewis6991/gitsigns.nvim", "${pkgs.vimPlugins.gitsigns-nvim}"),
            nix_plugin("MagicDuck/grug-far.nvim", "${pkgs.vimPlugins.grug-far-nvim}"),
            nix_plugin("folke/lazydev.nvim", "${pkgs.vimPlugins.lazydev-nvim}"),
            nix_plugin("nvim-lualine/lualine.nvim", "${pkgs.vimPlugins.lualine-nvim}"),
            nix_plugin("mason-org/mason-lspconfig.nvim", "${pkgs.vimPlugins.mason-lspconfig-nvim}"),
            nix_plugin("mason-org/mason.nvim", "${pkgs.vimPlugins.mason-nvim}"),
            nix_plugin("nvim-mini/mini.ai", "${pkgs.vimPlugins.mini-ai}"),
            nix_plugin("nvim-mini/mini.icons", "${pkgs.vimPlugins.mini-icons}"),
            nix_plugin("nvim-mini/mini.pairs", "${pkgs.vimPlugins.mini-pairs}"),
            nix_plugin("nvim-neo-tree/neo-tree.nvim", "${pkgs.vimPlugins.neo-tree-nvim}"),
            nix_plugin("folke/noice.nvim", "${pkgs.vimPlugins.noice-nvim}"),
            nix_plugin("MunifTanjim/nui.nvim", "${pkgs.vimPlugins.nui-nvim}"),
            nix_plugin("mfussenegger/nvim-lint", "${pkgs.vimPlugins.nvim-lint}"),
            nix_plugin("neovim/nvim-lspconfig", "${pkgs.vimPlugins.nvim-lspconfig}"),
            nix_plugin("nvim-treesitter/nvim-treesitter", "${treesitterWithParsers}"),
            nix_plugin("nvim-treesitter/nvim-treesitter-textobjects", "${pkgs.vimPlugins.nvim-treesitter-textobjects}"),
            nix_plugin("windwp/nvim-ts-autotag", "${pkgs.vimPlugins.nvim-ts-autotag}"),
            nix_plugin("folke/persistence.nvim", "${pkgs.vimPlugins.persistence-nvim}"),
            nix_plugin("nvim-lua/plenary.nvim", "${pkgs.vimPlugins.plenary-nvim}"),
            nix_plugin("MeanderingProgrammer/render-markdown.nvim", "${pkgs.vimPlugins.render-markdown-nvim}"),
            nix_plugin("b0o/SchemaStore.nvim", "${pkgs.vimPlugins.SchemaStore-nvim}"),
            nix_plugin("folke/todo-comments.nvim", "${pkgs.vimPlugins.todo-comments-nvim}"),
            nix_plugin("folke/tokyonight.nvim", "${pkgs.vimPlugins.tokyonight-nvim}"),
            nix_plugin("folke/trouble.nvim", "${pkgs.vimPlugins.trouble-nvim}"),
            nix_plugin("folke/ts-comments.nvim", "${pkgs.vimPlugins.ts-comments-nvim}"),
            nix_plugin("folke/which-key.nvim", "${pkgs.vimPlugins.which-key-nvim}"),
            nix_plugin("gbprod/yanky.nvim", "${pkgs.vimPlugins.yanky-nvim}"),

            -- Load LazyVim defaults and the selected language/editor extras.
            { "LazyVim/LazyVim", import = "lazyvim.plugins" },
            { import = "lazyvim.plugins.extras.lang.nix" },
            { import = "lazyvim.plugins.extras.lang.json" },
            { import = "lazyvim.plugins.extras.lang.yaml" },
            { import = "lazyvim.plugins.extras.editor.neo-tree" },
            { import = "lazyvim.plugins.extras.coding.yanky" },

            -- Nix supplies external tools, so Mason must not install duplicates.
            {
              "mason-org/mason.nvim",
              opts = function(_, opts)
                opts.ensure_installed = {}
              end,
            },

            -- Nix supplies immutable Tree-sitter parsers listed above.
            {
              "nvim-treesitter/nvim-treesitter",
              opts = function(_, opts)
                opts.ensure_installed = {}
              end,
            },

            -- Use system language servers and configure nixd for this flake.
            {
              "neovim/nvim-lspconfig",
              opts = {
                servers = {
                  nil_ls = { enabled = false },
                  nixd = {
                    mason = false,
                    cmd = { "nixd" },
                    settings = {
                      nixd = {
                        nixpkgs = {
                          expr = "import <nixpkgs> { }",
                        },
                        formatting = {
                          command = { "nixfmt" },
                        },
                        options = {
                          nixos = {
                            expr = '(builtins.getFlake "/etc/nixos").nixosConfigurations.${config.networking.hostName}.options',
                          },
                        },
                      },
                    },
                  },
                  lua_ls = { mason = false },
                  jsonls = { mason = false },
                  yamlls = { mason = false },
                },
              },
            },
          },
          defaults = {
            -- All plugins are already available at startup from the Nix store.
            lazy = false,
            version = false,
          },
          install = {
            -- Never download missing plugins; retain a built-in fallback theme.
            missing = false,
            colorscheme = { "tokyonight", "habamax" },
          },
          checker = {
            -- Flake updates, not Lazy, control plugin upgrades.
            enabled = false,
            notify = false,
          },
          change_detection = {
            -- Nix store plugin paths are immutable and need no reload checks.
            enabled = false,
            notify = false,
          },
          rocks = {
            -- Do not install LuaRocks dependencies outside Nix.
            enabled = false,
          },
          performance = {
            -- Preserve Nix's package path and trim unused built-in plugins.
            reset_packpath = false,
            rtp = {
              disabled_plugins = {
                "gzip",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
              },
            },
          },
        })
      '';
    };
  };

  # Install the external language servers, formatters, and CLI tools used above.
  environment.systemPackages = with pkgs; [
    alejandra # Opinionated Nix formatter retained for project compatibility.
    deadnix # Detect unused Nix bindings and dead code.
    fzf # Fuzzy finder used by editor pickers and shell workflows.
    gcc # C compiler required by native extensions and tooling.
    git # Version-control backend used by editor integrations.
    lazygit # Terminal Git interface launched from LazyVim.
    lua-language-server # Language server for Lua and Neovim configuration.
    nil # Alternative Nix language server retained for projects that request it.
    nixd # Primary Nix language server configured above.
    nixfmt # Official Nix formatter selected by nixd.
    nodejs # Runtime for JavaScript language servers and formatters.
    prettierd # Long-running Prettier formatter daemon.
    python3 # Runtime for Python editor providers and tools.
    shfmt # Formatter for shell scripts.
    statix # Linter for Nix antipatterns.
    stylua # Formatter for Lua source.
    tree-sitter # Parser generator and syntax tree command-line tool.
    vscode-langservers-extracted # HTML, CSS, JSON, and ESLint language servers.
    yaml-language-server # YAML validation and completion server.
  ];
}
