local Effect = require('react.core.effect')
local Signal = require('react.core.signal')

describe('signal::', function()
    it('Throws when initialized inside effect', function()
        local effect = Effect:new(function()
            assert.has_error(function()
                Signal:new(0)
            end)
        end)

        effect:dispatch()
    end)

    it('Readable & writeable outside of effects', function()
        local signal = Signal:new(10)

        assert.equal(10, signal:read())

        signal:write(20)
        assert.equal(20, signal:read())

        assert.equal(0, signal.publisher:length())
    end)

    it('Multiple signal reads in same effect should only register once', function()
        local signal = Signal:new(10)

        local effect = Effect:new(function()
            signal:read()
            signal:read()
            signal:read()
        end)

        effect:dispatch()
        assert.equal(1, signal.publisher:length())
    end)

    it('After unsubscribe, effect should be removed from signal', function()
        local signal1 = Signal:new(10)
        local signal2 = Signal:new(10)

        local effect = Effect:new(function()
            signal1:read()
            signal2:read()
        end)

        effect:dispatch()

        assert.equal(1, signal1.publisher:length())
        assert.equal(1, signal2.publisher:length())

        effect:unsubscribe_signals()
        assert.equal(0, signal1.publisher:length())
        assert.equal(0, signal2.publisher:length())
    end)
end)
