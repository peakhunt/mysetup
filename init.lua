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
  -- Core plugins
  "nvim-tree/nvim-tree.lua",
  "nvim-tree/nvim-web-devicons",
  "nvim-lualine/lualine.nvim",
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {
      --enabled = true,
      -- indent = { char = "┊" },
      --scope = { enabled = true, show_start = true, show_end = true },
    },
  },


  -- nvim-cmp core
  { "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- LSP completions
      "hrsh7th/cmp-buffer", -- buffer words
      "hrsh7th/cmp-path", -- filesystem paths
      "hrsh7th/cmp-cmdline", -- command line completions
      "L3MON4D3/LuaSnip", -- snippet engine
      "saadparwaiz1/cmp_luasnip", -- snippet completions
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Themes
  "morhetz/gruvbox",
  "folke/tokyonight.nvim",
  { "catppuccin/nvim", name = "catppuccin" },
  "shaunsingh/nord.nvim",
  "scottmckendry/cyberdream.nvim",
  "neanias/everforest-nvim",
  "sainnhe/gruvbox-material",
  "rebelot/kanagawa.nvim",
  "EdenEast/nightfox.nvim",
  "sainnhe/edge",
  "NLKNguyen/papercolor-theme",
  "olimorris/onedarkpro.nvim",
  "rose-pine/neovim",
  "savq/melange-nvim",
  "ATTron/bebop.nvim",
  { 'projekt0n/github-nvim-theme', name = 'github-theme' },
})

-- Basic setup
local function open_pdf(path)
  vim.fn.jobstart({"xdg-open", path}, {detach = true})
end

require("nvim-tree").setup({
  actions = {
    open_file = {
      quit_on_open = false,
    },
  },
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.pdf",
  callback = function()
    open_pdf(vim.fn.expand("<afile>"))
    vim.cmd("bd") -- close buffer after opening externally
  end,
})

-- Keybinding to toggle tree
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>')

-- Keybinding to Telescope live_grep
vim.keymap.set('n', '<leader>fg', require('telescope.builtin').live_grep, { desc = "Live Grep" })
vim.keymap.set('n', '<leader>ff', require('telescope.builtin').find_files, { desc = "Find Files" })
vim.keymap.set('n', '<leader>gw', require('telescope.builtin').grep_string, { desc = "Grep word under cursor" })
vim.keymap.set('v', '<leader>gw', function()
  local builtin = require('telescope.builtin')
  builtin.grep_string({ search = vim.fn.expand("<cword>") })
end, { desc = "Grep visual selection" })

require('lualine').setup {
  options = {
    theme = 'onelight',
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    icons_enabled = true,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff' },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
}

local highlight = {
  "RainbowRed",
  "RainbowYellow",
  "RainbowBlue",
  "RainbowOrange",
  "RainbowGreen",
  "RainbowViolet",
  "RainbowCyan",
}

local hooks = require "ibl.hooks"
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
  vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
  vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
  vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
  vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
  vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
  vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
end)

require("ibl").setup {
  indent = {
    char = "┊", -- ultra-lean
    tab_char = "┊",
    highlight = highlight,
  },
  whitespace = {
    highlight = nil, -- disable whitespace highlighting
    remove_blankline_trail = true,
  },
  scope = { enabled = false },
}
-- vim.api.nvim_set_hl(0, "IndentLean", { fg = "#3e4451", nocombine = true })

vim.cmd("syntax on")
vim.opt.termguicolors = true

--vim.cmd([[
--  augroup TransparentBackground
--    autocmd!
--    autocmd ColorScheme * highlight Normal ctermbg=none guibg=none
--    autocmd ColorScheme * highlight NonText ctermbg=none guibg=none
--  augroup END
--]])
vim.cmd("colorscheme PaperColor")

-- Set indentation
vim.opt.shiftwidth = 2   -- number of spaces for autoindent
vim.opt.tabstop = 2      -- number of spaces per tab
vim.opt.expandtab = true -- convert tabs to spaces

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

vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
