local M = {}

local input_method = "none"
local initialized = false
local prev_state = nil
local prev_engine = nil

local config = {
  enable = true,
  debug = false,
  no_mappings = false,
}

local function debug(msg)
  if config.debug then
    vim.notify("[input-method-auto] " .. msg, vim.log.levels.DEBUG)
  end
end

local function trim(s)
  return (s:gsub("%s+$", ""))
end

local function detect_input_method()
  if vim.fn.executable("fcitx5-remote") == 1 then
    if os.execute("pgrep -x fcitx5 >/dev/null 2>&1") == 0 then
      debug("Detected fcitx5")
      return "fcitx5"
    end
  end

  if vim.fn.executable("fcitx-remote") == 1 then
    if os.execute("pgrep -x fcitx >/dev/null 2>&1") == 0 then
      debug("Detected fcitx4")
      return "fcitx"
    end
  end

  if vim.fn.executable("ibus") == 1 then
    if os.execute("pgrep -x ibus-daemon >/dev/null 2>&1") == 0 then
      debug("Detected ibus")
      return "ibus"
    end
  end

  debug("No input method detected")
  return "none"
end

local function fcitx_off()
  local ok, err = pcall(function()
    local remote = input_method == "fcitx5" and "fcitx5-remote" or "fcitx-remote"
    local status = tonumber(trim(vim.fn.system(remote))) or 0
    prev_state = status
    if status == 2 then
      vim.fn.system(remote .. " -c")
      debug(input_method .. " turned off")
    end
  end)
  if not ok then
    debug("Error in fcitx_off: " .. tostring(err))
  end
end

local function fcitx_on()
  local ok, err = pcall(function()
    local remote = input_method == "fcitx5" and "fcitx5-remote" or "fcitx-remote"
    local status = tonumber(trim(vim.fn.system(remote))) or 0
    if status == 1 and prev_state == 2 then
      vim.fn.system(remote .. " -o")
      debug(input_method .. " restored")
    end
  end)
  if not ok then
    debug("Error in fcitx_on: " .. tostring(err))
  end
end

local function ibus_off()
  prev_engine = trim(vim.fn.system("ibus engine"))
  debug("ibus_off: saved engine = " .. prev_engine)
  vim.fn.system("ibus engine xkb:us::eng")
  local result = trim(vim.fn.system("ibus engine"))
  debug("ibus_off: switched to = " .. result)
end

local function ibus_on()
  local current_engine = trim(vim.fn.system("ibus engine"))
  debug("ibus_on: current = " .. current_engine)
  if not current_engine:lower():match("xkb:us::eng") then
    prev_engine = current_engine
    debug("ibus_on: updated saved engine = " .. current_engine)
  end
  if prev_engine and prev_engine ~= "" then
    vim.fn.system("ibus engine " .. vim.fn.shellescape(prev_engine))
    local result = trim(vim.fn.system("ibus engine"))
    debug("ibus_on: restored to = " .. result)
  end
end

local function im_off()
  if input_method == "fcitx5" or input_method == "fcitx" then
    fcitx_off()
  elseif input_method == "ibus" then
    ibus_off()
  end
end

local function im_on()
  if input_method == "fcitx5" or input_method == "fcitx" then
    fcitx_on()
  elseif input_method == "ibus" then
    ibus_on()
  end
end

local function init()
  if initialized then
    return
  end

  input_method = detect_input_method()

  if input_method ~= "none" then
    local group = vim.api.nvim_create_augroup("InputMethodAuto", { clear = true })

    vim.api.nvim_create_autocmd("CmdLineEnter", {
      group = group,
      pattern = { "[/?]", "\\?" },
      callback = function() im_on() end,
    })
    vim.api.nvim_create_autocmd("CmdLineLeave", {
      group = group,
      pattern = { "[/?]", "\\?" },
      callback = function() im_off() end,
    })
    vim.api.nvim_create_autocmd("InsertEnter", {
      group = group,
      pattern = "*",
      callback = function() im_on() end,
    })
    vim.api.nvim_create_autocmd("InsertLeave", {
      group = group,
      pattern = "*",
      callback = function() im_off() end,
    })
    vim.api.nvim_create_autocmd("VimEnter", {
      group = group,
      callback = function() im_off() end,
    })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = "fzf",
      callback = function() im_on() end,
    })
    vim.api.nvim_create_autocmd("BufLeave", {
      group = group,
      pattern = "*",
      callback = function()
        if vim.bo.filetype == "fzf" then
          im_off()
        end
      end,
    })

    im_off()
    initialized = true

    if config.debug then
      vim.notify("Input method auto initialized: " .. input_method)
    end
  else
    if config.debug then
      vim.notify("No supported input method found")
    end
  end
end

function M.toggle()
  if input_method ~= "none" then
    im_on()
    vim.notify("Input method temporarily enabled")
  else
    vim.notify("No input method detected")
  end
end

function M.status()
  vim.notify(("Input method: %s | Initialized: %s"):format(
    input_method,
    initialized and "yes" or "no"
  ))
end

function M.reset()
  initialized = false
  vim.api.nvim_create_augroup("InputMethodAuto", { clear = true })
  init()
  vim.notify("Input method auto reset")
end

function M.setup(opts)
  opts = opts or {}
  config.enable = opts.enable == nil and true or opts.enable
  config.debug = opts.debug or false
  config.no_mappings = opts.no_mappings or false

  -- Support legacy vim global variables
  if vim.g.input_method_auto_enable ~= nil then
    config.enable = vim.g.input_method_auto_enable ~= 0
  end
  if vim.g.input_method_auto_debug ~= nil then
    config.debug = vim.g.input_method_auto_debug ~= 0
  end
  if vim.g.input_method_auto_no_mappings ~= nil then
    config.no_mappings = vim.g.input_method_auto_no_mappings ~= 0
  end

  -- Commands
  vim.api.nvim_create_user_command("InputMethodAutoToggle", function() M.toggle() end, {})
  vim.api.nvim_create_user_command("InputMethodAutoStatus", function() M.status() end, {})
  vim.api.nvim_create_user_command("InputMethodAutoReset", function() M.reset() end, {})

  -- Key mapping
  if not config.no_mappings then
    vim.keymap.set("n", "<leader>im", M.toggle, { silent = true, desc = "Toggle input method" })
  end

  if config.enable then
    init()
  end
end

return M
