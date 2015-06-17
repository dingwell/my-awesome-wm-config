---------------------------
-- Designed to work with --
-- Xfce4 (Xubuntu 14.04) --
---------------------------

-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
require("beautiful")          -- Theme handling library
require("naughty")            -- Notification library
require("vicious")            -- Widgets library (basic)
--require("menubar")            -- (custom) dmenu-like freedesktop.menu (remove?)
require("debian.menu")        -- Load Debian menu entries

-- {{{ Variable definitions
home = os.getenv("HOME")      -- Path to home directory
-- Themes define colours, icons, and wallpapers
  -- I use nitrogen to set the wallpaper, this can be 
  -- disabled by commenting out the following lines or 
  -- by switching to a different theme.
  -- Note that my theme has been modified to handle this...
  wallpapertool = "nitrogen " .. 
    home .. "/Pictures/wallpapers"    -- For myawesomemenu
  wallpapercmd  = "nitrogen --restore &"  -- For theme.lua
beautiful.init(home .. "/.config/awesome/themes/adam/theme.lua")
-- beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")

-- Define some default programs 
-- This does not apply for the entire Xsession
-- but is used internally by awesome for autostart
-- and creating the launch menu
terminal      = "sakura" or "xterm"
editor        = os.getenv("EDITOR") or "vim"
editor_cmd    = terminal .. " -e " .. editor
filemanager   = "thunar" or "nautilus"
wwwbrowser    = "firefox"   -- Note: rules only apply for firefox!

-- Custom Quit command:
quit_cmd      = 'quit_awesome.sh' -- w/ custom autostop
--quit_cmd      = "'awesome.quit()' | awesome-client" -- no autostop

-- Default modkey.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = {
    awful.layout.suit.floating, --1
    awful.layout.suit.tile, --2
--    awful.layout.suit.tile.left,
--    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top, --3
    awful.layout.suit.fair, --4
    awful.layout.suit.fair.horizontal, --5
--    awful.layout.suit.spiral,
--    awful.layout.suit.spiral.dwindle,
--    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen, --6
--    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
  -- Used for defaults and screen 1:
  names   = { "1-W ", "2-@ ", "3-N ", "4-# ", "5-F ",
  	          "-6-", "-7-", "-8-", "-9-" },
  layout    = { layouts[2], layouts[3], layouts[2],layouts[5], layouts[5],
  	            layouts[2], layouts[2], layouts[2], layouts[2] },
  -- Used for screen 2:
  names2  = { "1-FM ", "2-# ", "-3-" },
  layout2 = { layouts[2], layouts[3], layouts[2] }
}

for s = 1, screen.count() do
    -- Each screen has its own tag table.
    if s==1 then                      -- Screen 1 uses default table
      tags[s] = awful.tag(tags.names, s, tags.layout)
    elseif s==2 then                  -- Screen 2 uses spc. table
      tags[s] = awful.tag(tags.names2, s, tags.layout2)
    else                              -- Additional screens use def.
      tags[s] = awful.tag(tags.names, s, tags.layout)
    end
end
-- Special settings for tags
awful.tag.viewonly(tags[1][7])  
awful.tag.incmwfact(0.20, tags[1][1])

awful.tag.viewonly(tags[1][1])  -- Select which tag to edit
awful.tag.incmwfact(0.35, tags[1][1]) -- Move the master-slave divisor
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome", beautiful.menu_manual_icon},
   { "Set Wallpaper", wallpapertool, beautiful.menu_wallpaper_icon},
   { "Restart Conky", "restart_conky.sh", beautiful.menu_restart_icon},

   { "Edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua", beautiful.menu_edit_icon},
   { "Test config", "test_awesome.sh", beautiful.menu_test_icon },
   { "Restart", awesome.restart, beautiful.menu_restart_icon},
   --{ "quit", awesome.quit }
   { "Quit", quit_cmd, beautiful.menu_quit_icon}
}

myappsmenu = {
   { "Claws Mail", "claws-mail", "/usr/share/pixmaps/claws-mail.png"},
   --{ "Diana","diana","/usr/local/share/pixmaps/diana.png"},
   { "Firefox", "firefox", beautiful.menu_firefox_icon },
   { "Inkscape (Xephyr)","run_inkscape_under_xephyr.sh",
      "/usr/share/pixmaps/inkscape.xpm"},
   { "KeePass2 (USB)","external_keepass.sh","/usr/share/pixmaps/keepass2.png"},
   { "Thunar Files", "thunar", beautiful.menu_files_icon }
   --{ "Tomboy Notes", "tomboy", "/usr/share/pixmaps/tomboy-32.xpm"}
}

myofficemenu = {
   { "Claws Mail", "claws-mail", "/usr/share/pixmaps/claws-mail.png"},
   { "Libre Office Calc", "libreoffice --calc", beautiful.menu_office_calc_icon},
   { "Libre Office Impress", beautiful.menu_office_impress_icon},
   { "Libre Office Write", "libreoffice --writer", beautiful.menu_office_write_icon},
   { "PDF Chain","pdfchain","/usr/share/app-install/icons/pdfchain.png"},
   { "Pybliographer", "pybliographer", "/usr/share/pixmaps/pybliographic.png"},
   { "Screen Ruler","screenruler","/usr/share/pixmaps/screenruler.png"},
   { "Zim Notes", "zim", "/usr/share/pixmaps/zim.png"}
}

--mydesktopsmenu = {
--   { "XFCE-desktop","run_xfce_xephyr.sh","/usr/share/pixmaps/xfce4_xicon3.png"}
--}

mydevelopmentmenu = {
   { "Geany IDE", "geany", "/usr/share/pixmaps/geany.xpm"},
   { "gitg Git viewer", "gitg", "/usr/share/pixmaps/gtg.xpm"}
}

mysysmenu = {
  { "Disk Usage", "baobab", "/usr/share/pixmaps/baobab.xpm"},
  { "Time and Date", "gksu system-config-date"}
}

mymainmenu = awful.menu({ items = {
         { "awesome", myawesomemenu, beautiful.awesome_icon },
         { "Applications", myappsmenu, beautiful.menu_apps_icon },
         { "Development", mydevelopmentmenu,
            "/usr/share/app-install/icons/kbibtex.png"},
--         { "Desktops (nested)", mydesktopsmenu, beautiful.desktop_icon},
         { "Office", myofficemenu, beautiful.menu_office_icon},
         { "System Tools", mysysmenu,
            "/usr/share/pixmaps/synaptic.png" },
         { "Debian", debian.menu.Debian_menu.Debian, beautiful.menu_debian_icon },
         { "open terminal", terminal, beautiful.menu_terminal_icon }
      }
})

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Menubar
--menubar.cache_entries = true   -- Cache entire tree on firt run (faster searching, must be updated manually)
--menubar.app_folders = { "/usr/share/applications/" }
--menubar.show_categories = true   -- Change to false if you want only programs to appear in the menu

-- menubar doesn't read the index.theme tables but assumes themes are in /usr/share/icons/
-- and hold the structure .../size/category (some themes use .../category/size)
--menubar.set_icon_theme("Drakfire Evolution Inverted (custom)")
--menubar.set_icon_theme("Humanity")
--menubar.set_icon_theme("gnome")

-- {{{ Wibox

-- Network usage widget
-- Initialize widget
netwidget    = widget({type = "textbox" })
dnicon	     = widget({ type = "imagebox" })
upicon	     = widget({ type = "imagebox" })
dnicon.image = image(beautiful.widget_net)
upicon.image = image(beautiful.widget_netup)

--Register widget
vicious.register(netwidget, vicious.widgets.net, '<span color="#CC9393">${eth0 down_mb}</span> <span color="#7F9F7F">${eth0 up_mb}</span>', 3)

-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a keyboard layout switcher
--kbdcfg = {}
--kbdcfg.cmd = "setxkbmap"
--kbdcfg.layout = { "se", "se -variant dvorak" }  -- argument to set layout
--kbdcfg.name = { "SE", "DV" }  -- Short name for display only
--kbdcfg.current = 1  -- se is our default layout
--kbdcfg.widget = widget({ type = "textbox", align = "right" })
--kbdcfg.widget.text = " " .. kbdcfg.name[kbdcfg.current] .. " "
--kbdcfg.switch = function ()
--  kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
--  local t = " " .. kbdcfg.layout[kbdcfg.current] .. " "
--  kbdcfg.widget.text = " " .. kbdcfg.name[kbdcfg.current] .. " "
--  os.execute( kbdcfg.cmd .. t )
--end

---- Mouse bindings for keyboard layout switcher
--kbdcfg.widget:buttons(awful.util.table.join(
--awful.button({ }, 1, function () kbdcfg.switch() end)
--))

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ screen = s,
      height = 18,
      position = "top"
    })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
	s == 1 and mysystray or nil,
  --kbdcfg.widget,
	upicon,
	netwidget,  
	dnicon,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ "Control", "Mod1" }, "l", function () awful.util.spawn("lockscreen.sh") end), --Mod1=Alt

    awful.key({ modkey, "Control" }, "r", awesome.restart),
    --awful.key({ modkey, "Shift"   }, "q", awesome.quit),
    awful.key({ modkey, "Shift"   }, "q",
      function() awful.util.spawn(quit_cmd) end),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
     --awful.key({ modkey }, "s", function () menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
--[[
   
   name: Rules
   @param
   @return
   
]]--
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    -- Application specific rules
    --{ rule = { protocols = ".*WM_TAKE_FOCUS.*" }, --not working
    --  properties = { floating = true } },
    { rule = { class = "Diana.bin*" },
      properties = { floating = true },
      callback = function (c)
        awful.placement.centered(c,nil)
      end
    },
    { rule = { class = "feh" },
      properties = { floating = true } },
    { rule = { name = "ImageMagick" },
      properties = { floating = true } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
--    { rule = { class = "gimp" },
--      properties = { floating = true } },
    { rule = { class = "Gimp" }, except = { name = "GNU Image Manipulation Program" },
      properties = { floating = true, ontop = true, opacity = 1.0} },
    { rule = { class = "Sozi.py" },
      properties = { floating = true } },
    { rule = { class = "Gtk-recordMyDesktop" },
      properties = { floating = true } },
    -- Setup Terminal Emulator
--  { rule = { class = terminal },  -- If terminal name is the same as window class
    { rule = { class = "Sakura" },
      properties = { floating = true },
      properties = { opacity = 0.8 } },
    -- Setup Firefox
    { rule = { class = "Firefox", instance = "Navigator" }, -- Main window
      properties = { tag = tags[1][1], floating = false } },
    { rule = { name = "Enter name of file to save to..." }, --Save file dialog
      properties = { floating = true } },
    { rule = { class = "Firefox", instance = "Dialog" },  -- other dialogs (add class firefox to rules?)
      properties = { floating = true } },
    { rule = { class = "Firefox", name = "Downloads" }, --download window
      properties = {}, callback = awful.client.setslave },
    --{ rule = { class = "Firefox", name = ".*Properties.*" },  -- Consider windows with properties in name as floating
    --  properties = { floating = true } }, -- not working
    -- Set Claws to always map on tag 1 of screen 1, and disable float
    { rule = {class = "Claws-mail"},    -- Default rule for claws mail (anything not covered by other rules)
      properties = {floating = true} },  
    { rule = {class = "Claws-mail"},    -- All claws-mail windows we want to tile
      except_any = { role = {"prefs"}, type = {"dialog"} }, -- except most dialogues and preferences windows
      properties = {tag = tags[1][2], floating = false} },  
    { rule = {class = "Claws-mail"},  -- All claws-mail windows except the main window are slaves
      except = {role = "mainwindow"},
      callback = awful.client.setslave },
    -- Set NixNote to always map on tag 3 screen 1:
--  { rule = {name = "NixNote"},    -- Main window
--    properties = {tag = tags[1][3], floating = false } },
--  { rule = {name = "Database Password", class = "Qt Jambi application"},  -- Password prompt
--    properties = {tag = tags[1][3], floating = true } },
--  { rule = {name = "Qt Jambi application", class = "Qt Jambi application"}, -- Splash screen (sadly this uses standard Qt Jambi names, and could apply to pretty much anything...)
--    properties = {tag = tags[1][3], floating = true } },
    -- Tomboy Notes (main window)
    { rule_any = {  class = {"Tomboy"},
                    name  = {"Zim notebook - Zim"} },
      properties = {tag = tags[1][3], floating = false } },
    { rule = {name = "zyGrib"},
      properties = { floating = false } },
    { rule = { class = "Conky" },
      properties = { sticky = true } },
    -- Scientific Apps:
    -- Set Plot windows to always map on tag 5 on screen 1, 
    { rule_any = { name   = {"Figure [0-9].*"},  -- Works with e.g. matlab, python
                   class  = {"Octave"} },
      properties = { tag = tags[1][5], floating = false } },
    -- Bibliography manager:
    { rule = { class = "Pybliographer" },   --referencer
      properties = { tag = tags[1][6], floating = false } },
    -- ncview:
    { rule = { class = "Ncview" }, -- General (Main window + plots)
      properties = { floating = true } },
    { rule = { instance = "ncview" }, -- Main window
      properties = { opacity = 0.8 } },
    -- Screen Ruler:
    { rule = { name = "Screen Ruler" }, -- On-screen ruler
      properties = {
        border_width = 0,
        focus = false,
        ontop = true,
        opacity = 0.7,
        floating =true } },
-- FLOATING WINDOWS (for dialogs: centered on workspace)
    { rule_any = { name = {"Choose",
                           "Error (pybliographer)",
                           "Open",
                           "Open file",
                           "File Operation Progress",
                           "cryptkeeper",
                           "Mount stash"},
                   instance = {"Floating window",
                               "xgks"} },
      properties = { floating = true,
                      opacity = 0.9,
                      ontop = true},
      callback = function(c)
        awful.placement.centered(c,nil)
      end },
-- FLOATING WINDOWS (for apps in the indicator field: upper right corner)
    { rule_any = { class = {"KeePass2",
                            "Ubuntuone-installer",
                            "Ubuntu-sso-login-qt",
                            "SpiderOak",
                            "Shutter",
                            "Gtg"},
                   name  = {"Import File/Data"} },
      properties = { floating = true,
                     opacity = 0.9,
                     ontop = true,
                     --sticky = true,
                      border_width = 0 },
      callback = function(c)
        local screengeom = screen[mouse.screen].workarea
        local width  = math.floor(math.max(screengeom.width*0.25,650))
        --local height = math.floor(math.max(screengeom.height*0.40,350))
        local height = math.floor(math.max(screengeom.height*1.00,350))
        local x = screengeom.width-width
        local y = mywibox[mouse.screen].height  -- Panel height (assume top panel)
        c:geometry({ x=x, y=y, width = width, height = height })
      end },

    -- Applications launched with '--name=set_on_tagX' should be put on tag X (command may vary)
    { rule = { instance = "set_on_s1t4"},
      properties = { tag = tags[1][4] } },
    { rule = { instance = "set_on_s1t7"},
      properties = { tag = tags[1][7] } },
    { rule = { instance = "set_on_s1t9"},
      properties = { tag = tags[1][9] } },
    -- For Python development:
    { rule = { class = "Tk" },
      properties = { floating = true } },
}
if screen.count() == 1 then   -- Rules specific to single monitor setup
    nr = #awful.rules.rules   -- Current number of rules
    nr = nr+1                 -- Index for next rules
    awful.rules.rules[nr] = {                     -- Append new rule
        rule = { class = "Hamster-.*" },--
        --properties = { tag = tags[1][8] } }       --
        properties = {
          floating = true,
          sticky=true,
          border_width = 0,
          focus = false,
          ontop = true,
          opacity = 0.9 },
          callback = function(c)
            local screengeom = screen[mouse.screen].workarea
            local width  = math.floor(math.max(screengeom.width*0.25,650))
            local height = math.floor(math.max(screengeom.height*0.40,350))
            local x = screengeom.width-width
            local y = mywibox[mouse.screen].height  -- Panel height (assume top panel)
            c:geometry({ x=x, y=y, width = width, height = height })
          end }
elseif  screen.count() > 1 then   -- Rules specific to dual monitor setup
    nr = #awful.rules.rules   -- Current number of rules
    nr = nr+1                 -- Index for next rule
    awful.rules.rules[nr] = {               -- Append new rule
          rule = { instance = "set_on_s2t1"}, --
          properties = { tag = tags[2][1] } } --
    nr = nr+1                 -- Update index for next rule
    awful.rules.rules[nr] = {               -- Append new rule
          rule = { instance = "set_on_s2t2"}, --
          properties = { tag = tags[2][2] } } --
    nr = nr+1                 -- Update index for next rule
    awful.rules.rules[nr] = {               -- Append new rule
        rule = { instance = "set_on_s2t3"}, --
        properties = { tag = tags[2][3] } } --
    nr = nr+1                 -- Update index for next rule
    awful.rules.rules[nr] = {                     -- Append new rule
        rule = { class = "Hamster-.*" },--
        properties = { tag = tags[2][3] } }       --
  end
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}


-- This function will be used to autostart applications
-- It will only run applications not already running
-- it should also be able to discern between users' apps
function run_once(prg,arg_string,pname,screen)
    if not prg then
        do return nil end
    end

    if not pname then
        pname = prg
    end

    awful.util.spawn_with_shell("echo '" .. prg .. "pid if already running:'")

    if not arg_string then 
--      awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. ")",screen)
        awful.util.spawn_with_shell("pgrep -u $USER -x '" .. pname .. "' || (" .. prg .. ")",screen)
    else
--      awful.util.spawn_with_shell("pgrep -f -u $USER -x '" .. pname .. "' || (" .. prg .. " " .. arg_string .. ")",screen)
        awful.util.spawn_with_shell("pgrep -u $USER -x '" .. pname .. "' || (" .. prg .. " " .. arg_string .. ")",screen)
    end
end


-- {{{ Autostart applications

-- Autostart applications specific to different screen setups
--   Will only be executed if the file /tmp/AWM exists and can
--   be removed (it should be generated by my ~./xinitrc )
if screen.count() == 1 and os.remove("/tmp/AWM") then  -- Only one screen
  -- Launch 4 terminals on first screen (see rules)
  run_once( "sakura --name=set_on_s1t4" .. "&" ..
            "sakura --name=set_on_s1t4" .. "&" ..
            "sakura --name=set_on_s1t4" .. "&" ..
            "sakura --name=set_on_s1t4" .. "&",nil,terminal)
  -- Launch file manager on screen 1 tag 9 (see rules)
  run_once( filemanager .. " --name=set_on_s1t9",nil,filemanager)  
  -- Hamster time tracker
  awful.util.spawn_with_shell( "hamster-time-tracker &")

elseif screen.count() > 1 and os.remove("/tmp/AWM") then  -- Two or more screens
  -- Launch 4 terminals on first screen (see rules)
  awful.util.spawn_with_shell( 
            terminal .. " --name=set_on_s1t4" .. "&" ..
            terminal .. " --name=set_on_s1t4" .. "&" ..
            terminal .. " --name=set_on_s1t4" .. "&" ..
            terminal .. " --name=set_on_s1t4" .. "&",1)
  -- Launch 4 terminals on second screen (see rules)
  awful.util.spawn_with_shell(
            terminal .. " --name=set_on_s2t2" .. 
              " -e octave" .. "&" ..
            terminal .. " --name=set_on_s2t2" .. "&" ..
            terminal .. " --name=set_on_s2t2" .. "&" ..
            terminal .. " --name=set_on_s2t2" .. "&",2) 
  -- Launch file manager on first 2 screens (see rules)
  run_once( filemanager .." --name=set_on_s1t9" .. "&",nil,filemanager,1)
  awful.util.spawn_with_shell( filemanager .." --name=set_on_s2t1",2)
  -- Launch time tracker on screen 2
  awful.util.spawn_with_shell( "hamster-time-tracker &",2)
end


--- }}}

--- {{{ Autostop applications
-- I do not use this since awesome quits too fast for the script to finish, instead I replaced the awesome quit commands in this file. (i.e. the hotkey AND the menu entry) to launch a bash script which will attempt to gracefully quit any applications spawned under the window manager (if someone is interested in this, let me know)
--- }}}
