---@diagnostic disable: undefined-global
local core = require('react.core')
local render = require('react.render-new')
local uv = require("luv")

local create_signal = core.create_signal

local type, set_type = create_signal('SuperUser')

function SuperUser()
  print('render SuperUser')
  return {
    'This is super user page'
  }
end

function User()
  print('render User')
  return {
    'This is user page'
  }
end

function Admin()
  print('render Admin')
  return {
    'This is admin page'
  }
end

function Root()
  print('render Root')
  if type() == 'Admin' then
    return {
      Admin
    }
  elseif type() == 'SuperUser' then
    return {
      'My website',
      SuperUser,
      ' testing'
    }
  else
    return {
      User
    }
  end
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

  M.set_timeout(2000, function()
    set_type('Admin')
  end)

  --  M.set_timeout(3000, function()
    --  set_type('User')
  --o end)

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
