local core = require('react.core')

local create_effect

local M = {}

function M:new(wrapper)
  local o = {
    text = '',
    wrapper = wrapper
  }

  create_effect(function()
    o:generate_text()
  end)


  setmetatable(o, self)
  self.__index = self
  return o
end

function M:generate_text(wrapper)
  local this = self

  local content = wrapper()

  for _, node in ipairs(content) do
    if type(node) == "function" then
      this.text = this.text .. M:new(node):get_text()
    end

    if type(node) == "string" then
      this.text = this.text .. node
    end
  end
end

function M:get_text()
  return self.text
end

local function render(buffer, component)
  local root

  local function draw()
    local text = root:get_text()
    local lines = {}

    for s in text:gmatch("[^\r\n]+") do
      table.insert(lines, s)
    end

    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  end

  create_effect = function(callback)
    core.create_effect(function()
      callback()
      draw()
    end)

  end

  root = M:new(component)
end

return render
