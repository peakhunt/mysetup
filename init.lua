-- Add LuaRocks paths
local home = os.getenv("HOME")
package.path = package.path .. ";" .. home .. "/.luarocks/share/lua/5.1/?.lua;" .. home .. "/.luarocks/share/lua/5.1/?/init.lua"
package.cpath = package.cpath .. ";" .. home .. "/.luarocks/lib/lua/5.1/?.so"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "nvim-tree/nvim-tree.lua",
  "nvim-tree/nvim-web-devicons",
  "nvim-lualine/lualine.nvim",
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
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename",
            "--line-number", "--column", "--smart-case",
          },
        },
        extensions = {
          live_grep_args = {
            auto_quoting = false,
            -- Define mappings inside the TUI
            mappings = {
              i = {
                ["<C-k>"] = require("telescope-live-grep-args.actions").quote_prompt(),
                ["<C-i>"] = require("telescope-live-grep-args.actions").quote_prompt({ postfix = " -t " }),
              },
            },
          }
        }
      })
      telescope.load_extension('fzf')
      telescope.load_extension("live_grep_args")
    end
  },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  { "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline", "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, { name = "luasnip" }, { name = "buffer" }, { name = "path" },
        }),
      })
    end,
  },
  -- Themes
  "morhetz/gruvbox", "folke/tokyonight.nvim", { "catppuccin/nvim", name = "catppuccin" },
  "sainnhe/gruvbox-material", "rebelot/kanagawa.nvim", "sainnhe/edge",
  "rose-pine/neovim", "ATTron/bebop.nvim",
})

-- Nvim-Tree Setup
require("nvim-tree").setup({
  update_cwd = true,
  respect_buf_cwd = true,
  sync_root_with_cwd = true,
  git = { ignore = false },
})

-- KEYMAPS
vim.keymap.set("n", "<leader>fg", function()
  require('telescope').extensions.live_grep_args.live_grep_args()
end, { desc = "Live Grep with Args" })
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = "Find Files" })
vim.keymap.set('n', '<leader>gw', require('telescope.builtin').grep_string, { desc = "Grep word under cursor" })
vim.keymap.set('v', '<leader>gw', function()
  local function get_visual_selection()
    vim.cmd('noau normal! "vy"')
    return vim.fn.getreg('v')
  end
  require('telescope.builtin').grep_string({ search = get_visual_selection() })
end, { desc = "Grep visual selection" })

-- Utility functions & Autocmds
local function open_pdf(path) vim.fn.jobstart({"xdg-open", path}, {detach = true}) end
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.pdf",
  callback = function() open_pdf(vim.fn.expand("<afile>")); vim.cmd("bd") end,
})

-- Visual Settings
vim.opt.termguicolors = true
vim.cmd("colorscheme catppuccin-mocha")
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true

-- Lualine
require('lualine').setup { options = { theme = 'onelight', icons_enabled = true } }

-- Indent Blankline
require("ibl").setup { indent = { char = "┊" }, scope = { enabled = false } }

vim.opt.number = true
vim.opt.relativenumber = true

vim.filetype.add(
  {
    extension = 
    {
      v = "verilog",
      sv = "verilog",
      vhd = "vhdl", 
    }, 
  }
)

local cmp = require'cmp'

cmp.setup {
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer',
      option = {
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()
        end
      }
    },
  }
}

-- Copy selection to system clipboard with <leader>c in Visual mode
vim.keymap.set('v', '<leader>c', '"+y', { desc = "Copy to system clipboard" })

vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { silent = true })

vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

local cmp = require'cmp'

cmp.setup({
  completion = {
    completeopt = 'menu,menuone,noinsert'
  },
  preselect = cmp.PreselectMode.Item,  -- auto-select the first item
  mapping = {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<CR>']  = cmp.mapping.confirm({ select = true }),
  },
})

