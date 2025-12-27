-- ==========================================================================
-- 1. CORE SETTINGS 
-- ==========================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true         -- Show line numbers
vim.opt.relativenumber = true -- Relative line numbers
vim.opt.mouse = "a"           -- Enable mouse support
vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard
vim.opt.breakindent = true    -- Wrap lines with indentation
vim.opt.undofile = true       -- Save undo history to disk
vim.opt.ignorecase = true     -- Case insensitive searching...
vim.opt.smartcase = true      -- ...unless you type a capital letter
vim.opt.signcolumn = "yes"    -- Always show the sign column
vim.opt.updatetime = 250      -- Faster completion
vim.opt.timeoutlen = 300      -- Faster key presses
vim.opt.termguicolors = true  -- True color support

-- ==========================================================================
-- 2. BOOTSTRAP LAZY.NVIM
-- ==========================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ==========================================================================
-- 3. PLUGINS SETUP
-- ==========================================================================
require("lazy").setup({

-- [THEME] Pywal
  {
    "AlphaTechnolog/pywal.nvim",
    name = "pywal",
    priority = 1000,
    config = function()
      require("pywal").setup()
      vim.cmd.colorscheme("pywal")
    end,
  },

  -- [FILE EXPLORER] Neo-tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer" },
    },
  },

  -- [FUZZY FINDER] Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Find Text" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find Buffer" },
    },
  },

  -- [SYNTAX] Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.config").setup({
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "python", "bash" },
        highlight = { enable = true },
      })
    end,
  },

  -- [STATUS LINE] Lualine
    {
      "nvim-lualine/lualine.nvim",
      opts = { theme = "pywal" },
    },

  -- [KEY HELPER] Which-Key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {},
  },

-- ========================================================================
  -- PART 2: THE BRAIN
  -- ========================================================================

  -- [INSTALLER] Mason
  {
    "williamboman/mason.nvim",
    opts = {},
  },

  -- [LSP BRIDGE] Mason-LSPConfig
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "lua_ls", "bashls", "pyright", "clangd", "omnisharp" }, -- Auto-install these
      automatic_installation = true,
    },
  },

-- [LSP CONFIG] The Engine
  {
    "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    config = function()
      -- 1. Setup Keymaps via LspAttach (Standard for 0.11+)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd", vim.lsp.buf.definition, "Goto Definition")
          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("<leader>rn", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
        end,
      })

      -- 2. Capabilities
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- 3. Setup Mason & Servers
      local mason_lspconfig = require("mason-lspconfig")
      
      mason_lspconfig.setup({
        ensure_installed = { "lua_ls", "bashls", "pyright" },
      })

      -- Iterate over installed servers and use the Native v0.11 API
      for _, server_name in ipairs(mason_lspconfig.get_installed_servers()) do
        -- Register the config (merges with defaults automatically)
        vim.lsp.config(server_name, {
          capabilities = capabilities,
        })
        -- Enable the server globally for its filetypes
        vim.lsp.enable(server_name)
      end
    end,
  },

  -- [AUTOCOMPLETE] CMP
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- LSP source for cmp
      "L3MON4D3/LuaSnip",     -- Snippet engine
      "saadparwaiz1/cmp_luasnip", -- Snippets source
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(), -- Ctrl+n to go down
          ["<C-p>"] = cmp.mapping.select_prev_item(), -- Ctrl+p to go up
          ["<C-Space>"] = cmp.mapping.complete(),     -- Ctrl+Space to force open
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Enter to confirm
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
        },
      })
    end,
  },

  -- [QUALITY OF LIFE] Auto-Close Brackets
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- [QUALITY OF LIFE] Easy Comments
  {
    "numToStr/Comment.nvim",
    opts = {},
  },

-- ========================================================================
  -- PART 3: THE LOOK & FEEL
  -- ========================================================================

  -- [GIT] Gitsigns
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },

  -- [FORMATTING] Conform
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "black" },
        bash = { "shfmt" },
        javascript = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        markdown = { "prettier" },
        c = { "clang-format" },      
        cpp = { "clang-format" },        
        cs = { "csharpier" },            
      },
    },
  },

  -- [VISUALS] Indent Blankline
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl", -- Important for v3+
    opts = {},
  },
-- ========================================================================
  -- PART 4: DEBUGGING
  -- ========================================================================

  -- [DEBUG ADAPTER] nvim-dap
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim", 
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Setup UI
      dapui.setup()
      
      -- Open UI automatically when debugging starts
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Keymaps for Debugging
      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: Step Into" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
      vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
    end,
  },
  
  -- [MASON DAP] Auto-setup debuggers
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
        ensure_installed = { "codelldb" },
        handlers = {}, 
    },
  },

})
