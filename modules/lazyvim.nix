{ pkgs, ... }:

let
  treesitterWithParsers = pkgs.vimPlugins.nvim-treesitter.withPlugins (
    parsers: with parsers; [
      bash
      c
      diff
      html
      javascript
      jsdoc
      json
      lua
      luadoc
      luap
      markdown
      markdown_inline
      nix
      printf
      python
      query
      regex
      toml
      tsx
      typescript
      vim
      vimdoc
      xml
      yaml
    ]
  );
in
{
  # LazyVim is managed through the system Neovim module. Core plugins and
  # editor tooling come from nixpkgs; Lazy remains available for its UI.
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = false;

    configure = {
      packages.lazyvim.start = with pkgs.vimPlugins; [
        lazy-nvim
        LazyVim

        blink-cmp
        blink-compat
        bufferline-nvim
        catppuccin-nvim
        conform-nvim
        flash-nvim
        friendly-snippets
        gitsigns-nvim
        grug-far-nvim
        lazydev-nvim
        lualine-nvim
        mason-lspconfig-nvim
        mason-nvim
        mini-ai
        mini-icons
        mini-pairs
        neo-tree-nvim
        noice-nvim
        nui-nvim
        nvim-lint
        nvim-lspconfig
        nvim-treesitter-textobjects
        nvim-ts-autotag
        persistence-nvim
        plenary-nvim
        render-markdown-nvim
        SchemaStore-nvim
        snacks-nvim
        todo-comments-nvim
        tokyonight-nvim
        treesitterWithParsers
        trouble-nvim
        ts-comments-nvim
        which-key-nvim
        yanky-nvim
      ];

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

            { "LazyVim/LazyVim", import = "lazyvim.plugins" },
            { import = "lazyvim.plugins.extras.lang.nix" },
            { import = "lazyvim.plugins.extras.lang.json" },
            { import = "lazyvim.plugins.extras.lang.yaml" },
            { import = "lazyvim.plugins.extras.editor.neo-tree" },
            { import = "lazyvim.plugins.extras.coding.yanky" },

            {
              "mason-org/mason.nvim",
              opts = function(_, opts)
                opts.ensure_installed = {}
              end,
            },

            {
              "nvim-treesitter/nvim-treesitter",
              opts = function(_, opts)
                opts.ensure_installed = {}
              end,
            },

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
                            expr = '(builtins.getFlake "/etc/nixos").nixosConfigurations.nixos.options',
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
            lazy = false,
            version = false,
          },
          install = {
            missing = false,
            colorscheme = { "tokyonight", "habamax" },
          },
          checker = {
            enabled = false,
            notify = false,
          },
          change_detection = {
            enabled = false,
            notify = false,
          },
          rocks = {
            enabled = false,
          },
          performance = {
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

  environment.systemPackages = with pkgs; [
    alejandra
    deadnix
    fzf
    gcc
    git
    lazygit
    lua-language-server
    nil
    nixd
    nixfmt
    nodejs
    prettierd
    python3
    shfmt
    statix
    stylua
    tree-sitter
    vscode-langservers-extracted
    yaml-language-server
  ];
}
