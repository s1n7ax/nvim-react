local core = require('react.core')

local create_effect

local M = {}

function M:new(wrapper)
  local o = {
    nodes = {},
    wrapper = wrapper
  }

  setmetatable(o, self)
  self.__index = self

  create_effect(function()
    o:init_cmp(o.wrapper)
  end)

  return o
end

function M:init_cmp(wrapper)
  -- reset the nodes on each re-render
  self.nodes = {}

  local content = wrapper()

  for _, node in ipairs(content) do
    -- if the node is a text then store as text
    if type(node) == "string" then
      table.insert(self.nodes, node)
    end

    if type(node) == "function" then
      table.insert(self.nodes, M:new(node))
    end
  end
end

function M:get_text()
  local text = ''

  for _, node in ipairs(self.nodes) do
    if type(node) == "string" then
      text = text .. node
    else
      text = text .. node:get_text()
    end
  end

  return text
end

local function render(buffer, component)
  local root
  local done = false

  local function draw()
    if not done then return end
    local text = root:get_text()
    local lines = {}

    for s in text:gmatch("[^\r\n]+") do
      table.insert(lines, s)
    end

    ---@diagnostic disable-next-line: undefined-global
    vim.schedule(function()
      ---@diagnostic disable-next-line: undefined-global
      vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
    end)
  end

  create_effect = function(callback)
    core.create_effect(function()
      callback()
      draw()
    end)
  end


  root = M:new(component)
  done = true
  draw()
end

return render
