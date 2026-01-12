require("copy-file-to-clipboard"):setup({
	append_char = "\n",
	notification = true,
})

require("back-cwd"):setup({
	start_dir = os.getenv("PWD"),
})

require("full-border"):setup()

require("session"):setup({
	sync_yanked = true,
})

require("git"):setup()
