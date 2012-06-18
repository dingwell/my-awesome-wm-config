---------------------------
-- Designed to work with --
-- Xfce4 (Xubuntu 11.10) --
---------------------------

-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Widgets library (basic)
require("vicious")
-- (custom) dmenu-like freedesktop.menu:
require("menubar")
-- Load Debian menu entries (redundant?)
require("debian.menu")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(".config/awesome/themes/adam/theme.lua")
-- beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "sakura" or "xterm"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating, --1
    awful.layout.suit.tile, --2
--    awful.layout.suit.tile.left,
--    awful.layout.suit.tile.bottom,
--    awful.layout.suit.tile.top,
    awful.layout.suit.fair, --3
    awful.layout.suit.fair.horizontal, --4
--    awful.layout.suit.spiral,
--    awful.layout.suit.spiral.dwindle,
--    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen, --5
--    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
  names = {"1-W ", "2-@ ", "3-N ", "4-# ", "5-F ",
  	   "-6-", "-7-", "-8-", "-9-"},
  layout = { layouts[2], layouts[2], layouts[2],layouts[3], layouts[4],
  	     layouts[2], layouts[2], layouts[2], layouts[2]
}}

for s = 1, screen.count() do
    -- Each screen has its own tag table.
--    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts)
    tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Menubar
menubar.cache_entries = true   -- Cache entire tree on firt run (faster searching, must be updated manually)
menubar.app_folders = { "/usr/share/applications/" }
menubar.show_categories = true   -- Change to false if you want only programs to appear in the menu

-- menubar doesn't read the index.theme tables but assumes themes are in /usr/share/icons/
-- and hold the structure .../size/category (some themes use .../category/size)
--menubar.set_icon_theme("Drakfire Evolution Inverted (custom)")
--menubar.set_icon_theme("Humanity")
menubar.set_icon_theme("gnome")

-- {{{ Wibox

-- Network usage widget
-- Initialize widget
netwidget    = widget({type = "textbox" })
dnicon	     = widget({ type = "imagebox" })
upicon	     = widget({ type = "imagebox" })
dnicon.image = image(beautiful.widget_net)
upicon.image = image(beautiful.widget_netup)

--Register widget
vicious.register(netwidget, vicious.widgets.net, '<span color="#CC9393">${eth0 down_kb}</span> <span color="#7F9F7F">${eth0 up_kb}</span>', 3)

-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

-- Create a systray
mysystray = widget({ type = "systray" })

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
    mywibox[s] = awful.wibox({ position = "top", screen = s })
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
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

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
              end),
     awful.key({ modkey }, "s", function () menubar.show() end)
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
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Setup Firefox
    { rule = { class = "Firefox", instance = "Navigator" }, -- Main window
      properties = { tag = tags[1][1], floating = false } },
    { rule = { name = "Enter name of file to save to..." }, --Save file dialog
      properties = { floating = true } },
    { rule = { class = "Firefox", instance = "Dialog" },  -- other dialogs (add class firefox to rules?)
      properties = { floating = true } },
    { rule = { class = "Firefox", name = "Downloads" }, --dowload window
      properties = {}, callback = awful.client.setslave },
    -- Set Claws to always map on tag 1 of screen 1, and disable float
    { rule = {class = "Claws-mail", role = "mainwindow"}, -- role option doesn't work...
      properties = {tag = tags[1][2], floating = false } },
    { rule = {class = "Claws-mail", role ~= "mainwindow"}, -- role option doesn-t work...
      properties = { floating = true } },
    -- Set NixNote to always map on tag 3 screen 1:
    { rule = {name = "NixNote"},    -- Main window
      properties = {tag = tags[1][3], floating = false } },
    { rule = {name = "Database Password", class = "Qt Jambi application"},  -- Password prompt
      properties = {tag = tags[1][3], floating = true } },
    { rule = {name = "Qt Jambi application", class = "Qt Jambi application"}, -- Splash screen (sadly this uses standard Qt Jambi names, and could apply to pretty much anything...)
      properties = {tag = tags[1][3], floating = true } },
    { rule = {name = "Search All Notes", class = "Tomboy"},
      properties = {tag = tags[1][3], floating = false } },
    -- Set Plot windows to always map on tag 5 on screen 1, 
    { rule = { name = "Figure [0-9].*"},  --mainly ment for matlab but will probably mess some other stuff up, if this happens I could add some exception rules (see documentation for except() )
      properties = { tag = tags[1][5], floating = false } },
    { rule = { class = "Pybliographer" },   --referencer
      properties = { tag = tags[1][6], floating = false } },
    { rule = { name = "Error (pybliographer)" },    -- Apply this AFTER main rule for Pybliographer
      properties = { floating = true }},
    -- Applications launched with '--name=set_on_tagX' should be put on tag X (command may vary)
    { rule = { instance = "set_on_tag4"},
      properties = { tag = tags[1][4] } },
    { rule = { instance = "set_on_tag7"},
      properties = { tag = tags[1][7] } },
}
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

-- Run dropbox without nautilus (installed to be used with nautilus)
--  run_once("dropbox",nil,"~/.dropbox-dist/dropboxd")
--  awful.util.spawn_with_shell("run_once.sh ~/.dropbox-dist/dropboxd")
run_once("dropbox","start")

-- is pulseaudio run by another user? (error mes. recieved)
--  run_once("pulseaudio")           -- the Pulse audio system
run_once("conky")                 -- Status panel
--run_once("xfsettingsd")	        -- Handles themes?
run_once("nm-applet")		        -- a Network manager applet
--update-notifier		            -- Checks for updates (will crash the session!?)
--system-config-printer-applet	    -- System tray print job manager
run_once("blueman-applet")	    -- Managing bluetooth devices
-- gnome-power-manager &            -- for laptops and stuff
-- gnome-volume-manager &           -- for mounting CDs, USB sticks, and such
-- run_once("nixnote",nil,"/bin/sh /usr/bin/nixnote")  -- Run nixnote, fund pname: ps -AF|grep nixnote -i (match with a ps -A)
run_once("tomboy","--search")                           -- Run note taking app
run_once("~/bin/run_claws-mail.sh",nil,"claws-mail")    -- Run e-mail client
run_once("/usr/bin/firefox",nil,"firefox")              -- Run browser
run_once("sakura --name=set_on_tag4 & sakura --name=set_on_tag4 & sakura --name=set_on_tag4 & sakura --name=set_on_tag4",nil,"sakura")  -- Run four terminals (set to tag 4, see rules)
run_once("~/bin/open_work.sh",nil,"open_work.sh")       -- Run Document stuff
run_once("pybliographic","~/Documents/Shared/phd/bibliography.bib","/usr/bin/pyblio") -- Referencer


-- Finally, use wmctrl to launch four sessions of sakura on tag 4
-- If there are any instances of sakura running, this will not be excecuted (see run_once)
-- LATER! (there is no utility to spawn commands under specific tags, there is a workaround using rules and callback but I doubt this is a good idea if awesome is restarted...
--- }}}

--- {{{ Autostop applications
-- todo add backup scripts to be run on exit
-- Backup Documents and bin directories:
awesome.add_signal("exit",function() awful.util.spawn("autostop.sh") end)
--- }}}
