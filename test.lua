local function create_effect() end
local function create_signal(v) return v,3 end
local function component(c, props) end

local a, _ = create_signal(20)

function Child1(props)
    return {
        'first line' .. a(),
        'second line' .. props.name
    }
end

function Child2(props)
    return {
        'first line' .. a(),
        'second line' .. props.name
    }
end

function Parent()
    return {
        component(Child1, { name = 'Srinesh' }),
        component(Child2, { name = 'Srinesh' }),
        'something',
        'other',
    }
end

render(buffer, component(Parent))
