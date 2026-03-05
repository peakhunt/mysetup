local wezterm = require 'wezterm'
local act = wezterm.action

return {
  font = wezterm.font("AdwaitaMono Nerd Font Mono"),
  font_size = 11.0,
  color_scheme = "Catppuccin Mocha",
  window_background_opacity = 0.85,
  hide_tab_bar_if_only_one_tab = false,
  window_decorations = "RESIZE",

  keys = {
    { key="t", mods="CTRL|SHIFT", action=act{SpawnTab="CurrentPaneDomain"} },
    { key="|", mods="CTRL|SHIFT", action=act.SplitHorizontal{domain="CurrentPaneDomain"} },
    { key="\\", mods="CTRL", action=act.SplitVertical{domain="CurrentPaneDomain"} },
    { key="q", mods="CTRL|SHIFT", action=act{CloseCurrentTab={confirm=true}} },

    -- Navigate between panes
    { key="h", mods="CTRL|SHIFT", action=act.ActivatePaneDirection("Left") },
    { key="l", mods="CTRL|SHIFT", action=act.ActivatePaneDirection("Right") },
    { key="k", mods="CTRL|SHIFT", action=act.ActivatePaneDirection("Up") },
    { key="j", mods="CTRL|SHIFT", action=act.ActivatePaneDirection("Down") },
  },
  front_end = "WebGpu", -- options: "OpenGL", "WebGpu", "Software"
}
