local Effect = require('react.core.effect')
local Signal = require('react.core.signal')

describe('effect::', function()
    it('Throws when callback if not passed', function()
        assert.has_error(function()
            Effect:new('hello')
        end)

        assert.has_error(function()
            Effect:new()
        end)

        assert.error_matches(function()
            Effect:new()
        end, 'Callback function should be passed to effect')
    end)

    it('Callback runs on dispatch', function()
        local got_callback = false

        local effect = Effect:new(function()
            got_callback = true
        end)

        effect:dispatch()

        assert.equal(true, got_callback)
    end)

    it('Adds signal to the effect on use', function()
        local signal1 = Signal:new()
        local signal2 = Signal:new()

        local effect = Effect:new(function()
            signal1:read()
            signal2:read()
        end)

        effect:dispatch()

        assert.equal(2, effect.signals:length())
        assert.equal(signal1, effect.signals:get(1))
        assert.equal(signal2, effect.signals:get(2))
    end)

    it('Unsubscribes signals', function ()
        local signal1 = Signal:new()
        local signal2 = Signal:new()
        local signal3 = Signal:new()

        local effect = Effect:new(function()
            signal1:read()
            signal2:read()
            signal3:read()
        end)

        effect:dispatch()

        assert.equal(3, effect.signals:length())

        effect:unsubscribe_signals()
        assert.equal(0, effect.signals:length())
    end)
end)
