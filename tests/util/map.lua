local M = {}

function M.get_keys(map)
  local keys = {}

  for key, _ in pairs(map) do
    table.insert(keys, key)
  end

  table.sort(keys)

  return keys
end

return M
