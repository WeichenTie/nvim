return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
        local fzf = require('fzf-lua')
        
        -- Setup configuration
        fzf.setup({
            defaults = {
                git_icons = false,
                file_icons = false,
                color_icons = false,
            },
            files = {
                fd_opts = "--hidden --exclude node_modules --exclude package-lock.json",
                hidden = true
            },
            grep = {
                rg_opts = "--hidden --column --line-number --no-heading " ..
                         "--color=always --smart-case --max-columns=512 " ..
                         "-g '!{node_modules,.git}/*' " ..
                         "-g '!package-lock.json'"
            }
        })

        -- Keymaps
        vim.keymap.set('n', '<leader>pf', fzf.files, {})
        vim.keymap.set('n', '<C-p>', fzf.git_files, {})
        vim.keymap.set('n', '<leader>pws', function()
            local word = vim.fn.expand("<cword>")
            fzf.live_grep_native({ search = word })
        end)
        vim.keymap.set('n', '<leader>pWs', function()
            local word = vim.fn.expand("<cWORD>")
            fzf.live_grep_native({ search = word })
        end)
        vim.keymap.set('n', '<leader>ps', function()
            fzf.live_grep_native({ prompt = "Rg > "})
        end)
        vim.keymap.set('n', '<leader>vh', fzf.help_tags, {})
    end
}