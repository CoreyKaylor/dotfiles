---@diagnostic disable: undefined-global -- hl and o are Hyprland/Omarchy globals
-- Personal Hyprland overrides from the dotfiles repo.
-- Loaded by ~/.config/hypr/hyprland.lua (install.sh adds the require) after
-- Omarchy's defaults and its stock monitors/input/bindings/looknfeel files,
-- and before Omarchy's runtime toggles. Later settings win in Hyprland.

-- Monitors -------------------------------------------------------------------
-- External Dell on top, laptop centered underneath it.
-- Laptop panel is 2560x1664; scale 1.333333 gives a 1920x1248 workspace, and
-- x = (3840 - 1920) / 2 centers it under the Dell.
hl.monitor({ output = "DP-1", mode = "3840x2160@60", position = "0x0", scale = 1 })
hl.monitor({ output = "eDP-1", mode = "preferred", position = "960x2160", scale = 1.333333 })

-- Input: Mac-like keyboard and trackpad --------------------------------------
hl.config({
  input = {
    -- Swap Caps Lock and Left Ctrl. Replaces Omarchy's default
    -- omarchy:shift_caps_compose, which would otherwise override the Caps key.
    kb_options = "ctrl:swapcaps",

    touchpad = {
      natural_scroll = true, -- content follows your fingers
      drag_3fg = 1,          -- three-finger drag (like macOS accessibility setting)
    },
  },
})

-- Mac direction: four-finger swipe left goes to the next workspace, right to the previous
-- (three fingers are used for dragging). Uses Omarchy's per-monitor workspaces 1-10.
-- Hyprland's built-in sliding "workspace" gesture didn't respond on this trackpad.
local function step_workspace(delta)
  return function()
    local ws = hl.get_active_workspace()
    if not ws or ws.id < 1 then return end
    local slot = (ws.id - 1) % 10 + 1
    local target = math.max(1, math.min(10, slot + delta))
    if target ~= slot then o.workspaces.focus(target)() end
  end
end
hl.gesture({ fingers = 4, direction = "left", action = step_workspace(1) })
hl.gesture({ fingers = 4, direction = "right", action = step_workspace(-1) })

-- Four-finger swipe up to open the app launcher (like Launchpad).
hl.gesture({ fingers = 4, direction = "up", action = function() hl.dispatch(hl.dsp.global("omarchy:menu.apps")) end })

-- Bindings -------------------------------------------------------------------
-- Folio (Omarchy's new Qt file manager, "Files") instead of Nautilus.
o.rebind("SUPER + SHIFT + F", "File manager", { launch = "folio" })

-- Look and feel --------------------------------------------------------------
-- Quick horizontal slide when switching workspaces (Omarchy disables this by default).
-- speed is in deciseconds: 2.5 = 250ms. Style options: "slide", "slidevert", "fade", "slidefade 20%".
hl.animation({ leaf = "workspaces", enabled = true, speed = 2.5, bezier = "easeOutQuint", style = "slide" })
