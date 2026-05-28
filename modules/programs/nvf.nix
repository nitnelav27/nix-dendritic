{ self, inputs, ...}: {

  flake.homeModules.vvhNvf = { config, pkgs, self, lib, inputs, ... }:
    let
      nixFormatter = if pkgs.stdenv.isDarwin then "alejandra" else "nixfmt";
    in
    {
      programs.nvf = {
        enable = true;
        enableManpages = true;
        settings = {
          vim = {
            globals = {
              mapleader = " ";
              vimtex_view_method = if pkgs.stdenv.isDarwin then "skim" else "zathura";
              vimtex_compiler_method = "latexmk";
              tex_conceal = "abdmg";
              vimtex_quickfix_open_on_warning = 0;
            };
            clipboard = {
              enable = true;
              providers.wl-copy.enable = pkgs.stdenv.isLinux;
              registers = "unnamedplus";
            };
            theme = {
              enable = true;
              name = "nord";
              style = "darker";
            };
            extraPlugins = with pkgs.vimPlugins; {
              nvim-autopairs = {
                package = nvim-autopairs;
                setup = ''require("nvim-autopairs").setup {}'';
              };
              vimtex = {
                package = vimtex;
                #setup = ''
                #  -- VimTeX configuration in Vimscript (it's a Vimscript plugin)
                #  vim.g.vimtex_view_method = 'zathura'
                #  vim.g.vimtex_compiler_method = 'latexmk'
                #'';
              };
              telescope-bibtex-nvim = {
                package = (pkgs.vimUtils.buildVimPlugin {
                  name = "telescope-bibtex-nvim";
                  src = pkgs.fetchFromGitHub {
                    owner = "nvim-telescope";
                    repo = "telescope-bibtex.nvim";
                    rev = "master"; 
                    hash = "sha256-xaGTJ69mknIn1esXw2maU03GnX85ficqXLD+ykkyi90="; 
                  };
                }).overrideAttrs (old: {
                    # This line stops the build from failing due to missing telescope during check
                    doCheck = false; 
                    nvimRequireCheck = null;
                    });
                setup = ''require("telescope").load_extension("bibtex")'';
              };
            };
            startPlugins = [
              "obsidian-nvim"
              "nvim-colorizer-lua"
              "blink-cmp"
              "catppuccin"
              "dressing-nvim"
              "flash-nvim"
              "friendly-snippets"
              "gitsigns-nvim"
              "mini-ai"
              "mini-icons"
              "mini-pairs"
              "nui-nvim"
              "nvim-lint"
              "nvim-ts-autotag"
              "plenary-nvim"
              "snacks-nvim"
              "todo-comments-nvim"
              "which-key-nvim"
              pkgs.vimPlugins.nvim-notify
              pkgs.vimPlugins.nvim-treesitter
              pkgs.vimPlugins.nvim-dap-python
              pkgs.vimPlugins.conform-nvim
              pkgs.vimPlugins.nvim-lint
              pkgs.vimPlugins.trouble-nvim
            ];
            luaConfigPost = ''
              -- 1. Register groups for which-key
              local wk = require("which-key")
              wk.add({
                { "<leader>l", group = "latex" },
                { "<leader>f", group = "find/telescope" },
              })

              -- 2. Force VimTeX mappings and ensure they load for .tex files
              vim.api.nvim_create_autocmd("FileType", {
                pattern = "tex",
                callback = function()
                local opts = { buffer = true, silent = true }
                vim.keymap.set('n', '<leader>ll', '<cmd>VimtexCompile<cr>', { buffer = true, desc = "Compile/Stop LaTeX" })
                vim.keymap.set('n', '<leader>lv', '<cmd>VimtexView<cr>', { buffer = true, desc = "View PDF" })
                vim.keymap.set('n', '<leader>li', '<cmd>VimtexInfo<cr>', { buffer = true, desc = "VimTeX Info" })
                -- New: Clean auxiliary LaTeX files
                vim.keymap.set('n', '<leader>lc', '<cmd>VimtexClean<cr>', { buffer = true, desc = "Clean Aux Files" })
              end})

              -- 3. Configure Python DAP
              require('dap-python').setup('python')

              -- 4. DOI Fetching Logic
              -- Existing Visual Mode: Fetches DOI from highlighted text
              vim.keymap.set('v', '<leader>doi', function()
              vim.cmd('normal! "dy')
              local doi = vim.fn.getreg('d')
              doi = doi:gsub("^%s*(.-)%s*$", "%1")
              if doi ~= "" then
              local cmd = string.format("curl -sLH 'Accept: application/x-bibtex' https://doi.org/%s", doi)
              local bibtex_entry = vim.fn.systemlist(cmd)
              if vim.v.shell_error == 0 then
                vim.api.nvim_put(bibtex_entry, 'l', true, true)
                print("DOI fetched successfully!")
              else
                print("Failed to fetch DOI.")
              end
              end
              end, { desc = "Fetch BibTeX from DOI (Visual)" })

              -- New Normal Mode: Prompts for DOI input
              vim.keymap.set('n', '<leader>doi', function()
              local doi = vim.fn.input('Enter DOI: ')
              if doi ~= "" then
              local cmd = string.format("curl -sLH 'Accept: application/x-bibtex' https://doi.org/%s", doi)
              local bibtex_entry = vim.fn.systemlist(cmd)
              if vim.v.shell_error == 0 then
                vim.api.nvim_put(bibtex_entry, 'l', true, true)
                print("DOI fetched successfully!")
              else
                print("Failed to fetch DOI.")
                  end
                end
              end, { desc = "Fetch BibTeX from DOI (Prompt)" })

              -- 5. Nix Indentation
              vim.api.nvim_create_autocmd("FileType", {
                pattern = "nix",
                callback = function()
                vim.opt_local.tabstop = 2
                vim.opt_local.softtabstop = 2
                vim.opt_local.shiftwidth = 2
                vim.opt_local.expandtab = true
                  end,
              })

              -- 6. New Telescope Keymaps
              local builtin = require('telescope.builtin')
              vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
              vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
              vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
              vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
            '';
            pluginRC = {
              nvim-notify = ''
                require("notify").setup({
                background_colour = "#000000",
                stages = "fade_in_slide_out"
                })
              '';
              noice-nvim = ''
                local noice = require("noice")
                noice.setup({
                  lsp = {
                    progress = { enables = true },
                    override = {
                      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                      ["vim.lsp.util.stylize_markdown"] = true,
                      ["cmp.entry.get_documentation"] = true,
                    },
                  },
                  presets = {
                    bottom_search = true,
                    command_palette = true,
                    long_message_to_split = true,
                  },
                  views = {
                    cmdline_popup = {
                      position = {
                        row = "40%",
                        col = "50%",
                      },
                      size = {
                        width = 60,
                        height = "auto",
                      },
                    },
                    popupmenu = {
                      relative = "editor",
                      position = {
                        row = 8,
                        col = "50%",
                      },
                      size = {
                        width = 60,
                        height = 10,
                      },
                      border = {
                        style = "rounded",
                        padding = { 0,1 },
                      },
                      win_options = {
                        winhighlight = {
                          Normal = "Normal",
                          FloatBorder = "DiagnosticInfo",
                        },
                      },
                    },
                  },
                  routes = {
                    {
                      view = "notify",
                      filter = { event = "msg_showmode" },
                    },
                    {
                      filter = {
                        event = "lsp",
                        kind = "progress",
                        cond = function(message)
                          local client = vim.tbl_get(message.opts, "progress", "client")
                          return client == "lua_ls" or client == "null-ls"
                        end,
                      },
                      opts = { skip = true },
                    },
                  },
                })
              '';
            };
            autocomplete.nvim-cmp = {
              enable = true;
              sources = lib.mkForce {
                "vimtex" = "[VimTeX]";
                "nvim_lsp" = "[LSP]";
                "path" = "[Path]";
                "buffer" = "[Buffer]";
                "luasnip" = "[snippets]";
              };
            };
            utility = {
              preview = {
                glow.enable = true;
                glow.mappings.openPreview = "<leader>mg";
                markdownPreview = {
                  enable = true;
                  alwaysAllowPreview = true;
                  autoClose = true;
                  autoStart = true;
                };
              };
              snacks-nvim.enable = true;
              images = {
                image-nvim = {
                  enable = true;
                  setupOpts = {
                    backend = "kitty";
                    editorOnlyRenderWhenFocused = false;
                    integrations = {
                      markdown = {
                        enable = true;
                        clearInInsertMode = true;
                        downloadRemoteImages = true;
                      };
                    };
                  };
                };
                img-clip.enable = true;
              };
            };
            ui = {
              noice.enable = true;
              colorizer = {
                enable = true;
                setupOpts = {
                  filetypes = {
                    "*" = {
                      AARRGGBB = true;
                      RGB = true;
                      RRGGBB = true;
                      RRGGBBAA = true;
                      always_update = true;
                      css = true;
                      mode = "background";
                      names = true;
                    };
                  };
                };
              };
              breadcrumbs.enable = true;
              illuminate.enable = true;
              smartcolumn.enable = true;
            };
            statusline.lualine.enable = true;
            telescope.enable = true;
            fzf-lua.enable = true;
            filetree = {
              neo-tree.enable = true;
            };
            options = {
              relativenumber = false;
              cursorline = true;
              tabstop = 2;
              softtabstop = 2;
              showtabline = 2;
              expandtab = true;
              smartindent = true;
              shiftwidth = 2;
              breakindent = true;
              conceallevel = 2;
              encoding = "utf-8";
              fileencoding = "utf-8";
            };
            lsp = {
              enable = true;
              trouble = {
                enable = true;
              };
              lspconfig.enable = true;
              servers.texlab.enable = true;
            };
            languages = {
              enableFormat = true;
              enableDAP = true;
              enableExtraDiagnostics = true;
              enableTreesitter = true;
              bash = {
                enable = true;
                format.enable = true;
                lsp.enable = true;
              };
              nix = {
                enable = true;
                format = {
                  enable = true;
                  type = [ nixFormatter ];
                };
                lsp = {
                  enable = true;
                  servers = [ "nil" ];
                };
              };
              python = {
                enable = true;
                dap.enable = true;
                format.enable = true;
                format.type = [
                  "black"
                ];
                lsp.enable = true;
                lsp.servers = [
                  "pyright"
                ];
              };
              markdown = {
                enable = true;
                format.enable = true;
                lsp = {
                  enable = !pkgs.stdenv.isDarwin;
                };
                extensions = {
                  markview-nvim.enable = true;
                  render-markdown-nvim.enable = true;
                };
              };
              clang.enable = true;
              html = {
                enable = true;
                treesitter.autotagHtml = true;
                # Disable the failing package specifically
                lsp = {
                  enable = true;
                  servers = [ "emmet-ls" ];
                };
              };
              lua.enable = true;
            };
          };
        };
      };
    };
}
