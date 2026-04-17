-- 1. Setup Lazy.nvim path
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 2. Run Setup
require("lazy").setup({
  -- CORE PLUGINS
  "nvim-tree/nvim-tree.lua",
  "nvim-tree/nvim-web-devicons",
  "nvim-lualine/lualine.nvim",
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  
  -- TELESCOPE
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      { "nvim-telescope/telescope-live-grep-args.nvim" , version = "^1.0.0" },
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup({
        defaults = {
          vimgrep_arguments = { "rg", "--color=never", "--no-heading", "--with-filename",
                                "--line-number", "--column", "--smart-case" },
        },
      })
      telescope.load_extension('fzf')
      telescope.load_extension("live_grep_args")
    end
  },

  -- TREESITTER (Fixed diet)
  { 
    "nvim-treesitter/nvim-treesitter", 
    build = ":TSUpdate",
    config = function()
      local status, ts = pcall(require, "nvim-treesitter")
      if not status then return end

      ts.setup({
        -- Force it to use the standard site directory
        install_dir = vim.fn.stdpath("data") .. "/site",
        ensure_installed = { "lua", "vim", "vimdoc", "python",
                              "javascript", "verilog", "c", "html", "vue", "css" },
        highlight = { enable = true },
      })
      -- Satisfy treesitter checkhealth bug which expects trailing slash
      vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/site/")
    end
  },

  -- AUTOCOMPLETE & SNIPPETS
  { 
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, { name = "luasnip" }, { name = "buffer" }, { name = "path" },
        }),
      })
    end,
  },

  -- THEMES
  "morhetz/gruvbox", "folke/tokyonight.nvim", { "catppuccin/nvim", name = "catppuccin" },
  "sainnhe/gruvbox-material", "rebelot/kanagawa.nvim", "rose-pine/neovim",
  "nkxxll/ghostty-default-style-dark.nvim",

}, {
  -- LAZY CONFIG (The "No Bloat" zone)
  rocks = { enabled = false }, 
  pkg = { sources = { "ghostty", "terminal", "packer", "local" } } -- Strictly no luarocks
})

require('kanagawa').setup({
  transparent = false,  -- This removes the background color
  theme = "wave",      -- Or "dragon" / "lotus"
  overrides = function(colors)
    return {
      -- Optional: If you want a "tinted" transparency look, 
      -- you can leave some UI elements opaque or dimmed.
      NormalFloat = { bg = "none" },
      FloatBorder = { bg = "none" },
    }
  end,
})

-- 3. GENERAL SETTINGS
vim.opt.termguicolors = true
--vim.cmd("colorscheme catppuccin-latte")
vim.cmd("colorscheme kanagawa")
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true

-- 4. PLUGIN SETUP
require("nvim-tree").setup({ update_cwd = true, respect_buf_cwd = true, sync_root_with_cwd = true })
require('lualine').setup { options = { theme = 'auto' } }
require("ibl").setup { indent = { char = "┊" }, scope = { enabled = false } }

-- 5. KEYMAPS
vim.keymap.set("n", "<leader>fg", function()
  require('telescope').extensions.live_grep_args.live_grep_args()
end, { desc = "Live Grep with Args" })
vim.keymap.set('n', '<leader>gw', function()
    require('telescope.builtin').live_grep({
        default_text = vim.fn.expand("<cword>"),
    })
end, { desc = 'Live grep word under cursor' })
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { silent = true })
vim.keymap.set('v', '<leader>c', '"+y', { desc = "Copy to system clipboard" })
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files)

vim.keymap.set('n', '<leader>gc', require('telescope.builtin').git_commits, { desc = 'Telescope Git Commits' })

-- Disable provider bloat
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

vim.opt_local.foldmethod = "manual"
vim.opt_local.foldlevel = 99
vim.opt_local.foldenable = true

-- Folding
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "c", "html", "vue", "javascript", "css" },
  callback = function()
    -- Use Tree-sitter for modern, context-aware folding
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    
    -- Start unfolded (99) so you can actually see your code
    vim.opt_local.foldlevel = 99
    vim.opt_local.foldenable = true

    -- BUG FIX: Tree-sitter folds often don't calculate on initial load.
    -- This "nudges" Neovim to look at the file structure immediately.
    vim.schedule(function()
      vim.cmd("normal! zx")
    end)
  end,
})

-- 4. THE SPACEBAR KING (MBS PIVOT)
vim.g.mapleader = " "
vim.keymap.set("n", "<space>", "za", { desc = "Toggle Fold" })

vim.o.background = "dark"
