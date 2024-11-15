local assert = require("luassert")
local assert_util = require "luassert.util"

-- Match an argument table that is a superset of the given table.
local function table_containing(_, arguments)
    local expected = arguments[1]

    return function(value)
        if type(value) ~= "table" then
            return false
        end

        for expected_key, expected_val in pairs(expected) do
            if not assert_util.deepcompare(value[expected_key], expected_val) then
                return false
            end
        end

        return true
    end
end

assert:register("matcher", "table_containing", table_containing)
