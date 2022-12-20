local core = require('react.core')

local create_signal = core.create_signal
local create_effect = core.create_effect

describe('core::', function()
    describe('signal::', function()
        it('correctly sets initial value', function()
            local num = create_signal(10)
            local str = create_signal('hello world')
            local bool = create_signal(true)
            local tbl = create_signal({ name = 's1n7ax' })

            assert.are.same(10, num())
            assert.are.same('hello world', str())
            assert.are.same(true, bool())
            assert.are.same({ name = 's1n7ax' }, tbl())
        end)

        it('correctly changes the existing value', function()
            local signal, set_signal = create_signal(10)
            assert.are.same(10, signal())

            set_signal('hello world')
            assert.are.same('hello world', signal())

            set_signal(true)
            assert.are.same(true, signal())

            set_signal({ name = 's1n7ax' })
            assert.are.same({ name = 's1n7ax' }, signal())
        end)

        it('signal change re-call effect', function()
            local signal, set_signal = create_signal(10)
            local current_value = nil

            create_effect(function()
                current_value = signal()
            end)

            assert.are.same(10, current_value)

            set_signal('hello world')
            assert.are.same('hello world', current_value)

            set_signal(true)
            assert.are.same(true, current_value)

            set_signal({ name = 's1n7ax' })
            assert.are.same({ name = 's1n7ax' }, current_value)
        end)

        it('signal can not be created within an effect', function()
            create_effect(function()
                assert.has_error(function()
                    local _, _ = create_signal(10)
                end)
            end)

            create_effect(function()
                assert.error_matches(function()
                    local _, _ = create_signal(10)
                end, 'You should not create signals or stores within an effect or component')
            end)
        end)
    end)

    describe('effect::', function()
        it('signal only triggers the effect that uses the signal', function()
            local signal1, set_signal1 = create_signal(10)
            local signal2 = create_signal(10)

            local signal1_value = nil
            local signal2_value = nil

            create_effect(function()
                signal1_value = signal1()
            end)

            create_effect(function()
                signal2_value = signal2()
            end)

            set_signal1('hello world')

            assert.are.same(signal1_value, 'hello world')
            assert.are.same(signal2_value, 10)
        end)

        it('signal only triggers the effect that uses the signal when nested', function()
            local signal1, set_signal1 = create_signal(10)
            local signal2, set_signal2 = create_signal(20)
            local signal3, set_signal3 = create_signal(30)

            local curr_signal1 = nil
            local curr_signal2 = nil
            local curr_signal3 = nil

            create_effect(function()
                curr_signal1 = signal1()

                create_effect(function()
                    curr_signal2 = signal2()

                    create_effect(function()
                        curr_signal3 = signal3()
                    end)
                end)
            end)

            assert.are.same(10, curr_signal1)
            assert.are.same(20, curr_signal2)
            assert.are.same(30, curr_signal3)

            set_signal3(signal3() + 1)
            assert.are.same(31, curr_signal3)

            set_signal2(signal2() + 1)
            assert.are.same(21, curr_signal2)

            set_signal1(signal1() + 1)
            assert.are.same(11, curr_signal1)
        end)
    end)
end)
