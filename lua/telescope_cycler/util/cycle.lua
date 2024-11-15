local Cycle = {}

function Cycle:new(values)
    local cycle = {
        _values = values,
        _index = 0,
    }
    return setmetatable(cycle, {__index = self})
end

function Cycle:skip_until(predicate)
    for i, v in ipairs(self._values) do
        if predicate(v) then
            self._index = i
            return v
        end
    end
end

function Cycle:next()
    self._index = self._index + 1
    if self._index > #self._values then
        self._index = 1
    end
    return self._values[self._index]
end

function Cycle:prev()
    self._index = self._index - 1
    if self._index < 1 then
        self._index = #self._values
    end
    return self._values[self._index]
end

return Cycle
