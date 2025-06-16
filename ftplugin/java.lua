local jdtls_config = {

	cmd = {
		vim.fn.expand("~/.local/share/nvim/mason/bin/jdtls"),
		("--jvm-arg=-javaagent:%s"):format(vim.fn.expand("~/.local/share/nvim/mason/packages/jdtls/lombok.jar")),
	},

	root_dir = vim.fs.dirname(vim.fs.find({ "gradlew", ".git", "mvnw" }, { upward = true })[1]),

	init_options = {
		bundles = {
			vim.fn.glob(
				"/Users/nickgermanos/Developer/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar"
			),
		},
	},

	on_attach = function()
		require("jdtls").setup_dap({ hotcodereplace = "auto", config_overrides = {} })
	end,
}

local dap = require("dap")
local dapui = require("dapui")

dap.listeners.before.attach.dapui_config = function()
	dapui.open()
	dapui.float_element("console", { width = 300, height = 70, position = "center", enter = true, title = "Console" })
end
dap.listeners.before.launch.dapui_config = function()
	dapui.open()
	dapui.float_element("console", { width = 300, height = 70, position = "center", enter = true, title = "Console" })
end
dap.listeners.before.event_terminated.dapui_config = function()
	dapui.close()
end

dap.configurations.java = {
	{
		type = "java",
		request = "attach",
		name = "Debug (Attach) to Wealth Central",
		host = "127.0.0.1",
		port = 51416,
	},
	{
		name = "SpringbootBackendApplication",
		type = "java",
		request = "launch",
		mainClass = "com.nickblogsite.springboot_backend.SpringbootBackendApplication",
		vmArgs = "-Xmx2g",
	},
}

require("jdtls").start_or_attach(jdtls_config)
