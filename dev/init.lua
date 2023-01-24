local cwd = vim.fn.getcwd()
vim.opt.runtimepath:prepend(cwd)

--[[
-- plugin name will be used to reload the loaded modules
--]]
local package_name = 'react'

-- add the escape character to special characters
--  local escape_pattern = function (text)
--  return text:gsub("([^%w])", "%%%1")
--  end

-- unload loaded modules by the matching text
local function unload_packages()
	for module_name, _ in pairs(package.loaded) do
		if string.find(module_name, '^' .. package_name) then
			package.loaded[module_name] = nil
		end
	end
end

-- executes the run method in the package
local run_action = function()
	require('react').run()
	--  vim.cmd('luafile test.lua')
end

-- unload and run the function from the package
local function reload_and_run()
	unload_packages()
	run_action()
end

vim.keymap.set('n', '')

vim.keymap.set('n', '<leader><leader>r', '<cmd>luafile dev/init.lua<cr>', {})
vim.keymap.set('n', '<leader><leader>w', reload_and_run, {})
vim.keymap.set('n', '<leader><leader>u', unload_packages, {})
