
-- Customize None-ls sources

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, config)
    -- config variable is the default configuration table for the setup function call
    local h = require("null-ls.helpers")
    local methods = require("null-ls.methods")
    local DIAGNOSTICS = methods.internal.DIAGNOSTICS
    local diagnostics = h.diagnostics.from_pattern(
        "[^:]+:(%d+):  (.+)  %[(.+)%/(.+)%] %[%d+%]",
        { "row", "message", "severity", "label" },
        {
            severities = {
                build = h.diagnostics.severities["warning"],
                whitespace = h.diagnostics.severities["hint"],
                runtime = h.diagnostics.severities["warning"],
                legal = h.diagnostics.severities["information"],
                readability = h.diagnostics.severities["information"],
            },
        }
    )
    -- Check supported formatters and linters
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/formatting
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
    config.sources = {
--       Set a formatter
--       null_ls.builtins.formatting.stylua,
--       null_ls.builtins.formatting.prettier,
        h.make_builtin({
            name = "cpplint",
            meta = {
                url = "https://github.com/cpplint/cpplint",
                description = "Cpplint is a command-line tool to check C/C++ files for style issues following Google's C++ style guide",
            },
            method = DIAGNOSTICS,
            filetypes = { "cpp", "c" },
            generator_opts = {
                command = "cpplint",
                args = {
                    "$FILENAME",
                },
                format = "line",
                to_stdin = false,
                from_stderr = true,
                to_temp_file = true,
                on_output = function(line, params)
                    local rez = diagnostics(line, params)

                    if rez and rez.severity == 2 and (rez.label == "include_order" or rez.label == "header_guard") then
                        return nil
                    end

                    return rez
                end,
                check_exit_code = function(code)
                    return code >= 1
                end,
            },
            factory = h.generator_factory,
        })
    }
    return config -- return final config table
  end,
}
