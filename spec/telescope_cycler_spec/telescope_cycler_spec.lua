describe("telescope_cycler", function()
    local actions
    local match
    local stub
    local telescope_cycler
    local cycler
    local picker_stubs
    local picker_opts
    local close_action
    local notify

    setup(function()
        match = require("luassert.match")
        stub = require("luassert.stub")
        telescope_cycler = require("telescope_cycler")
        actions = require("telescope.actions")
        require("spec.helpers")
    end)

    before_each(function()
        close_action = stub.new(actions, "close")
        notify = stub(vim, "notify")

        picker_stubs = {
            stub.new(),
            stub.new(),
            stub.new(),
            stub.new(),
        }
        picker_opts = {
            { picker_opts = "picker1" },
            { picker_opts = "picker2" },
            { picker_opts = "picker3", attach_mappings = stub.new() },
            { picker_opts = "picker4" },
        }


        cycler = telescope_cycler:new {
            pickers = {
                {
                    name = "picker1",
                    picker = function(opts) picker_stubs[1](opts) end,
                    opts = picker_opts[1]
                },
                {
                    name = "picker2",
                    picker = function(opts) picker_stubs[2](opts) end,
                    opts = picker_opts[2]
                },
                {
                    name = "picker3",
                    picker = function(opts) picker_stubs[3](opts) end,
                    opts = picker_opts[3]
                },
                {
                    name = "picker4",
                    picker = function(opts) picker_stubs[4](opts) end,
                    opts = picker_opts[4]
                },
            }
        }
    end)

    after_each(function()
        cycler = nil
        close_action:revert()
        notify:revert()
    end)

    it("SHOULD call the first picker by default", function()
        cycler()

        assert.stub(picker_stubs[1]).was_called_with(match.table_containing(picker_opts[1]))
    end)

    it("SHOULD call the named picker", function()
        cycler("picker2")

        assert.stub(picker_stubs[2]).was_called_with(match.table_containing(picker_opts[2]))
    end)

    it("SHOULD log an error if called with an unknown picker", function()
        cycler("unknown")

        assert.stub(notify).was_called_with("Unknown picker: unknown", vim.log.levels.ERROR)
    end)

    describe("attach_mappings", function()
        it("SHOULD add mappings to the picker", function()
            local map = stub.new()
            local prompt_bufnr = 1

            cycler()
            local opts = picker_stubs[1].calls[1].refs[1]

            opts.attach_mappings(prompt_bufnr, map)

            assert.stub(map).was_called_with({ "i", "n" }, "<C-l>", match.is_function(), { desc = "cycle to next picker" })
            assert.stub(map).was_called_with({ "i", "n" }, "<C-h>", match.is_function(), { desc = "cycle to previous picker" })
        end)

        it("SHOULD return true", function()
            cycler()
            local opts = picker_stubs[1].calls[1].refs[1]
            local prompt_bufnr = 1

            local ret = opts.attach_mappings(prompt_bufnr, function(...) end)

            assert.is_true(ret)
        end)

        it("SHOULD call the original 'attach_mappings'", function()
            local map = function() end
            local prompt_bufnr = 1

            cycler("picker3")
            local opts = picker_stubs[3].calls[1].refs[1]

            opts.attach_mappings(prompt_bufnr, map)

            assert.stub(picker_opts[3].attach_mappings).was_called_with(prompt_bufnr, map)
        end)

        it("SHOULD return the same value as the original 'attach_mappings'", function()
            local prompt_bufnr = 1

            cycler("picker3")
            picker_opts[3].attach_mappings.returns(false)
            local opts = picker_stubs[3].calls[1].refs[1]

            local ret = opts.attach_mappings(prompt_bufnr, function() end)

            assert.is_false(ret)
        end)

        describe("next action", function()
            it("SHOULD call the next picker", function()
                local map = stub.new()
                local prompt_bufnr = 1

                cycler()
                local opts = picker_stubs[1].calls[1].refs[1]
                opts.attach_mappings(prompt_bufnr, map)
                local next_action = map.calls[1].refs[3]

                next_action(prompt_bufnr)

                assert.stub(picker_stubs[2]).was_called_with(match.table_containing(picker_opts[2]))
            end)


            it("SHOULD wrap when calling next", function()
                local map = stub.new()
                local prompt_bufnr = 1

                cycler("picker4")
                local opts = picker_stubs[4].calls[1].refs[1]
                opts.attach_mappings(prompt_bufnr, map)
                local next_action = map.calls[1].refs[3]

                next_action(prompt_bufnr)

                assert.stub(picker_stubs[1]).was_called_with(match.table_containing(picker_opts[1]))
            end)

            it("SHOULD call the close action", function()
                local map = stub.new()
                local prompt_bufnr = 1

                cycler("picker2")
                local opts = picker_stubs[2].calls[1].refs[1]
                opts.attach_mappings(prompt_bufnr, map)
                local next_action = map.calls[1].refs[3]

                next_action(prompt_bufnr)

                assert.stub(close_action).was_called_with(prompt_bufnr)
            end)
        end)

        describe("prev action", function()
            it("SHOULD call the previous picker", function()
                local map = stub.new()
                local prompt_bufnr = 1

                cycler("picker2")
                local opts = picker_stubs[2].calls[1].refs[1]
                opts.attach_mappings(prompt_bufnr, map)
                local prev_action = map.calls[2].refs[3]

                prev_action(prompt_bufnr)

                assert.stub(picker_stubs[1]).was_called_with(match.table_containing(picker_opts[1]))
            end)

            it("SHOULD wrap when calling prev", function()
                local map = stub.new()
                local prompt_bufnr = 1

                cycler("picker1")
                local opts = picker_stubs[1].calls[1].refs[1]
                opts.attach_mappings(prompt_bufnr, map)
                local prev_action = map.calls[2].refs[3]

                prev_action(prompt_bufnr)

                assert.stub(picker_stubs[4]).was_called_with(match.table_containing(picker_opts[4]))
            end)

            it("SHOULD call the close action", function()
                local map = stub.new()
                local prompt_bufnr = 1

                cycler("picker2")
                local opts = picker_stubs[2].calls[1].refs[1]
                opts.attach_mappings(prompt_bufnr, map)
                local prev_action = map.calls[2].refs[3]

                prev_action(prompt_bufnr)

                assert.stub(close_action).was_called_with(prompt_bufnr)
            end)
        end)

    end)
end)
