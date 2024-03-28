-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Lean & mean status/tabline
  use 'vim-airline/vim-airline'
  use 'vim-airline/vim-airline-themes'

  use 'tpope/vim-fugitive'

  use 'rhysd/vim-grammarous' -- grammar check
  use 'andymass/vim-matchup' -- matching parens and more
  use 'bronson/vim-trailing-whitespace' -- highlight trailing spaces
  use 'rhysd/git-messenger.vim'

  use 'kyazdani42/nvim-web-devicons' -- icons when searching

    -- python
  use { 'Vimjas/vim-python-pep8-indent', ft = 'python' }

  -- color scheme
  use 'EdenEast/nightfox.nvim'
  -- use 'marko-cerovac/material.nvim'
  --use 'navarasu/onedark.nvim'
end)
