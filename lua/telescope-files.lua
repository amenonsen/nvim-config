-- Fall back to find_files if git_files doesn't find .git; based on
-- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#falling-back-to-find_files-if-git_files-cant-find-a-git-directory
--

return {
    project_files = function()
        if not pcall(require('telescope.builtin').git_files, {}) then
            require('telescope.builtin').find_files({})
        end
    end
}
