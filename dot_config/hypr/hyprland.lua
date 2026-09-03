-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Browser video never sends a Wayland idle inhibitor. Inhibit only while
-- that window is focused, so a YouTube or Netflix tab in the background does
-- not block the screensaver.
o.window({
  title = ".*(Netflix|YouTube|Prime Video|Disney\\+|Disney Plus|Hulu|HBO Max|Plex|Jellyfin|Twitch|Crunchyroll|Paramount|Peacock|Apple TV).*",
}, { idle_inhibit = "focus" })
o.window(
  "^(mpv|vlc|celluloid|io\\.github\\.celluloid_player\\.Celluloid|org\\.gnome\\.Totem|com\\.github\\.rafostar\\.Clapper|haruna)$",
  { idle_inhibit = "focus" }
)
o.window({ tag = "pip" }, { idle_inhibit = "always" })
