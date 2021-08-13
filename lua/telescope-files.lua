-- Fall back to find_files if git_files doesn't find .git; based on
-- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#falling-back-to-find_files-if-git_files-cant-find-a-git-directory
--

local T = require('telescope.builtin')
local dropdown = require('telescope.themes').get_dropdown({ previewer = false })

return {
    project_files = function()
        if not pcall(T.git_files, dropdown) then
            T.find_files(dropdown)
        end
    end
}
