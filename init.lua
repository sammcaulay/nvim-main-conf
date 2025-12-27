-- ==========================================================================
-- 1. CORE SETTINGS (The basics)
-- ==========================================================================
vim.g.mapleader = " " -- Sets the "Leader" key to Spacebar (Crucial!)
vim.g.maplocalleader = " "

vim.opt.number = true         -- Show line numbers
vim.opt.relativenumber = true -- Relative line numbers (great for jumps)
vim.opt.mouse = "a"           -- Enable mouse support
vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard
vim.opt.breakindent = true    -- Wrap lines with indentation
vim.opt.undofile = true       -- Save undo history to disk
vim.opt.ignorecase = true     -- Case insensitive searching...
vim.opt.smartcase = true      -- ...unless you type a capital letter
vim.opt.signcolumn = "yes"    -- Always show the sign column (prevents text shift)
vim.opt.updatetime = 250      -- Faster completion
vim.opt.timeoutlen = 300      -- Faster key presses
vim.opt.termguicolors = true  -- True color support

-- ==========================================================================
-- 2. BOOTSTRAP LAZY.NVIM (The Plugin Manager)
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

-- [THEME] Pywal (System Colors)
  {
    "AlphaTechnolog/pywal.nvim",
    name = "pywal",
    priority = 1000, -- Load this before everything else
    config = function()
      require("pywal").setup()
      vim.cmd.colorscheme("pywal")
    end,
  },

  -- [FILE EXPLORER] Neo-tree (Like VSCode sidebar)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- Requires a Nerd Font
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer" },
    },
  },

  -- [FUZZY FINDER] Telescope (Find files fast)
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find File" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Find Text" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find Buffer" },
    },
  },

  -- [SYNTAX] Treesitter (Better highlighting)
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

  -- [STATUS LINE] Lualine (Bottom bar)
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { theme = "pywal" },
  },

  -- [KEY HELPER] Which-Key (Shows popup of available keys)
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
  -- PART 2: THE BRAIN (LSP & Autocomplete)
  -- ========================================================================

  -- [INSTALLER] Mason (The "App Store" for Language Servers)
  {
    "williamboman/mason.nvim",
    opts = {},
  },

  -- [LSP BRIDGE] Mason-LSPConfig (Connects Mason to Neovim)
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "lua_ls", "bashls", "pyright", "clangd", "omnisharp" }, -- Auto-install these
      automatic_installation = true,
    },
  },

-- [LSP CONFIG] The Engine (Neovim 0.11 Native Version)
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

      -- 2. Capabilities (Enable Autocomplete)
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- 3. Setup Mason & Servers (The NEW Way)
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

  -- [AUTOCOMPLETE] CMP (The dropdown menu)
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

  -- [QUALITY OF LIFE] Easy Comments (gcc to comment line)
  {
    "numToStr/Comment.nvim",
    opts = {},
  },

-- ========================================================================
  -- PART 3: THE LOOK & FEEL (Git, Formatting, Visuals)
  -- ========================================================================

  -- [GIT] Gitsigns (Green/Red bars for added/deleted lines)
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },

  -- [FORMATTING] Conform (Auto-format on save)
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" }, -- Load when writing a buffer
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

  -- [VISUALS] Indent Blankline (Vertical lines for code blocks)
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl", -- Important for v3+
    opts = {},
  },
-- ========================================================================
  -- PART 4: DEBUGGING (C/C++/C#)
  -- ========================================================================

  -- [DEBUG ADAPTER] nvim-dap ( The Engine )
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui", -- The UI (Floating windows)
      "nvim-neotest/nvim-nio", -- Required by dap-ui
      "jay-babu/mason-nvim-dap.nvim", -- Connects Mason to DAP
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

      -- Keymaps for Debugging (F5, F10, F11)
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
        ensure_installed = { "codelldb" }, -- Installs C/C++ debugger
        handlers = {}, -- Auto-setup the handlers
    },
  },

})
