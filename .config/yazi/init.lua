require("copy-file-to-clipboard"):setup({
	append_char = "\n",
	notification = true,
})

require("back-cwd"):setup({
	start_dir = os.getenv("PWD"),
})

require("git"):setup()

require("full-border"):setup()
