local function wrapper(fc, props)
  return function()
    return fc(props)
  end
end
