local core = require('react.core')
local render = require('react.render')
local uv = require("luv")

local create_signal = core.create_signal


function A()
  return {
    'hello', ' ', 'world',
    '\n'
  }
end

local name, set_name = create_signal('Srinesh')

function B()
  return {
    'Hello', ' ', name()
  }
end

local M = {}

function M.run()
  print('...........................')
  local buffer = 454

  render(buffer, function()
    return {
      A, B
    }
  end)
end

function M.set_timeout(timeout, callback)
  local timer = uv.new_timer()
  local function ontimeout()
    uv.timer_stop(timer)
    uv.close(timer)
    callback()
  end

  uv.timer_start(timer, timeout, 0, ontimeout)
  return timer
end

return M
