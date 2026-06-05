return {
  "Jezda1337/nvim-html-css",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "hrsh7th/nvim-cmp"
  },
  opts = {
    enable_on = {
      "html",
      "htmldjango",
      "tsx",
      "jsx",
      "erb",
      "svelte",
      "vue",
      "blade",
      "php",
      "templ",
      "astro",
    },
    style_sheets = {
      -- Add any global stylesheets here if needed
      -- "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css",
      -- "./styles/main.css",
    },
  },
}