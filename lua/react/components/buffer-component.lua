local core = require('react.core')

local create_effect = core.create_effect

local M = {}

function M:new(args)
    assert(args.component, [[A component should be passed
        Ex:-
        local function App()
            return {
                'Hello World'
            }
        end

        local function on_change(changed_range, updated_content)
            -- do something
        end
        
        local Component = require('react.component')

        Component:new({
            component = App,
            subscriber = on_change
        })
    ]])

    local o = {
        node = args.component,
        subscriber = args.subscriber,
        components = {},
        text = '',
    }

    setmetatable(o, self)
    self.__index = self

    local init = nil

    -- Render the component for the first time without dispatching any changed
    -- events for the first time
    init = function()
        o:__init_component()

        init = function()
            local prev_text = o:get_text()

            o:__init_component()

            -- dispatch change event to parent
            o:__dispatch_update(o:get_text_range(prev_text), o.text)
        end
    end

    create_effect(function()
        init()
    end)

    return o
end

function M:__init_component()
    -- remove prev subscriptions to children and text
    self:__release_components()

    local nodes = self.node()

    for index, node in ipairs(nodes) do
        -- IF the current node is a function, then initialize component wrapper
        -- around it and store the text
        if type(node) == 'function' then
            local component = M:new({
                component = node,
                -- __get_notify_callback returns a callback that notify the
                -- parent of the current component with the updated range
                -- relative to the current component
                subscriber = self:__get_notify_callback(index)
            })

            table.insert(self.components, component)

            self.text = self.text .. component:get_text()

            -- IF the current node is a text, get the text as it is
        elseif type(node) == 'string' then
            table.insert(self.components, node)

            self.text = self.text .. node
        end
    end
end

-- Removes all subscriptions to children components and previous rendered text
function M:__release_components()
    if #self.components < 1 then return end

    for _, component in ipairs(self.components) do
        if type(component) == "table" then
            component:remove_subscriber()
        end
    end

    self.components = {}
    self.text = ''
end

-- Returns the text of the current component
function M:get_text()
    return self.text
end

-- Returns the range of text
function M:get_text_range(text)
    local row_end = 0
    local after_last_newline_idx = 0

    for idx in text:gmatch "\n()" do
        row_end = row_end + 1
        -- idx is the next character after a new line
        after_last_newline_idx = (idx - 1)
    end

    return {
        row_start = 0,
        col_start = 0,
        row_end = row_end,
        col_end = #text - after_last_newline_idx
    }
end

-- Calculates the given range (of a child) relative to the current component
function M:get_relative_clild_range(id, child_range)
    local text = ''

    for index = 1, (id - 1), 1 do
        local component = self.components[index]

        if type(component) == 'string' then
            text = text .. component
        elseif type(component) == 'table' then
            text = text .. component:get_text()
        end
    end

    local range = self:get_text_range(text)

    local new_range = {
        row_start = range.row_end,
        col_start = range.col_end,
        row_end = range.row_end + child_range.row_end,
        col_end = child_range.col_end
    }

    if range.row_end == new_range.row_end then
        new_range.col_end = range.col_end + child_range.col_end
    end

    return new_range
end

-- Dispatch a re-render update to parent node
function M:__dispatch_update(range, text)
    if self.subscriber then
        self.subscriber(range, text)
    end
end

-- Returns a function that has the context of the child that is notifying
-- current component
function M:__get_notify_callback(id)
    local this = self

    return function(range, text)
        local new_range = this:get_relative_clild_range(id, range)

        if this.subscriber then
            this.subscriber(new_range, text)
        end
    end
end

-- Remove the subscriber from the component
function M:remove_subscriber()
    self.subscriber = nil
end

return M
