return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  keys = {
    { "<leader>H", false }, -- replaced by <leader>ha
    { "<leader>h", false }, -- replaced by <leader>hh (also conflicts as a prefix)

    {
      "<leader>ha",
      function() require("harpoon"):list():add() end,
      desc = "Harpoon Add",
    },
    {
      "<leader>hh",
      function()
        local harpoon = require("harpoon")
        local list = harpoon:list()
        local items = {}
        for i, item in ipairs(list.items) do
          table.insert(items, { label = item.value, idx = i })
        end
        vim.ui.select(items, {
          prompt = "Harpoon",
          format_item = function(item) return item.label end,
        }, function(item)
          if item then list:select(item.idx) end
        end)
      end,
      desc = "Harpoon Menu",
    },
    {
      "<leader>hd",
      function() require("harpoon"):list():remove() end,
      desc = "Harpoon Delete",
    },
    {
      "<leader>h[",
      function() require("harpoon"):list():prev() end,
      desc = "Harpoon Prev",
    },
    {
      "<leader>h]",
      function() require("harpoon"):list():next() end,
      desc = "Harpoon Next",
    },
  },
}
