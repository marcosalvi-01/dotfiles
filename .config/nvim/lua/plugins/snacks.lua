return {
	"folke/snacks.nvim",
	priority = 900,
	lazy = false,
	---@type snacks.Config
	opts = {
		dashboard = {
			width = 60,

			sections = {
				{ section = "header", padding = 4 },
				{
					section = "terminal",
					cmd = [[
fortune -n 250 -s | awk -v C="$(tput cols)" '
  { lines[NR] = $0; if (length > max) max = length }
  END {
    ind = int((C - max) / 2); if (ind < 0) ind = 0
    for (i = 1; i <= NR; i++)
      printf("%*s%s\n", ind, "", lines[i])
  }'
				]],
					hl = "file",
					height = 4,
					ttl = 0,
					width = 80,
					indent = -10,
					padding = 5,
				},
				{
					section = "terminal",
					cmd = [[
#!/bin/bash

# Gruvbox color palette
FG='\033[38;2;212;190;152m'     # fg: #d4be98 (base foreground)
GRAY='\033[38;2;168;153;132m'   # accent.gray: #a89984
BLUE='\033[38;2;125;174;163m'   # accent.blue: #7daea3
GREEN='\033[38;2;142;192;124m'  # accent.green: #8ec07c
YELLOW='\033[38;2;216;166;87m'  # accent.yellow: #d8a657
PURPLE='\033[38;2;211;134;155m' # accent.purple: #d3869b
RED='\033[38;2;234;105;98m'     # accent.red: #ea6962
RESET='\033[0m'

# Build the colorized output
branch_info="${BLUE}󰘬 $(git branch --show-current)${RESET}"

# Check for remote changes (commits to pull/push)
current_branch=$(git branch --show-current)
upstream_branch=$(git rev-parse --abbrev-ref @{upstream} 2>/dev/null)
pull_indicator=""
push_indicator=""

if [ -n "$upstream_branch" ]; then
    # Fetch remote updates silently
    git fetch --quiet 2>/dev/null || true
    
    # Count commits behind (to pull)
    commits_behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null || echo "0")
    
    if [ "$commits_behind" -gt 0 ]; then
        pull_indicator=" ${GRAY}⇣ ${commits_behind}${RESET}"
    fi
    
    # Count commits ahead (to push)
    commits_ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo "0")
    
    if [ "$commits_ahead" -gt 0 ]; then
        push_indicator=" ${PURPLE}⇡ ${commits_ahead}${RESET}"
    fi
fi

git_stats=$(git status --porcelain | awk '
BEGIN{m=0;a=0;d=0;r=0;u=0} 
/^.M|^M./{m++} 
/^A.|^.A/{a++} 
/^.D|^D./{d++} 
/^R./{r++} 
/^\?\?/{u++} 
END{printf " %d  %d  %d  %d  %d", m,a,d,r,u}')

# Parse the stats and colorize each part
IFS=' ' read -r modified added deleted renamed untracked <<< "$git_stats"
colorized_stats="${YELLOW} ${modified}${RESET} ${GREEN} ${added}${RESET} ${RED} ${deleted}${RESET} ${PURPLE} ${renamed}${RESET} ${GRAY}? ${untracked}${RESET}"

commit_msg="${BLUE} '$(git log --oneline -1 --pretty=format:'%s')'${RESET}"

# Combine all parts (including pull/push indicators if present)
indicators="${pull_indicator}${push_indicator}"
if [ -n "$indicators" ]; then
    output="${branch_info}${indicators} ${FG}|${RESET} ${colorized_stats} ${FG}|${RESET} ${commit_msg}"
else
    output="${branch_info} ${FG}|${RESET} ${colorized_stats} ${FG}|${RESET} ${commit_msg}"
fi

# Calculate terminal width and center the output
# Strip ANSI codes to get actual character length for proper centering
clean_output=$(echo -e "$output" | sed 's/\x1b\[[0-9;]*m//g')
output_length=${#clean_output}
terminal_width=$(tput cols)

# Center the output
if [ $output_length -lt $terminal_width ]; then
    padding=$(((terminal_width - output_length) / 2))
    printf "%*s%s\n" "$padding" "" "$(echo -e "$output")"
else
    echo -e "$output"
fi
				]],
					hl = "file",
					ttl = 0,
					width = 80,
					indent = -10,
					height = 3,
				},
				{
					pane = 2,
					padding = 1,
				},
				{
					pane = 2,
					section = "keys",
					indent = 20,
					gap = 1,
					padding = 2,
				},
				{
					indent = 20,
					pane = 2,
					section = "startup",
					icon = "󱐋 ",
				},
			},
			autokeys = "neiatsrc",
			preset = {
				keys = {
					{
						icon = " ",
						key = "f",
						desc = "Find File",
						action = ":lua Snacks.picker.files({hidden = true, ignored = true})",
					},
					{
						icon = " ",
						key = "g",
						desc = "Find Text",
						action = ":lua Snacks.picker.grep({hidden = true, ignored = true})",
					},
					{ icon = " ", key = "y", desc = "Yazi", action = "<cmd>Yazi<cr>" },
					{ icon = " ", key = "o", desc = "Last Buffer", action = "<cmd>normal <c-o><c-o><cr>" },
					{ icon = "󰘬 ", key = "n", desc = "Neogit", action = "<cmd>Neogit kind=tab<cr>" },
					{
						icon = "󰒲 ",
						key = "l",
						desc = "Lazy",
						action = ":Lazy",
						enabled = package.loaded.lazy ~= nil,
					},
					{
						icon = "󰏗 ",
						key = "m",
						desc = "Mason",
						action = ":Mason",
						enabled = package.loaded.lazy ~= nil,
					},
					-- { icon = "󰑓 ", key = "r", desc = "Reload", action = ":lua Snacks.dashboard.update()" },
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
				header = [[
██╗   ██╗███████╗ ██████╗ ██╗   ███╗██╗███╗   ███╗
██║   ██║╚═══╗██║██╔═══██╗██║  ████║██║████╗ ████║
██║   ██║  █████║██║   ██║██║ ██╔██║██║██╔████╔██║
╚██╗ ██╔╝  ╚═╗██║██║   ██║██╚██╔╝██║██║██║╚██╔╝██║
 ╚████╔╝ ███████║╚██████╔╝████╔╝ ██║██║██║ ╚═╝ ██║
  ╚═══╝  ╚══════╝ ╚═════╝ ╚═══╝  ╚═╝╚═╝╚═╝     ╚═╝]],
			},
		},
		image = {},
		indent = {
			enabled = true,
			animate = {
				enabled = false,
			},
		},
		quickfile = { enabled = true },
		picker = {
			matcher = {
				frecency = true,
			},
			-- needed for the custom refine_dir action
			auto_close = false,
			layouts = {
				main_preview = {
					preview = "main",
					reverse = false,
					layout = {
						row = 0,
						width = 0.4,
						min_width = 80,
						height = 0.4,
						max_height = 10,
						title = "{title}",
						title_pos = "center",
						box = "vertical",
						border = "rounded",
						{
							win = "input",
							height = 1,
							border = "bottom",
						},
						{ win = "list", border = "none" },
						{ win = "preview", title = "{preview}", border = "none" },
					},
				},
			},
			sources = {
				-- custom picker for dirs
				dirs = {
					finder = "proc",
					cmd = "fd",
					args = { "--type", "d", "--hidden", "--exclude", ".git" },
					transform = function(item)
						item.file = item.text
						item.dir = true
					end,
				},
				select = {
					layout = {
						reverse = false,
						layout = {
							row = 1,
							width = 0.4,
							min_width = 80,
							height = 0.4,
							border = "rounded",
							box = "vertical",
							title = "{title}",
							title_pos = "center",
							{
								win = "input",
								height = 1,
								border = "bottom",
							},
							{ win = "list", border = "none" },
							{ win = "preview", title = "{preview}", border = "none" },
						},
					},
				},
			},
			prompt = " ",
			ui_select = true,
			layout = {
				reverse = true,
				layout = {
					box = "horizontal",
					width = 0.8,
					min_width = 120,
					min_height = 10,
					height = 0.8,
					{
						box = "horizontal",
						border = "rounded",
						title = "{title}",
						{
							box = "vertical",
							{ win = "list", border = "none" },
							{ win = "input", height = 1, border = "top" },
						},
						{ win = "preview", title = "{preview}", border = "left", width = 0.5 },
					},
				},
			},
			win = {
				input = {
					keys = {
						["<Esc>"] = { "close", mode = { "n", "i" } },
						["<C-s>"] = { "edit_vsplit", mode = { "i", "n" }, desc = "Vertical Split" },
						["<C-p>"] = { "toggle_preview", mode = "i" },
						["<C-right>"] = { "focus_preview", mode = "i" },
						["<PageUp>"] = { "preview_scroll_up", mode = "i" },
						["<PageDown>"] = { "preview_scroll_down", mode = "i" },
						["<C-u>"] = { "clear_input", mode = "i" },
						-- for some reason ctr+i does something else and this does not override it...
						-- ["<C-i>"] = { "toggle_hidden_and_ignored", mode = "i" },
						["<C-h>"] = { "toggle_hidden_and_ignored", mode = { "i" } },
						["<C-d>"] = { "refine_dir", mode = "i" },
						["<BS>"] = { "backspace", mode = "i" },
					},
					b = {
						minipairs_disable = true,
					},
				},
				preview = {
					keys = {
						["<C-left>"] = "focus_input",
						["<C-p>"] = "toggle_preview",
					},
				},
			},
			actions = {
				-- close the popup if the filter is empty on backspace
				backspace = function(p)
					local filter = p:filter()
					if filter.pattern == "" and filter.search == "" then
						p:close()
					else
						vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<bs>", true, true, true), "n", false)
					end
				end,
				toggle_hidden_and_ignored = function(p)
					p:action("toggle_hidden")
					p:action("toggle_ignored")
				end,
				delete_word = function()
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>", true, true, true), "i", false)
				end,
				clear_input = function(p)
					vim.api.nvim_win_call(p.input.win.win, function()
						vim.cmd('normal! "_cc')
					end)
				end,
				refine_dir = function(p)
					p:toggle()
					local newDir = nil
					Snacks.picker.dirs({
						confirm = function(picker, item)
							newDir = vim.fs.joinpath(vim.fn.getcwd(), item.file)
							picker:close()
							if item then
								p:set_cwd(newDir)
								p:find()
								p:focus()
								-- TODO: for some reason this does not put the cursor at the end of the line!
								vim.api.nvim_win_call(p.input.win.win, function()
									vim.cmd("normal A")
								end)
							end
						end,
						on_close = function()
							if not newDir then
								p:close()
							end
						end,
						title = "Refine Dir",
					})
				end,
			},
		},
	},
	keys = {
		{
			"<leader>sf",
			function()
				require("snacks").picker.files({
					hidden = true,
					ignored = true,
				})
			end,
			desc = "Snacks [S]earch [F]iles",
		},
		{
			"<leader>sp",
			function()
				Snacks.picker.files({ cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") })
			end,
			desc = "Snacks [S]earch [P]lugins",
		},
		{
			"<leader>sn",
			function()
				Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "Snacks [S]earch [C]onfig",
		},
		{
			"\\",
			function()
				Snacks.picker.lines({
					layout = "main_preview",
				})
			end,
			desc = "Snacks Search Lines In Buffer",
		},
		{
			"<leader>sg",
			function()
				Snacks.picker.grep({
					hidden = true,
					ignored = true,
				})
			end,
			desc = "Snacks [S]earch [G]rep",
		},
		{
			"<leader>sw",
			function()
				Snacks.picker.lines({
					search = function(picker)
						return picker:word()
					end,
					finder = "grep",
					regex = false,
					format = "file",
					layout = "main_preview",
				})
			end,
			desc = "Snacks [S]earch [W]ord",
			mode = "n",
		},
		{
			"<leader>sd",
			function()
				Snacks.picker.diagnostics({
					layout = "main_preview",
				})
			end,
			desc = "Snacks [S]earch [D]iagnostics",
		},
		{
			"<leader>sD",
			function()
				Snacks.picker.diagnostics_buffer({
					layout = "main_preview",
				})
			end,
			desc = "Snacks [S]earch Buffer [D]iagnostics",
		},
		{
			"<leader>sh",
			function()
				Snacks.picker.help()
			end,
			desc = "Snacks [S]earch [H]elp",
		},
		{
			"<leader>sk",
			function()
				Snacks.picker.keymaps()
			end,
			desc = "Snacks [S]earch [K]eymaps",
		},
		{
			"<leader>sm",
			function()
				Snacks.picker.marks({
					layout = {
						reverse = false,
					},
				})
			end,
			desc = "Snacks [S]earch [M]arks",
		},
		{
			"<leader>sM",
			function()
				Snacks.picker.man()
			end,
			desc = "Snacks [S]earch [M]an Pages",
		},
		{
			"<leader>sq",
			function()
				Snacks.picker.qflist({
					layout = "main_preview",
				})
			end,
			desc = "Snacks [S]earch [Q]uickfix",
		},
		{
			"<leader>sr",
			function()
				Snacks.picker.resume()
			end,
			desc = "Snacks [S]earch [R]esume",
		},
		{
			"gd",
			function()
				Snacks.picker.lsp_definitions({
					layout = "main_preview",
				})
			end,
			desc = "Snacks [G]oto [D]efinition",
		},
		{
			"gD",
			function()
				Snacks.picker.lsp_type_definitions({
					layout = "main_preview",
				})
			end,
			desc = "Snacks [G]oto Type [D]efinition",
		},
		{
			"gr",
			function()
				Snacks.picker.lsp_references({
					layout = "main_preview",
				})
			end,
			nowait = true,
			desc = "Snacks [G]oto [R]eferences",
		},
		{
			"gI",
			function()
				Snacks.picker.lsp_implementations({
					layout = "main_preview",
				})
			end,
			desc = "Snacks [G]oto [I]mplementation",
		},
		{
			"<leader>sl",
			function()
				Snacks.picker.lsp_symbols({
					layout = "main_preview",
				})
			end,
			desc = "Snacks [S]earch [L]sp symbols",
		},
		{
			"<leader>sL",
			function()
				Snacks.picker.lsp_workspace_symbols({
					layout = "main_preview",
				})
			end,
			desc = "Snacks [S]earch Workspace [L]sp symbols",
		},
		{
			"<leader>si",
			function()
				Snacks.picker.dirs()
			end,
			desc = "Snacks [S]earch D[I]rectories",
		},
		{
			"<leader>se",
			function()
				Snacks.picker.explorer({
					hidden = true,
					ignored = true,
					auto_close = true,
					on_show = function(picker)
						picker:action("toggle_preview")
					end,
					layout = {
						preview = "main",
						reverse = false,
						layout = {
							row = 1,
							width = 0.2,
							min_width = 60,
							height = 1,
							border = "rounded",
							box = "vertical",
							position = "left",
							title = "{title}",
							{
								win = "input",
								height = 1,
								border = "hpad",
							},
							{ win = "list", border = "top" },
							{ win = "preview", title = "{preview}", border = "none" },
						},
					},
					win = {
						input = {
							keys = {
								["<C-down>"] = { "focus_list", mode = "i" },
								["<C-right>"] = { "confirm", mode = "i" },
								["<C-p>"] = { "toggle_preview", mode = "i" },
							},
						},
						list = {
							keys = {
								["<BS>"] = "explorer_up",
								["<right>"] = "confirm",
								["<c-right>"] = "confirm",
								["<left>"] = "explorer_close",
								["a"] = "explorer_add",
								["d"] = "explorer_del",
								["r"] = "explorer_rename",
								["c"] = "explorer_copy",
								["m"] = "explorer_move",
								["o"] = "explorer_open",
								["p"] = "toggle_preview",
								["y"] = "explorer_yank",
								["u"] = "explorer_update",
								["<c-c>"] = "tcd",
								["."] = "explorer_focus",
								["I"] = "toggle_ignored",
								["H"] = "toggle_hidden",
								["Z"] = "explorer_close_all",
								["]g"] = "explorer_git_next",
								["[g"] = "explorer_git_prev",
								["]d"] = "explorer_diagnostic_next",
								["[d"] = "explorer_diagnostic_prev",
								["]w"] = "explorer_warn_next",
								["[w"] = "explorer_warn_prev",
								["]e"] = "explorer_error_next",
								["[e"] = "explorer_error_prev",
								["<C-up>"] = "focus_input",
								["<C-p>"] = "toggle_preview",
							},
						},
					},
				})
			end,
			desc = "Snacks [S]earch [E]xplorer",
		},
		{
			"<leader>ss",
			function()
				Snacks.picker.spelling()
			end,
			desc = "Snacks [S]earch [S]pelling",
		},
		{
			"<leader>hg",
			function()
				Snacks.picker.highlights()
			end,
			desc = "Snacks [H]i[G]hlights",
		},
		{
			"<leader>sb",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Snacks [S]earch open [B]uffers",
		},
	},
}
