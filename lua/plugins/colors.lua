return {
  { "sainnhe/sonokai" },
  {
    "xiyaowong/transparent.nvim",
    lazy = false,
    opts = {
      enable_on_startup = true,
      exclude_groups = { "CursorLine" },
    },
    config = function(_, opts)
      require("transparent").setup(opts)

      local ui_groups = {
        "NormalFloat", "FloatBorder",
        "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer",
      }

      local function fix_ui_bg()
        -- Pmenu keeps its bg since transparent.nvim doesn't clear it
        local ref = vim.api.nvim_get_hl(0, { name = "Pmenu", link = false })
        if not ref.bg then return end
        for _, group in ipairs(ui_groups) do
          local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
          hl.bg = ref.bg
          vim.api.nvim_set_hl(0, group, hl)
        end
      end

      -- schedule_wrap ensures we run after transparent.nvim's own ColorScheme handler
      vim.api.nvim_create_autocmd("ColorScheme", { callback = vim.schedule_wrap(fix_ui_bg) })
      vim.schedule(fix_ui_bg)
    end,
  },
  { "HiPhish/rainbow-delimiters.nvim" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "sonokai",
    },
  },
  {
    "mawkler/modicator.nvim",
    opts = {
      show_warnings = false,
    },
  },
}
