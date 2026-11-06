-- Minimal Neovim config: 0.12 built-ins (vim.pack, catppuccin, LSP) plus
-- mini.nvim. Role: $EDITOR/$VISUAL for git commits, OpenCode's /editor and
-- quick terminal edits. Doom Emacs remains the main editor.

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- File manager from mini.files instead of netrw.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt
opt.number = true
opt.signcolumn = "yes"
opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.smartindent = true
opt.wrap = false
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.splitright = true
opt.splitbelow = true
opt.scrolloff = 4
opt.termguicolors = true
opt.clipboard = "unnamedplus"
opt.confirm = true

-- Installs on first start; `:lua vim.pack.update()` updates everything.
vim.pack.add({ "https://github.com/echasnovski/mini.nvim" })

require("mini.ai").setup()
require("mini.surround").setup()
require("mini.statusline").setup()
require("mini.files").setup()
require("mini.pick").setup()
require("mini.clue").setup({})

local map = vim.keymap.set
local function mini_pick(builtin)
  return function()
    require("mini.pick").builtin[builtin]()
  end
end

map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save" })
map("n", "<leader>e", function() require("mini.files").open() end, { desc = "File manager" })
map("n", "<leader>ff", mini_pick("files"), { desc = "Find files" })
map("n", "<leader>fg", mini_pick("grep_live"), { desc = "Live grep" })
map("n", "<leader>fb", mini_pick("buffers"), { desc = "Buffers" })
map("n", "<leader>fh", mini_pick("help"), { desc = "Help" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- Ships with Neovim 0.12 and follows 'background' (Mocha dark / Latte light),
-- which Ghostty updates live via DEC mode 2031.
vim.cmd.colorscheme("catppuccin")

vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.textwidth = 72
  end,
})

-- LSP is optional: only wired up when the server is on PATH.
if vim.fn.executable("ty") == 1 then
  vim.lsp.config("ty", {
    cmd = { "ty", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "uv.lock", ".git" },
  })
  vim.lsp.enable("ty")
end

if vim.fn.executable("ruby-lsp") == 1 then
  vim.lsp.config("ruby_lsp", {
    cmd = { "ruby-lsp" },
    filetypes = { "ruby" },
    root_markers = { "Gemfile", ".git" },
  })
  vim.lsp.enable("ruby_lsp")
end
