local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		'git',
		'clone',
		'--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git',
		'--branch=stable',
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

local temp_path = './.test_plugins'

require('lazy').setup({
	{
		'nvim-lua/plenary.nvim',
		lazy = false,
	},
	-- {
	-- 	'nvim-java/nvim-java-test',
	-- 	---@diagnostic disable-next-line: assign-type-mismatch
	-- 	dir = local_plug('~/Workspace/nvim-java-test'),
	-- 	lazy = false,
	-- },
}, {
	root = temp_path,
	lockfile = temp_path .. '/lazy-lock.json',
	defaults = {
		lazy = false,
	},
})
