package.path = '../../../tests/?.lua;' .. package.path

local helper = require('react.stores.dict.helper')
local List = require('react.util.list')
local Set = require('react.util.set')
local Effect = require('react.core.effect')
local utils = require('tests.util.map')


describe('store::', function()
  describe('dict::', function()
    local get_init_pub_map = function()
      return { key = 'root', effects = Set:new(),
        children = { a = { key = 'a', effects = Set:new(),
          children = { b = { key = 'b', effects = Set:new(),
            children = { c = { key = 'c', effects = Set:new(), children = {} } } } } } } }
    end

    local pub_map = nil

    describe('helper::', function()
      ---@diagnostic disable-next-line: undefined-global
      before_each(function()
        pub_map = get_init_pub_map()
      end)

      it('traversal returns the correct node for given path', function()
        assert.equal(
          pub_map.children.a,
          helper.publisher_path_traversal(pub_map, List:new({ 'a' }))
        )

        assert.equal(
          pub_map.children.a.children.b,
          helper.publisher_path_traversal(pub_map, List:new({ 'a', 'b' }))
        )

        assert.not_equal(
          pub_map.children.a.children.b,
          helper.publisher_path_traversal(pub_map, List:new({ 'b' })).key
        )
      end)

      it('traversal creates the publishers map', function()
        pub_map = {
          key = 'root',
          effects = Set:new(),
          children = {},
        }

        local curr_pub_node = pub_map

        helper.publisher_path_traversal(pub_map, List:new({ 'a', 'b', 'c' }))

        for _, key in ipairs({ 'a', 'b', 'c' }) do
          assert.same({ 'children', 'effects', 'key' }, utils.get_keys(curr_pub_node))
          assert.same({ key }, utils.get_keys(curr_pub_node.children))
          assert.equal(curr_pub_node.effects:length(), 0)

          curr_pub_node = curr_pub_node.children[key]
        end
      end)

      it('current path appends key to parent path', function()
        local parent_path = List:new({ 'a', 'b', 'c' })

        assert.same(List:new({ 'a', 'b', 'c', 'd' }), helper.get_curr_path_by_key(parent_path, 'd'))
        assert.not_equal(List:new({ 'a', 'b', 'c', 'd' }), helper.get_curr_path_by_key(parent_path, 'd'))
      end)

      it('on store change, removes relevant children nodes', function()
        -- 1st level
        assert.same({ 'a' }, utils.get_keys(pub_map.children))
        helper.dispatch_and_remove_children(pub_map)
        assert.same({}, utils.get_keys(pub_map.children))

        -- 2nd level
        pub_map = get_init_pub_map()

        assert.same({ 'b' }, utils.get_keys(pub_map.children.a.children))
        helper.dispatch_and_remove_children(pub_map.children.a)
        assert.same({}, utils.get_keys(pub_map.children.a.children))

        -- 3rd level
        pub_map = get_init_pub_map()

        assert.same({ 'c' }, utils.get_keys(pub_map.children.a.children.b.children))
        helper.dispatch_and_remove_children(pub_map.children.a.children.b)
        assert.same({}, utils.get_keys(pub_map.children.a.children.b.children))
      end)

      it('on store change, dispatches current level effects', function()
        local init_data_set = function()
          pub_map = get_init_pub_map()

          local effects = {}
          local effect_values = { 0, 0, 0 }

          for i = 1, 3 do
            effects[i] = Effect:new(function()
              effect_values[i] = effect_values[i] + 1
            end)
          end

          pub_map.children.a.effects:add(effects[1])
          pub_map.children.a.children.b.effects:add(effects[2])
          pub_map.children.a.children.b.children.c.effects:add(effects[3])

          return effect_values
        end

        local effect_values = init_data_set()
        assert.same({ 0, 0, 0 }, effect_values)

        effect_values = init_data_set()
        helper.dispatch_and_remove_children(pub_map.children.a.children.b.children.c)
        assert.same({ 0, 0, 1 }, effect_values)

        effect_values = init_data_set()
        helper.dispatch_and_remove_children(pub_map.children.a.children.b)
        assert.same({ 0, 1, 1 }, effect_values)

        effect_values = init_data_set()
        helper.dispatch_and_remove_children(pub_map.children.a)
        assert.same({ 1, 1, 1 }, effect_values)
      end)

      it('on store change, store does not dispatch previously removed effects', function()
        local init_data_set = function()
          pub_map = get_init_pub_map()

          local effects = {}
          local effect_values = { 0, 0, 0 }

          for i = 1, 3 do
            effects[i] = Effect:new(function()
              effect_values[i] = effect_values[i] + 1
            end)
          end

          pub_map.children.a.effects:add(effects[1])
          pub_map.children.a.children.b.effects:add(effects[2])
          pub_map.children.a.children.b.children.c.effects:add(effects[3])

          return effect_values
        end

        local effect_values = init_data_set()

        helper.dispatch_and_remove_children(pub_map.children.a.children.b.children.c)
        helper.dispatch_and_remove_children(pub_map.children.a.children.b)
        helper.dispatch_and_remove_children(pub_map.children.a)

        assert.same({ 1, 2, 2 }, effect_values)
      end)
    end)
  end)
end)
