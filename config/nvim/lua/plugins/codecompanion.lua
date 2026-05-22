return {
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("codecompanion").setup({
                adapters = {
                    openai = function()
                        return require("codecompanion.adapters").extend("openai", {
                            env = {
                                api_key = "cmd:echo $OPENAI_API_KEY",
                            },
                            schema = {
                                model = {
                                    default = "gpt-4o-mini", -- Specify GPT-4o-mini model
                                },
                            },
                        })
                    end,
                },
                strategies = {
                    chat = {
                        adapter = "openai", -- Use OpenAI for chat
                    },
                    inline = {
                        adapter = "openai", -- Use OpenAI for inline completions
                    },
                },
            })
        end,
    },
}
