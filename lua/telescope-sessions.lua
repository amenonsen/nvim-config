-- Display a picker with the :mksessions saved by folke/persistence.nvim

local T = require('telescope.builtin')
local dir = require('persistence.config').options.dir
local dropdown = require('telescope.themes').get_dropdown({
    prompt_title = "Sessions",
    previewer = false,
    search_dirs = { dir },
    entry_maker = function(entry)
        local short = entry:gsub(dir,''):gsub('.vim$',''):gsub('%%','/')
        return {
            value = entry,
            ordinal = entry,
            display = short,
        }
    end,
    attach_mappings = function(prompt_bufnr, map)
        local actions = require "telescope.actions"
        local actions_state = require "telescope.actions.state";
        actions.select_default:replace(function()
            local selection = actions_state.get_selected_entry()
            actions.close(prompt_bufnr)
            vim.cmd("source " .. selection['value']:gsub('%%','\\%%'))
        end)
        return true
    end
})

return {
    sessions = function()
        T.find_files(dropdown)
    end
}
