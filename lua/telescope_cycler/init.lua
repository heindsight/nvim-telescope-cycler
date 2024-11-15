local actions = require("telescope.actions")

local Cycle = require("telescope_cycler.util.cycle")

local TCycler = {}

-- Create a new Telescope Cycler instance
--
-- Params:
--  opts: (table) cycler config
--      - pickers: (table) Array of tables.
--          Each element contains:
--              - `name` a name to identify a picker,
--              - `picker` a function to launch the picker,
--              - `opts` options to pass to the picker (default: {}),
--      - mappings: (table) keys to map to cycle to next/previous pickers
--          (default: {next = '<C-l>', prev = '<C-h>'})
function TCycler:new(opts)
    opts = opts or {}
    vim.validate({
        pickers = { opts.pickers, "t" },
        mappings = { opts.mappings, "t", true },
    })
    for _, picker_cfg in ipairs(opts.pickers) do
        vim.validate({
            name = { picker_cfg.name, "string" },
            picker = { picker_cfg.picker, "function" },
            opts = { picker_cfg.opts, "table", true },
        })
    end

    opts.mappings = opts.mappings or {}

    local cycler = {
        _default = opts.pickers[1].name,
        _cycle = Cycle:new(opts.pickers),
        _mappings = {
            next = opts.mappings.next or "<C-l>",
            prev = opts.mappings.prev or "<C-h>",
        },
    }
    setmetatable(cycler, self)
    self.__index = self

    local function next_action(prompt_bufnr)
        actions.close(prompt_bufnr)
        local next_picker = cycler._cycle:next()
        next_picker.picker(next_picker.opts)
    end

    local function prev_action(prompt_bufnr)
        actions.close(prompt_bufnr)
        local prev_picker = cycler._cycle:prev()
        prev_picker.picker(prev_picker.opts)
    end

    for _, picker_cfg in ipairs(opts.pickers) do
        local orig_attach_mappings = picker_cfg.opts.attach_mappings

        picker_cfg.opts = vim.deepcopy(picker_cfg.opts or {})

        picker_cfg.opts.attach_mappings = function(prompt_bufnr, map)
            map({ "i", "n" }, cycler._mappings.next, next_action, { desc = "cycle to next picker" })
            map({ "i", "n" }, cycler._mappings.prev, prev_action, { desc = "cycle to previous picker" })
            if orig_attach_mappings then
                return orig_attach_mappings(prompt_bufnr, map)
            end
            return true
        end
    end

    return cycler
end

-- Call the picker with the given key
function TCycler:__call(key)
    key = key or self._default

    local picker_cfg = self._cycle:skip_until(function(v)
        return v.name == key
    end)
    if picker_cfg == nil then
        vim.notify("Unknown picker: " .. key, vim.log.levels.ERROR)
        return
    end

    return picker_cfg.picker(picker_cfg.opts)
end

return TCycler
