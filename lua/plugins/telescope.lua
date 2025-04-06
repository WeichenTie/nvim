return {
	"nvim-telescope/telescope.nvim",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local transform_mod = require("telescope.actions.mt").transform_mod
		local finders = require("telescope.finders")
		local pickers = require("telescope.pickers")
		local sorters = require("telescope.sorters")
		local trouble = require("trouble")
		local trouble_telescope = require("trouble.sources.telescope")

		-- or create your custom action
		local custom_actions = transform_mod({
			open_trouble_qflist = function(prompt_bufnr)
				trouble.toggle("quickfix")
			end,
		})

		telescope.setup({
			defaults = {
				path_display = { "smart" },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
						["<C-t>"] = trouble_telescope.open,
					},
				},
			},
		})

		telescope.load_extension("fzf")

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>ps", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })

		-- Define the `fg` command
		local function git_changed_files()
			local handle = io.popen(
				"git diff --name-only HEAD~ && git ls-files --others --exclude-standard && git diff --name-only --cached"
			)
			if handle == nil then
				return {}
			end
			local result = {}
			for line in handle:lines() do
				if not vim.tbl_contains(result, line) then
					table.insert(result, line)
				end
			end
			handle:close()
			return result
		end

		keymap.set("n", "<leader>fg", function()
			local files = git_changed_files()
			pickers
				.new({}, {
					prompt_title = "Git Changed + Untracked Files",
					finder = finders.new_table({
						results = files,
					}),
					sorter = sorters.get_fuzzy_file(),
					previewer = require("telescope.previewers").vim_buffer_cat.new({}),
				})
				:find()
		end, { desc = "Find git modified, added, and untracked files" })
	end,
}
