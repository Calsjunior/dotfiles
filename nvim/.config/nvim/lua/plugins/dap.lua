return {
    {
        "jay-babu/mason-nvim-dap.nvim",
        opts = {
            handlers = {
                function(config)
                    require("mason-nvim-dap").default_setup(config)
                end,

                codelldb = function(config)
                    require("dap").adapters.codelldb = config.adapters
                end,
            },
        },
    },
    {
        "mfussenegger/nvim-dap",
        opts = function()
            local dap = require("dap")
            local dapui = require("dapui")

            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end

            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end

            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end

            dap.adapters["pwa-chrome"] = {
                type = "server",
                host = "localhost",
                port = "${port}",
                executable = {
                    command = "node",
                    args = {
                        vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
                        "${port}",
                    },
                },
            }

            dap.configurations.javascript = {
                {
                    type = "pwa-chrome",
                    request = "launch",
                    name = "Launch Chromium to debug frontend",
                    url = "http://localhost:8080",
                    webRoot = "${workspaceFolder}",
                    runtimeExecutable = "/usr/sbin/chromium",
                },
            }
            dap.configurations.typescript = dap.configurations.javascript

            dap.configurations.c = {
                {
                    name = "Launch and Debug C Executable",
                    type = "codelldb",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.expand("%:p:h") .. "/", "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                },
            }
            dap.configurations.cpp = dap.configurations.c
        end,
    },
}
