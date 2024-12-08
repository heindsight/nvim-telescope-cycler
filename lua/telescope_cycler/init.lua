-- Telescope Cycler
--
-- Cycle through telescope.nvim picker_cfgs.
--
-- This module provides a way to cycle through a list of telescope picker_cfgs. It sets telescope key mappings to
-- switch to the next (default: <C-l>) or previous (default <C-h>) picker in the list.
--
-- Example:
--
--  ```lua
--  local telescope_builtin = require('telescope.builtin')
--  local telescope_cycler = require("telescope_cycler")
--  local cycler = telescope_cycler.new({
--      {
--          { name = "Find files",   picker = telescope_builtin.find_files, opts = { hidden = true } },
--          { name = "Buffers",      picker = telescope_builtin.buffers },
--          { name = "Recent files", picker = telescope_builtin.oldfiles },
--          { name = "Live grep",    picker = telescope_builtin.live_grep },
--      },
--      { next = "<C-l>", prev = "<C-h>" },
--  })

--  vim.keymap.set('n', '<leader>f', cycler, { desc = 'Telescope' })
--  ```

local actions = require("telescope.actions")

local M = {}


-- Create a new Telescope Cycler instance
--
-- Parameters:
--      {picker_cfgs} (table[]) A list of picker configurations to cycle through. Each should have the following fields:
--          - {name} (string) A name to identify the picker
--          - {picker} (function) A function to launch the picker
--          - {opts} (table?) Options to pass to the picker
--      {mappings} (table?) Keys to map to cycle to next/previous picker:
--          - {next} (string?) Key to map to cycle to the next picker (default: <C-l>)
--          - {prev} (string?) Key to map to cycle to the previous picker (default: <C-h>)
--          Note that the same keys are mapped in both normal and insert mode.
--
--  Return:
--      (function(name: string?)) function to launch a picker. Accepts an optional name parameter
--      to launch a specific picker, otherwise the first picker in the `picker_cfgs` list will be used.
function M.new(picker_cfgs, mappings)
    vim.validate({
        picker_cfgs = { picker_cfgs, "table" },
        mappings = { mappings, "table", true },
    })
    for _, picker_cfg in ipairs(picker_cfgs) do
        vim.validate({
            name = { picker_cfg.name, "string" },
            picker = { picker_cfg.picker, "function" },
            opts = { picker_cfg.opts, "table", true },
        })
    end

    mappings = vim.tbl_extend("force", { next = "<C-l>", prev = "<C-h>" }, mappings or {})
    vim.validate({
        next = { mappings.next, "string" },
        prev = { mappings.prev, "string" },
    })

    local pickers = {}
    local default_picker = picker_cfgs[1].name

    local function launch_picker(name)
        name = name or default_picker

        local picker_cfg = pickers[name]
        if picker_cfg == nil then
            vim.notify("Unknown picker: " .. name, vim.log.levels.ERROR)
            return
        end

        picker_cfg.picker(picker_cfg.opts)
    end

    for i, picker_cfg in ipairs(picker_cfgs) do
        local next = picker_cfgs[i + 1] or picker_cfgs[1]
        local prev = picker_cfgs[i - 1] or picker_cfgs[#picker_cfgs]
        local opts = picker_cfg.opts or {}
        local orig_attach_mappings = opts.attach_mappings

        pickers[picker_cfg.name] = {
            name = picker_cfg.name,
            picker = picker_cfg.picker,
            opts = vim.deepcopy(opts),
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


return M
