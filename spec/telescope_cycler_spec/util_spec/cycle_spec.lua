local cycle = require("telescope_cycler.util.cycle")

describe("Cycle", function()
    local cycler

    before_each(function()
        cycler = cycle:new({ 1, 2, 3 })
    end)

    after_each(function()
        cycler = nil
    end)

    it("SHOULD cycle forward through values", function()
        assert.are.same(1, cycler:next())
        assert.are.same(2, cycler:next())
        assert.are.same(3, cycler:next())
        assert.are.same(1, cycler:next())
        assert.are.same(2, cycler:next())
        assert.are.same(3, cycler:next())
    end)
    it("SHOULD cycle backward through values", function()
        assert.are.same(3, cycler:prev())
        assert.are.same(2, cycler:prev())
        assert.are.same(1, cycler:prev())
        assert.are.same(3, cycler:prev())
        assert.are.same(2, cycler:prev())
        assert.are.same(1, cycler:prev())
    end)
    describe("skip_until", function()
        it("SHOULD return the value if it is the first value", function()
            assert.are.same(
                1,
                cycler:skip_until(function(v)
                    return v == 1
                end)
            )
        end)
        it("SHOULD return the value if it is the last value", function()
            assert.are.same(
                3,
                cycler:skip_until(function(v)
                    return v == 3
                end)
            )
        end)
        it("SHOULD return the value if it is in the middle", function()
            assert.are.same(
                2,
                cycler:skip_until(function(v)
                    return v == 2
                end)
            )
        end)
        it("SHOULD return nil if the value is not found", function()
            assert.is_nil(cycler:skip_until(function(v)
                return v == 4
            end))
        end)
        it("SHOULD cycle normally after skipping", function()
            cycler:skip_until(function(v)
                return v == 2
            end)
            assert.are.same(3, cycler:next())
        end)
        it("SHOULD cycle normally after skipping to the last value", function()
            cycler:skip_until(function(v)
                return v == 3
            end)
            assert.are.same(1, cycler:next())
        end)
        it("SHOULD skip correctly after cycling", function()
            cycler:next()
            assert.are.same(
                1,
                cycler:skip_until(function(v)
                    return v == 1
                end)
            )
        end)
    end)
end)
