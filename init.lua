-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Install package manager
--    
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)  


require('lazy').setup({

	-- NOTE: This is where your plugins related to LSP can be installed.
	--  The configuration is done below. Search for lspconfig to find it below.
	{
		-- LSP Configuration & Plugins
		'neovim/nvim-lspconfig',
		dependencies = {
			-- Automatically install LSPs to stdpath for neovim
			{ 'williamboman/mason.nvim', config = true },
			'williamboman/mason-lspconfig.nvim',

			-- Useful status updates for LSP
			-- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
			{ 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },

			-- Additional lua configuration, makes nvim stuff amazing!
			'folke/neodev.nvim',
		},
	},
	{
		'hrsh7th/nvim-cmp',
		dependencies = {

			-- Adds LSP completion capabilities
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-cmdline',
                        'hrsh7th/cmp-copilot',
                        'hrsh7th/cmp-vsnip',
		}
	},
	{
		-- Theme inspired by Atom
		'navarasu/onedark.nvim',
		priority = 1000,
		config = function()
			vim.cmd.colorscheme 'onedark'
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		}
	},
	'github/copilot.vim',
        {
            'nvim-telescope/telescope.nvim',
            requires = {{'nvim-lua/plenary.nvim'}}
        },
        {
            "nvim-treesitter/nvim-treesitter",
            run = ":TSUpdate",
            highlight = {
                enable = true,
                disable = {},
            },
            ensure_installed = {
                "bash",
                "c",
                "cpp",
                "css",
                "dockerfile",
                "go",
                "gomod",
                "html",
                "java",
                "javascript",
                "json",
                "jsonc",
                "lua",
                "python",
                "pug",
                "regex",
                "rust",
                "toml",
                "typescript",
                "yaml",
            },
        },
        {
            "numToStr/Comment.nvim",
            opts = {},
            lazy = false
        },
        'kaarmu/typst.vim',
        'digitaltoad/vim-pug',
        'exosite/lua-yaml'
})

-- Set highlight on search
vim.o.hlsearch = false

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'


-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

vim.g.mapleader = ' '

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = '*',
})

vim.opt.softtabstop=4 
vim.opt.shiftwidth=4 
vim.opt.expandtab=true
vim.opt.colorcolumn="80"

vim.api.nvim_set_keymap('n', '<C-Up>', '<C-W><C-K>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-Down>', '<C-W><C-J>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-Left>', '<C-W><C-H>', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-Right>', '<C-W><C-L>', { noremap = true })
-- vim.api.nvim_set_keymap('n', '<C-v>', '<C-r>+', { noremap = true })

--vim.cmd([[nnoremap <Leader>t :Neotree reveal<cr>]])
vim.api.nvim_set_keymap('n', '<Leader>t', ':Neotree reveal<cr>', { noremap = true })

local cmp = require 'cmp'

cmp.setup {
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<Up>'] = cmp.mapping.select_prev_item(),
    ['<Down>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'cmdline' },
    { name = 'copilot' },
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
    autocomplete = false,
  },
}
local lspconfig = require('lspconfig')
local lsp_defaults = lspconfig.util.default_config

lsp_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lsp_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)
lspconfig.jdtls.setup({})
lspconfig.rust_analyzer.setup({
    settings = {
        ["rust-analyzer"] = {
            diagnostics = {
                disabled = {"unresolved-proc-macro"}
            }
        }
    }
})
lspconfig.ruff_lsp.setup({})

-- Enable spell check automatically for text files
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "html", "markdown", "text" },
    callback = function()
        vim.opt_local.spell = true
    end,
}) 

-- Copilot for markdown
vim.g.copilot_filetypes = {markdown = true}

vim.cmd([[
  augroup FileTypePug
    autocmd!
    autocmd FileType pug setlocal tabstop=2 shiftwidth=2 softtabstop=2
  augroup END
]])

