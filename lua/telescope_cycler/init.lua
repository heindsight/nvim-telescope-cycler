local actions = require("telescope.actions")

local TCycler = {}

--- Create a new Telescope Cycler instance
--
-- @param params (table) cycler config
-- @field pickers: (table[]) [[ A list of picker configurations to cycle through.
--  Each element should be a table with the following fields:
--    name: (string) a name to identify a picker,
--    picker: (function) a function to launch the picker,
--    opts: (table?) options to pass to the picker (default: {}),
-- ]]
-- @field mappings: (table?) [[ Keys to map to cycle to next/previous pickers:
--    next: (string) key to map to cycle to the next picker (default: '<C-l>'),
--    prev: (string) key to map to cycle to the previous picker (default: '<C-h>'),
-- ]]
-- @return (function(string?):any) [[ a function that will launch a picker identified by name
--  (or the first picker if no name is provided)
-- ]]
function TCycler.new(params)
    params = params or {}
    vim.validate({
        pickers = { params.pickers, "table" },
        mappings = { params.mappings, "table", true },
    })
    for _, picker_cfg in ipairs(params.pickers) do
        vim.validate({
            name = { picker_cfg.name, "string" },
            picker = { picker_cfg.picker, "function" },
            opts = { picker_cfg.opts, "table", true },
        })
    end

    local mappings = vim.tbl_extend("force", { next = "<C-l>", prev = "<C-h>" }, params.mappings or {})
    vim.validate({
        next = { mappings.next, "string" },
        prev = { mappings.prev, "string" },
    })

    local pickers = {}

    local function launch_picker(name)
        name = name or params.pickers[1].name

        local picker_cfg = pickers[name]
        if picker_cfg == nil then
            vim.notify("Unknown picker: " .. name, vim.log.levels.ERROR)
            return
        end

        return picker_cfg.picker(picker_cfg.opts)
    end

    for i, picker_cfg in ipairs(params.pickers) do
        local next = params.pickers[i + 1] or params.pickers[1]
        local prev = params.pickers[i - 1] or params.pickers[#params.pickers]
        local orig_attach_mappings = picker_cfg.opts.attach_mappings

        pickers[picker_cfg.name] = {
            name = picker_cfg.name,
            picker = picker_cfg.picker,
            opts = vim.deepcopy(picker_cfg.opts or {}),
        }

        pickers[picker_cfg.name].opts.attach_mappings = function(prompt_bufnr, map)
            map({ "i", "n" }, mappings.next, function(bufnr)
                actions.close(bufnr)
                launch_picker(next.name)
            end, { desc = "cycle to next picker" })
            map({ "i", "n" }, mappings.prev, function(bufnr)
                actions.close(bufnr)
                launch_picker(prev.name)
            end, { desc = "cycle to previous picker" })
            if orig_attach_mappings then
                return orig_attach_mappings(prompt_bufnr, map)
            end
            return true
        end
    end

    return launch_picker
end

return TCycler
