return {
  { "nvimdev/dashboard-nvim", enabled = false },
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "amansingh-afk/milli.nvim" },
    config = function()
      local alpha     = require("alpha")
      local dashboard = require("alpha.themes.dashboard")
      local splash    = require("milli").load({ splash = "redpill" })

      -- ── highlights ───────────────────────────────────────────────────
      vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#e2637a", bold   = true })
      vim.api.nvim_set_hl(0, "AlphaColHd",  { fg = "#9ed072", bold   = true })
      vim.api.nvim_set_hl(0, "AlphaSep",    { fg = "#3d3f4b" })
      vim.api.nvim_set_hl(0, "AlphaFile",   { fg = "#76cce0" })
      vim.api.nvim_set_hl(0, "AlphaDir",    { fg = "#7c7c9c", italic = true })
      vim.api.nvim_set_hl(0, "AlphaFooter", { fg = "#7c7c9c", italic = true })

      -- ── two-column shortcut grid ─────────────────────────────────────
      local COL_W = 28
      local DIV   = "  ┃  "

      local function fmt_item(it)
        local prefix  = string.format("  %s  %s", it.icon, it.label)
        local key_str = string.format("[%s]", it.key)
        local gap     = COL_W - vim.fn.strdisplaywidth(prefix) - vim.fn.strdisplaywidth(key_str)
        return prefix .. string.rep(" ", math.max(1, gap)) .. key_str
      end

      local function col_hd(icon, title)
        local s = string.format("  %s %s", icon, title)
        return s .. string.rep(" ", math.max(0, COL_W - vim.fn.strdisplaywidth(s)))
      end

      local left_items = {
        { icon = "󰱼", label = "Find file",    key = "f", fn = function() LazyVim.pick("files")() end },
        { icon = "󱋡", label = "Recent files", key = "r", fn = function() LazyVim.pick("recent")() end },
        { icon = "󰏗", label = "Projects",     key = "p", fn = function() Snacks.picker.projects() end },
        { icon = "󰍉", label = "Find text",    key = "/", fn = function() LazyVim.pick("grep")() end },
        { icon = "󰙴", label = "New file",     key = "n", fn = function() vim.cmd("ene | startinsert") end },
      }
      local right_items = {
        { icon = "󰦛", label = "Session",     key = "s", fn = function() require("persistence").load() end },
        { icon = "󰒓", label = "Config",      key = "c", fn = function() LazyVim.pick("files", { cwd = vim.fn.stdpath("config") })() end },
        { icon = "󰱖", label = "Lazy Extras", key = "x", fn = function() vim.cmd("LazyExtras") end },
        { icon = "󰒲", label = "Lazy",        key = "l", fn = function() vim.cmd("Lazy") end },
        { icon = "󰗼", label = "Quit",        key = "q", fn = function() vim.cmd("qa") end },
      }

      local blank      = string.rep(" ", COL_W)
      local hd_row     = col_hd("󰈚", "FILES") .. DIV .. col_hd("", "SYSTEM")
      local sep_row    = string.rep("─", COL_W + 2) .. "┼" .. string.rep("─", COL_W + 2)
      local grid_lines = {}
      for i = 1, math.max(#left_items, #right_items) do
        grid_lines[i] = (left_items[i] and fmt_item(left_items[i]) or blank)
          .. DIV
          .. (right_items[i] and fmt_item(right_items[i]) or "")
      end

      -- keymaps wired on every alpha buffer open
      vim.api.nvim_create_autocmd("FileType", {
        pattern  = "alpha",
        callback = function(ev)
          for _, it in ipairs(left_items) do
            vim.keymap.set("n", it.key, it.fn, { buffer = ev.buf, nowait = true, silent = true })
          end
          for _, it in ipairs(right_items) do
            vim.keymap.set("n", it.key, it.fn, { buffer = ev.buf, nowait = true, silent = true })
          end
        end,
      })

      -- ── recent files ─────────────────────────────────────────────────
      local recents = {}
      local seen    = {}
      for _, f in ipairs(vim.v.oldfiles or {}) do
        if #recents >= 5 then break end
        local path = vim.fn.resolve(vim.fn.expand(f))
        if not seen[path] and vim.fn.filereadable(path) == 1 then
          seen[path] = true
          local key  = tostring(#recents + 1)
          local name = vim.fn.fnamemodify(path, ":t")
          local dir  = vim.fn.fnamemodify(path, ":~:.:h")
          local display = string.format("  %-26s  %s", name, dir)
          local b = dashboard.button(key, display, "<cmd>e " .. vim.fn.fnameescape(path) .. "<cr>")
          -- two-tone: filename cyan, dir muted
          local name_end = 2 + #name + 2  -- byte offset after name
          b.opts.hl = {
            { "AlphaFile", 0, name_end },
            { "AlphaDir",  name_end, -1 },
          }
          b.opts.hl_shortcut = "AlphaShortcut"
          recents[#recents + 1] = b
        end
      end

      -- ── footer ───────────────────────────────────────────────────────
      local v      = vim.version()
      local n      = (pcall(require, "lazy")) and require("lazy").stats().count or 0
      local footer_val = { string.format("  nvim v%d.%d.%d  ·  ⚡ %d plugins", v.major, v.minor, v.patch, n) }

      vim.api.nvim_create_autocmd("User", {
        once    = true,
        pattern = "LazyVimStarted",
        callback = function()
          local s  = require("lazy").stats()
          local ms = string.format("%.0fms", s.startuptime)
          footer_val[1] = string.format(
            "  nvim v%d.%d.%d  ·  ⚡ %d plugins  ·   %s startup",
            v.major, v.minor, v.patch, s.count, ms
          )
          pcall(vim.cmd.AlphaRedraw)
        end,
      })

      -- ── layout ───────────────────────────────────────────────────────
      local total_w = 2 * COL_W + vim.fn.strdisplaywidth(DIV)

      local layout = {
        { type = "padding", val = 1 },
        { type = "text", val = splash.frames[1], opts = { position = "center" } },
        { type = "padding", val = 1 },
        {
          type = "text",
          val  = { "◈  R E D P I L L  V I M  ◈" },
          opts = { hl = "AlphaHeader", position = "center" },
        },
        { type = "padding", val = 1 },
        { type = "text", val = { hd_row  }, opts = { hl = "AlphaColHd", position = "center" } },
        { type = "text", val = { sep_row }, opts = { hl = "AlphaSep",   position = "center" } },
        { type = "text", val = grid_lines,  opts = { hl = "AlphaFile",  position = "center" } },
      }

      if #recents > 0 then
        local rec_hd  = "  󰋃 RECENT"
        rec_hd = rec_hd .. string.rep(" ", math.max(0, total_w - vim.fn.strdisplaywidth(rec_hd)))
        local rec_sep = string.rep("─", total_w)
        table.insert(layout, { type = "padding", val = 1 })
        table.insert(layout, { type = "text", val = { rec_hd  }, opts = { hl = "AlphaColHd", position = "center" } })
        table.insert(layout, { type = "text", val = { rec_sep }, opts = { hl = "AlphaSep",   position = "center" } })
        table.insert(layout, { type = "group", val = recents, opts = { spacing = 0 } })
      end

      table.insert(layout, { type = "padding", val = 1 })
      table.insert(layout, { type = "text", val = footer_val, opts = { hl = "AlphaFooter", position = "center" } })
      table.insert(layout, { type = "padding", val = 1 })

      alpha.setup({ layout = layout })
      require("milli").alpha({ splash = "redpill", loop = true })
    end,
  },
}
