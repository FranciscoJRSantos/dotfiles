------------------
---- MONITORS ----
------------------

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" })

-- Both desks use a single external monitor with the laptop panel off; only the
-- mobile profile brings eDP-1 back. The home/office profiles disable it, so the
-- re-enable must pass disabled = false explicitly: a rule that only sets
-- mode/position is treated as identical to the active one and is never applied.
local function laptop_on(position)
    hl.monitor({ output = "eDP-1", mode = "1920x1200@60", position = position, scale = "1", disabled = false })
end

local function apply_monitor_profile()
    local monitors = hl.get_monitors()
    local names = {}
    for _, m in ipairs(monitors) do
        names[m.name] = true
    end

    if names["HDMI-A-1"] then
        -- Home: single 4K OLED, laptop panel off regardless of lid state
        hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@120", position = "0x0", scale = "1" })
        hl.monitor({ output = "eDP-1", disabled = true })
    elseif names["DP-1"] then
        -- Office: single 1440p, laptop panel off
        hl.monitor({ output = "DP-1", mode = "2560x1440@60", position = "0x0", scale = "1" })
        hl.monitor({ output = "eDP-1", disabled = true })
    else
        -- Mobile: laptop only
        laptop_on("0x0")
    end
end

apply_monitor_profile() -- re-apply on config reload, not just on hotplug/start

hl.on("monitor.added", function() apply_monitor_profile() end)
hl.on("monitor.removed", function() apply_monitor_profile() end)

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "ghostty"
local file_manager = "thunar"
local tui_file_manager = "yazi"
local editor = "emacsclient -nc"
local browser = "chromium-browser"
local ipc = "noctalia msg "

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    apply_monitor_profile()
    hl.exec_cmd("systemctl --user start hyprland-session.target")
    hl.exec_cmd("noctalia")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("emacs --daemon")

    hl.exec_cmd("flatpak run com.slack.Slack", { workspace = "1 silent" })
    hl.exec_cmd(browser, { workspace = "2 silent" })
    hl.exec_cmd(editor, { workspace = "3 silent" })
    hl.exec_cmd(terminal, { workspace = "3 silent" })
    hl.exec_cmd("flatpak run app.zen_browser.zen", { workspace = "10 silent" })

    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)

hl.on("hyprland.shutdown", function()
    os.execute("systemctl --user stop hyprland-session.target && sleep 0.1")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    debug = {
        disable_logs = false,
    },

    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        resize_on_border = false,
        allow_tearing = false,
        layout = "master",
    },

    decoration = {
        rounding = 20,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },

        blur = {
            enabled = true,
            size = 3,
            passes = 2,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        enable_anr_dialog = false,
    },

    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",

        follow_mouse = 1,
        sensitivity = 0,

        touchpad = {
            natural_scroll = false,
        },

        repeat_delay = 400,
        repeat_rate = 30,
    },
})

--------------------
---- ANIMATIONS ----
--------------------

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

---------------
---- INPUT ----
---------------

hl.device({
    name = "ergo-k860-keyboard",
    kb_options = "caps:swapescape, altwin:swap_alt_win",
})

hl.device({
    name = "at-translated-set-2-keyboard",
    kb_options = "caps:swapescape",
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd(ipc .. "settings-toggle"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(file_manager))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(terminal .. " -e " .. tui_file_manager))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(editor))

hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(ipc .. "panel-toggle clipboard"))

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exit())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen(1))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.group.next())
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd([[bash -c 'W=$(hyprctl -j activeworkspace | jq -r .id); L=$(hyprctl -j activeworkspace | jq -r .tiledLayout); if [ "$L" = monocle ]; then N=master; else N=monocle; fi; hyprctl eval "hl.workspace_rule({ workspace = \"$W\", layout = \"$N\" })" && notify-send -t 1500 "Layout" "Workspace $W → $N"']]))

-- Move active workspace to a specific monitor
hl.bind(mainMod .. " + CTRL + 0", hl.dsp.workspace.move({ monitor = 0 }))
hl.bind(mainMod .. " + CTRL + 1", hl.dsp.workspace.move({ monitor = 1 }))

-- Move focus with mainMod + HJKL
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Swap windows with mainMod + SHIFT + HJKL
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.swap({ direction = "down" }))

-- Cycle windows
hl.bind(mainMod .. " + Tab", hl.dsp.layout("cyclenext"))
hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.layout("cycleprev"))

-- Switch workspaces / move windows to workspaces with mainMod + [0-9]
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume / brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. "volume-up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. "volume-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. "volume-mute"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. "brightness-up"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. "brightness-down"), { locked = true, repeating = true })

-- Media keys
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(ipc .. "media play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(ipc .. "media previous"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(ipc .. "media next"), { locked = true })

-- Mute mic
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(ipc .. "mic-mute"))
hl.bind("F13", hl.dsp.exec_cmd(ipc .. "mic-mute"), { locked = true })

-- Lock screen
hl.bind(mainMod .. " + CTRL + Q", hl.dsp.exec_cmd(ipc .. "session lock"))

-- Lid switch: docked = no-op, undocked = lock and suspend (see scripts/lid-policy.sh)
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/lid-policy.sh on"), { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.workspace_rule({ workspace = "2", layout = "monocle" })
hl.workspace_rule({ workspace = "3", layout = "monocle" })
hl.workspace_rule({ workspace = "4", layout = "monocle" })
hl.workspace_rule({ workspace = "10", layout = "monocle" })

hl.window_rule({
    name = "Float Bluetooth Manager",
    match = {
        title = "^(Bluetooth Manager)$",
    },
    float = true
})
hl.window_rule({
    name = "Float Volume Control",
    match = {
        title = "^(Volume Control)$",
    },
    float = true
})

hl.window_rule({
    name = "Picture in Picture",
    match = {
        title = "^(Picture-in-Picture|Firefox|Picture in picture|Meet)$",
    },
    float = true,
    size = {800, 450},
    pin = true
})


-- Noctalia shell color overrides (sourced last to override border colors).
-- The file is generated by Noctalia and not tracked, so a missing one just means default borders.
pcall(require, "noctalia.noctalia-colors")
