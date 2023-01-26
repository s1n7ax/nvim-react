local Set = require('react.util.set')

--- @module 'dict_helper'
local M = {}

--- Traverse through the table and find
--- @param publisher_map PublisherMap
--- @param path List
function M.publisher_path_traversal(publisher_map, path)
	local curr_pub_node = publisher_map

	for _, key in path:iter() do
		if not curr_pub_node.children[key] then
			curr_pub_node.children[key] = {
				-- adding key for debugging purposes
				key = key,
				effects = Set:new(),
				children = {},
			}
		end

		curr_pub_node = curr_pub_node.children[key]
	end

	return curr_pub_node
end

function M.get_curr_path_by_key(path, key)
	local path_clone = path:clone()
	path_clone:add(key)

	return path_clone
end

function M.dispatch_and_remove_children(root_pub_node)
	local effects_to_dispatch = M.get_all_effects_in_pub_node(root_pub_node)

	--[[
	-- @TODO - right now, this function dose not remove the signal from the effect
	-- signal should be stored and removed on this call
	--]]

	root_pub_node.children = {}

	for _, effect in effects_to_dispatch:iter() do
		effect:dispatch()
	end
end

function M.get_all_effects_in_pub_node(root_pub_node)
	local effects = Set:new()

	local capture_children_effects = nil

	capture_children_effects = function(pub_node)
		effects:concat(pub_node.effects)

		for _, child_pub_node in pairs(pub_node.children) do
			capture_children_effects(child_pub_node)
		end
	end

	capture_children_effects(root_pub_node)

	return effects
end

return M
