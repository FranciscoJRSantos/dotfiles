------------------
---- MONITORS ----
------------------

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "1" })

-- Both desks keep the laptop panel off; only the mobile profile brings eDP-1
-- back. The home/office profiles disable it, so the re-enable must pass
-- disabled = false explicitly: a rule that only sets mode/position is treated
-- as identical to the active one and is never applied.
local function laptop_on(position)
    hl.monitor({ output = "eDP-1", mode = "1920x1200@60", position = position, scale = "1", disabled = false })
end

-- The lid decides whether the laptop panel is on when docked (decision D2):
-- open = panel on, closed = panel off. Read it from the kernel because
-- Hyprland has no lid event, only the `switch:*:Lid Switch` binds.
local LID_STATE_FILES = {
    "/proc/acpi/button/lid/LID0/state",
    "/proc/acpi/button/lid/LID1/state",
    "/proc/acpi/button/lid/LID/state",
}
local function lid_closed()
    for _, path in ipairs(LID_STATE_FILES) do
        local f = io.open(path, "r")
        if f then
            local state = f:read("*a") or ""
            f:close()
            return state:find("closed", 1, true) ~= nil
        end
    end
    return false -- no lid switch (desktop): behave as if open
end

-- Docked: mirror the lid on eDP-1 and let Hyprland place the panel next to the
-- external layout.
local function apply_lid_to_laptop_panel()
    if lid_closed() then
        hl.monitor({ output = "eDP-1", disabled = true })
    else
        hl.monitor({ output = "eDP-1", mode = "1920x1200@60", position = "auto", scale = "1", disabled = false })
    end
end

-- Office secondary: 34" 2560x1080 ultrawide, mounted vertically right of the
-- ASUS. Matched by EDID description, not port, because it sits on HDMI-A-1,
-- the same port the home OLED uses. It advertises a 4K mode that it only
-- downscales, so pin the native mode. transform = 3 (270°) matches how it is
-- physically mounted; 1 renders upside down. Rotated it is 1080x2560 logical; the
-- ASUS is shifted down 560 so their vertical centres line up.
local OFFICE_VERTICAL = "LG Electronics LG ULTRAGEAR 0x00023FA3"

local function apply_monitor_profile()
    local monitors = hl.get_monitors()
    local names, descs = {}, {}
    for _, m in ipairs(monitors) do
        names[m.name] = true
        descs[m.description] = true
    end

    -- Office first: its ultrawide also occupies HDMI-A-1, which would
    -- otherwise be mistaken for the home OLED.
    if names["DP-1"] then
        -- Office: 1440p main, optional vertical ultrawide on the right
        if descs[OFFICE_VERTICAL] then
            hl.monitor({ output = "DP-1", mode = "2560x1440@60", position = "0x560", scale = "1" })
            hl.monitor({ output = "desc:" .. OFFICE_VERTICAL, mode = "2560x1080@144", position = "2560x0", scale = "1", transform = 3 })
        else
            hl.monitor({ output = "DP-1", mode = "2560x1440@60", position = "0x0", scale = "1" })
        end
    elseif names["HDMI-A-1"] then
        -- Home: single 4K OLED
        hl.monitor({ output = "HDMI-A-1", mode = "3840x2160@120", position = "0x0", scale = "1" })
    else
        -- Mobile: laptop only, whatever the lid says
        laptop_on("0x0")
        return
    end
    -- With an external attached, the lid owns the laptop panel.
    apply_lid_to_laptop_panel()
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
    -- Noctalia and the Emacs daemon are systemd user units (systemd/ package),
    -- started with hyprland-session.target. nm-applet comes from XDG autostart,
    -- so none of them are exec'd here.

    hl.exec_cmd("flatpak run com.slack.Slack", { workspace = "1 silent" })
    hl.exec_cmd(browser, { workspace = "2 silent" })
    -- `systemctl start` blocks until the Type=notify daemon is ready, then the
    -- client attaches; the workspace comes from the one-shot rule below, not
    -- from an exec token (a forked child breaks Hyprland's PID association).
    hl.exec_cmd([[bash -c 'systemctl --user start emacs.service && emacsclient -nc']])
    hl.exec_cmd(terminal, { workspace = "3 silent" })
    hl.exec_cmd("flatpak run app.zen_browser.zen", { workspace = "10 silent" })
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
        -- A restarted Noctalia must be able to reclaim the session lock;
        -- without this a crash leaves the screen stuck on the dead lock client.
        allow_session_lock_restore = true,
        disable_hyprland_logo = true,
        background_color = "0xff000000",
        -- Adaptive sync everywhere, including fullscreen-only apps.
        vrr = 3,
    },

    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
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
    -- No altwin:swap_alt_win on purpose. Put the keyboard itself in macOS
    -- layout mode (Fn+O, held ~3s) so its firmware sends Cmd as LWIN (Super)
    -- and Opt as LALT (Alt). Then no software swap is needed.
    -- If you ever switch it back to PC layout (Fn+P), Cmd/Alt emits LALT and
    -- Opt/Start emits LWIN, and you'd need "altwin:swap_alt_win" here instead.
    kb_options = "caps:swapescape",
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

-- Window switcher (MRU) on Super+Tab; a quick tap switches to the previous window
hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd(ipc .. "window-switcher hold"))
-- deferred: Super+Shift+Tab reverse switching, Noctalia 5.4.1 rejects the `reverse` action

hl.bind("PRINT", hl.dsp.exec_cmd(ipc .. "screenshot-region"))
hl.bind(mainMod .. " + PRINT", hl.dsp.exec_cmd(ipc .. "screenshot-fullscreen"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(ipc .. "panel-toggle clipboard"))
-- Read the PRIMARY selection (or clipboard) aloud with Piper. Absolute path
-- because ~/.local/bin is not guaranteed to be on Hyprland's PATH.
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/read-selection.sh"))
-- Stop the read that is currently playing.
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/read-selection.sh --stop"))

-- Dictation (hyprwhspr): press starts recording, release stops. Escape discards
-- an accidental recording without transcribing. Absolute path because
-- ~/.local/bin is not on Hyprland's exec PATH.
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/dictation.sh start"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/dictation.sh release"), { release = true })
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/dictation.sh cancel"))

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
-- Session panel (lock, logout, reboot, shutdown) instead of an instant exit.
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd(ipc .. "panel-toggle session"))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen(1))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.group.next())
hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd([[bash -c 'W=$(hyprctl -j activeworkspace | jq -r .id); L=$(hyprctl -j activeworkspace | jq -r .tiledLayout); if [ "$L" = monocle ]; then N=master; else N=monocle; fi; hyprctl eval "hl.workspace_rule({ workspace = \"$W\", layout = \"$N\" })" && notify-send -t 1500 "Layout" "Workspace $W → $N"']]))

-- Move active workspace to a specific monitor
hl.bind(mainMod .. " + CTRL + 0", hl.dsp.workspace.move({ monitor = 0 }))
hl.bind(mainMod .. " + CTRL + 1", hl.dsp.workspace.move({ monitor = 1 }))
-- Office vertical ultrawide, by description: its numeric ID depends on what
-- else is plugged in (eDP-1 keeps ID 0 even while disabled).
hl.bind(mainMod .. " + CTRL + 2", hl.dsp.workspace.move({ monitor = "desc:" .. OFFICE_VERTICAL }))

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
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(ipc .. "mic-mute"), { locked = true })
hl.bind("F13", hl.dsp.exec_cmd(ipc .. "mic-mute"), { locked = true })

-- Lock screen
hl.bind(mainMod .. " + CTRL + Q", hl.dsp.exec_cmd(ipc .. "session lock"))

-- Lid switch: re-apply the layout so eDP-1 follows the lid, then hand the
-- docked/undocked decision to power-policy.sh (docked = no-op, undocked = lock
-- and suspend). Hyprland exposes no lid event, only these binds.
local power_policy = os.getenv("HOME") .. "/.config/hypr/scripts/power-policy.sh"
hl.bind("switch:on:Lid Switch", function()
    apply_monitor_profile()
    hl.exec_cmd(power_policy .. " on")
end, { locked = true })
hl.bind("switch:off:Lid Switch", function()
    apply_monitor_profile()
end, { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Keep workspaces 1-10 alive so the bar always shows a stable row; the four
-- named ones are where the autostarted apps land.
local workspace_names = { [1] = "slack", [2] = "web", [3] = "code", [10] = "zen" }
for i = 1, 10 do
    hl.workspace_rule({ workspace = tostring(i), persistent = true, default_name = workspace_names[i] })
end

hl.workspace_rule({ workspace = "2", layout = "monocle" })
hl.workspace_rule({ workspace = "3", layout = "monocle" })
hl.workspace_rule({ workspace = "4", layout = "monocle" })
hl.workspace_rule({ workspace = "10", layout = "monocle" })

-- Noctalia panels and popups: no slide animations, blur everything, and let
-- translucent areas of the layer contribute to the blur.
hl.layer_rule({
    name = "Noctalia panels",
    match = { namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$" },
    no_anim = true,
    ignore_alpha = 0.5,
    blur = true,
    blur_popups = true,
})

-- Picture-in-Picture: small floating window pinned to the bottom-right corner.
-- The class match keeps ordinary browser windows with a matching title tiled.
hl.window_rule({
    name = "Picture in Picture",
    match = {
        class = "^(firefox|chromium-browser|zen)$",
        title = "^(Picture-in-Picture|Firefox|Picture in picture|Meet)$",
    },
    float = true,
    size = { 800, 450 },
    keep_aspect_ratio = true,
    move = "monitor_w-window_w-20 monitor_h-window_h-20",
    pin = true,
})

-- The first Emacs frame of the session lands on workspace 3, then the rule
-- disables itself so later frames open wherever the user is. Emacs frames
-- belong to the daemon's PID, so an exec-rule workspace token never matches.
local emacs_ws3 = hl.window_rule({
    name = "emacs-login-workspace",
    match = { class = "^emacs$" },
    workspace = "3 silent",
})
local emacs_ws3_sub
emacs_ws3_sub = hl.on("window.open", function(w)
    if w and w.class == "emacs" then
        emacs_ws3:set_enabled(false)
        emacs_ws3_sub:remove()
    end
end)

hl.window_rule({
    name = "Float Noctalia Settings",
    match = {
        class = "dev.noctalia.Noctalia",
    },
    float = true,
    size = { 1080, 920 },
})

-- Scratchpad: a floating window in the special:magic workspace, centered and
-- slightly translucent so the workspace behind it stays readable.
hl.window_rule({
    name = "Scratchpad",
    match = {
        workspace = "special:magic",
    },
    float = true,
    center = true,
    size = { "monitor_w * 0.8", "monitor_h * 0.8" },
    opacity = "0.95 0.95",
})


-- Noctalia shell color overrides (sourced last to override border colors).
-- The file is generated by Noctalia and not tracked, so a missing one just means default borders.
pcall(require, "noctalia.noctalia-colors")
