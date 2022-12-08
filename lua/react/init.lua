---@diagnostic disable: undefined-global
local core = require('react.core')
local render = require('react.render')
local uv = require("luv")

local create_signal = core.create_signal

local greet, set_greet = create_signal('Welcome')

local fname, set_fname = create_signal('Alison')
local lname, _ = create_signal('Swift')

function Greet()
  print('render greet')
  return {
    greet()
  }
end

function Name()
  print('render name')
  return {
    fname(), ' ', lname()
  }
end

function Root()
  return {
    Greet, ' ', Name
  }
end

local M = {}

local buffer = nil

function M.run()
  if not buffer or vim.api.nvim_buf_is_valid(buffer) then
    buffer = vim.api.nvim_create_buf(true, true)
  end

  local win = vim.api.nvim_open_win(buffer, true, {
    relative = 'editor',
    width = 50,
    height = 30,
    row = 15,
    col = 100,
  })

  render(buffer, Root)

  M.set_timeout(1000, function()
    set_fname('Taylor')
  end)

  M.set_timeout(2000, function()
    set_greet('Hello')
  end)

  M.set_timeout(3000, function()
    vim.schedule(function()
      vim.api.nvim_win_close(win, true)
    end)
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
