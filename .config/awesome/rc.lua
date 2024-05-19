--Si LuaRocks está instalado, asegúrese de que los paquetes instalados a través de él sean
--encontrado (por ejemplo, lgi). Si LuaRocks no está instalado, no hagas nada.
pcall(require, "luarocks.loader")

--Impresionante biblioteca estándar
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
--Biblioteca de widgets y diseños
local wibox = require("wibox")
--Biblioteca de manejo de temas
local beautiful = require("beautiful")
--Biblioteca de notificaciones
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")


--Habilite el widget de ayuda de teclas de acceso rápido para VIM y otras aplicaciones
--cuando se abre un cliente con un nombre coincidente:
require("awful.hotkeys_popup.keys")



-- ##### Importando de otros archivos######
require("bar")   -- Importando la polybar
require("keys")  -- Importando shortcuts de teclado
require("color") -- Importando paleta de colores

-- NOTA COLOCAR LA RUTA DEL LA IMAGEN /home/{usario}/.config/awesome/wallpaper/Ruka Sarashina.jpg"
url_wallpaper = "/home/zein/Wallpapers/boy-sttret.jpg"



--{{{ Manejo de errores
--Compruebe si Awesome encontró un error durante el inicio y volvió a
--otra configuración (este código solo se ejecutará para la configuración alternativa)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

--Manejar errores de tiempo de ejecución después del inicio
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        })
        in_error = false
    end)
end
--}}}
--{{{ Definiciones de variables
--Los temas definen colores, íconos, fuentes y fondos de pantalla.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

--Esto se utiliza más adelante como terminal y editor predeterminado para ejecutar.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

--Clave de modificación predeterminada.
--Normalmente, Mod4 es la tecla con un logo entre Control y Alt.
--Si no te gusta esto o no tienes dicha clave,
--Le sugiero que reasigne Mod4 a otra clave usando xmodmap u otras herramientas.
--Sin embargo, puedes usar otro modificador como Mod1, pero puede interactuar con otros.
modkey = "Mod4"

--Tabla de diseños para cubrir con horrible.layout.inc, el orden importa.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Crear un widget de inicio y un menú principal
myawesomemenu = {
    { "hotkeys",     function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual",      terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart",     awesome.restart },
    { "quit",        function() awesome.quit() end },
}


-- Configuración del menú
--beautiful.menu_submenu_icon = "/usr/share/icons/submenu_icon.png" -- Ruta del icono del sub-menú
beautiful.menu_font = "HackNerd Font 16" -- Fuente del texto del menú
beautiful.menu_height = 40               -- Altura de cada ítem del menú
beautiful.menu_width = 200               -- Ancho predeterminado del menú
beautiful.menu_border_color = color_600  -- Color del borde de los ítems del menú
beautiful.menu_border_width = 2          -- Ancho del borde de los ítems del menú
beautiful.menu_fg_focus = color_950      -- Color del texto del ítem enfocado
beautiful.menu_bg_focus = color_700      -- Color de fondo del ítem enfocado
beautiful.menu_fg_normal = color_500     -- Color del texto de los ítems normales
--beautiful.menu_bg_normal = color_950 -- Color de fondo de los ítems normales
--beautiful.menu_submenu = "»" -- Indicador de sub-menú si no se proporciona un icono

mymainmenu = awful.menu({
    items = { { "Awesome", myawesomemenu, beautiful.awesome_icon },
        { "Open Terminal", terminal },
        { "Firefox",       "firefox" },
        { "VS Code",       "code" },
        { "Archivos",      "thunar" }
    }
})

mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = mymainmenu
})



--Indicador y conmutador de mapa de teclado
mykeyboardlayout = awful.widget.keyboardlayout()

--{{{ Wibar
--Crear un widget de reloj de texto
mytextclock = wibox.widget.textclock()

--Crea un wibox para cada pantalla y agrégalo
local taglist_buttons = gears.table.join(awful.button({}, 1, function(t)
        t:view_only()
    end), awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end), 
    awful.button({}, 3, awful.tag.viewtoggle), awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end), 
    awful.button({}, 4, function(t)
        awful.tag.viewnext(t.screen)
    end), 
    awful.button({}, 5, function(t)
        awful.tag.viewprev(t.screen)
    end)
)

-- Distancia de los lados de las ventanas
beautiful.useless_gap = 10
awful.screen.connect_for_each_screen(function(s)
    s.padding = 10
end)


local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal(
                "request::activate",
                "tasklist",
                { raise = true }
            )
        end
    end),
    awful.button({}, 3, function()
        local instance = nil
        return function()
            if instance and instance.wibox.visible then
                instance:hide()
                instance = nil
            else
                instance = awful.menu.clients({ theme = { width = 250 } })
            end
        end
    end)
)

-- #### Funcion para cambiar wallpapers
local function set_wallpaper(s)
    -- Si encontro la imagen del fondo de pantalla
    local f = io.open(url_wallpaper, "r")
    if f ~= nil
    then
        io.close(f)
        gears.wallpaper.maximized(url_wallpaper, s, true) -- un archivo formato imagen
    else
        if beautiful.wallpaper then
            -- Fondo de pantalla
            local wallpaper = beautiful.wallpaper
            -- Si encontro la imagen del fondo de pantalla por defecto
            if type(wallpaper) == "function" then
                wallpaper = wallpaper(s)
            end
            gears.wallpaper.maximized(wallpaper, s, true) -- un archivo formato imagen
        end
        -- NOTA : En este punto se coloca el fondo de pantalla
        gears.wallpaper.set("000000") --un color solido
    end
end

--Restablecer el fondo de pantalla cuando cambia la geometría de una pantalla (por ejemplo, resolución diferente)
screen.connect_signal("property::geometry", set_wallpaper)
--}}}


-- #### Funcion para llamar a la polybar (archivo bar.lua)
polybar(awful, set_wallpaper, tasklist_buttons, wibox, gears, color, taglist_buttons)
--}}}


--{{{ Enlaces del ratón
root.buttons(gears.table.join(
    awful.button({}, 3, function() mymainmenu:toggle() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))
--}}}

-- #### Funcion para cargar los shortcuts / atajo de teclas
relizar_kyes(modkey, awful, hotkeys_popup, gears)

--Establecer claves
root.keys(globalkeys)
--}}}

--{{{ Normas
--Reglas a aplicar a nuevos clientes (a través de la señal "gestionar").
awful.rules.rules = {
    -- Todos los clientes cumplirán esta regla.
    {
        rule = {},
        properties = {
            border_width = 3,                                                              --beautiful.border_width,  -- Establece el ancho del borde de las ventanas usando el valor del tema
            border_color = beautiful.border_normal,                                        -- Establece el color del borde de las ventanas usando el valor del tema
            callback = awful.client.setslave,                                              -- Convierte la ventana en una "esclava" en el esquema de mosaico, no la ventana principal
            focus = awful.client.focus.filter,                                             -- Usa el filtro de enfoque de AwesomeWM para determinar cuándo una ventana debe recibir el foco
            raise = true,                                                                  -- Hace que la ventana se eleve al frente cuando recibe el foco
            keys = clientkeys,                                                             -- Asigna las combinaciones de teclas específicas para las ventanas, definidas previamente en clientkeys
            buttons = clientbuttons,                                                       -- Define los botones del ratón y sus acciones para las ventanas, especificados en clientbuttons
            screen = awful.screen.preferred,                                               -- Asigna la ventana a la pantalla preferida, en sistemas con múltiples monitores
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,         -- Coloca las ventanas de manera que no se solapen entre sí y no queden fuera de la pantalla
            size_hints_honor = false                                                       -- Ignora los consejos de tamaño proporcionados por las ventanas, permitiendo a AwesomeWM manejar el tamaño sin restricciones
        }
    },

    -- Clientes flotantes.
    {
        rule_any = {
            instance = {
                "DTA", -- Complemento de Firefox DownThemAll.
                "copyq", -- Incluye el nombre de la sesión en clase.
                "pinentry",
            },
            class = {
                "Arandr",
                "Blueman-manager",
                "Gpick",
                "Kruler",
                "MessageWin", -- kalarm.
                "Sxiv",
                "Tor Browser", -- Necesita un tamaño de ventana fijo para evitar huellas dactilares por tamaño de pantalla.
                "Wpa_gui",
                "veromix",
                "xtightvncviewer" },

            -- Tenga en cuenta que la propiedad de nombre que se muestra en xprop puede configurarse ligeramente después de la creación del cliente.
            --y es posible que el nombre que se muestra allí no coincida con las reglas definidas aquí.
            name = {
                "Event Tester", -- xev.
            },
            role = {
                "AlarmWindow", -- El calendario de Thunderbird.
                "ConfigManager", -- Thunderbird es sobre:config.
                "pop-up",  -- e.g. Herramientas para desarrolladores de Google Chrome (separadas).
            }
        },
        properties = { floating = true }
    },

    -- Agregar barras de título a clientes y cuadros de diálogo normales
    {
        rule_any = { type = { "normal", "dialog" }
        },
        properties = { titlebars_enabled = true }  -- Para habilitar botones y titulo de las ventanas
    },

    -- Configure Firefox para que siempre se asigne en la etiqueta denominada "2" en la pantalla 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{
-- Función para iniciar aplicaciones automáticamente
local function run_once(cmd_arr)
    for _, cmd in ipairs(cmd_arr) do
        awful.spawn.with_shell("pgrep -u $USER -fx '" .. cmd .. "' || (" .. cmd .. ")")
    end
end

-- Lista de aplicaciones para iniciar automáticamente
local autostart_apps = {
    "picom --config ~/.config/picom/picom.conf", -- Iniciar picom con configuración personalizada
    -- Añade aquí otras aplicaciones que desees iniciar automáticamente
}

run_once(autostart_apps)

-- }}}


-- {{{ Signals
-- Función de señal para ejecutar cuando aparece un nuevo cliente.
client.connect_signal("manage", function(c)
    --Coloque las ventanas en el esclavo,
    --es decir, ponerlo al final de otros en lugar de configurarlo como maestro.
    --si no es awesome.startup entonces horrible.client.setslave(c) finaliza

    if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position then
        -- Evite que los clientes queden inaccesibles después de cambios en el recuento de pantallas.
        awful.placement.no_offscreen(c)
    end
end)

-- Agregue una barra de título si las barras de título habilitadas están configuradas como verdaderas en las reglas.
client.connect_signal("request::titlebars", function(c)
    if beautiful.titlebar_fun then
        -- Si hay una función definida para la barra de título en el tema,
        -- ejecuta esa función y termina aquí.
        beautiful.titlebar_fun(c) -- Ejecuta la función definida para la barra de título, pasando la ventana (c) como argumento
        return                    -- Termina la ejecución de este bloque de código
    end

    -- Si no hay una función definida para la barra de título en el tema,
    -- crea los botones predeterminados para la barra de título.

    -- Define los botones de la barra de título
    local buttons = gears.table.join(
    -- Botón izquierdo del ratón
        awful.button({}, 1, function()
            -- Cuando se hace clic con el botón izquierdo,
            -- activa la ventana y permite moverla arrastrándola con el ratón.
            c:emit_signal("request::activate", "titlebar", { raise = true }) -- Activa la ventana
            awful.mouse.client.move(c)                                     -- Permite mover la ventana
        end),
        -- Botón derecho del ratón
        awful.button({}, 3, function()
            -- Cuando se hace clic con el botón derecho,
            -- activa la ventana y permite cambiar su tamaño arrastrándola con el ratón.
            c:emit_signal("request::activate", "titlebar", { raise = true }) -- Activa la ventana
            awful.mouse.client.resize(c)                                   -- Permite cambiar el tamaño de la ventana
        end)
    )

    awful.titlebar(c, { size = 20 }):setup {
        { -- Izquierda
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        {     -- Medio
            { -- Título
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Derecha
            awful.titlebar.widget.minimizebutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Habilite el enfoque descuidado, para que el enfoque siga al mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {
        raise = vi_focus })
end)

client.connect_signal("focus", function(c)
    c.opacity = "1"
    c.border_color = color_500
end)
client.connect_signal("unfocus", function(c)
    c.opacity = "0.8"
    c.border_color = color_dark_gray
end)


-- {{{
-- Aplicaciones de ejecucion al entorno
awful.util.spawn("picom")                                              --para transparencia
awful.spawn.with_shell("/usr/lib/polkit-kde-authentication-agent-1 &") --Lanzador de ventanas para permisos
--awful.spawn.with_shell("mpd &")--cargar configuracion de reproductor
awful.spawn.with_shell("/usr/bin/pipewire &")                          --controlador de audio
--awful.spawn.with_shell("/usr/bin/pipewire-pulse &")--controlador de audio
--color del listado aplicaciones de segundo plano
beautiful.bg_systray = color_dark_gray

-- }}}




-- Definir una función llamada 'backham'
local function backham()
    -- Obtener la pantalla enfocada actualmente
    local s = awful.screen.focused()
    -- Obtener el cliente que estaba enfocado antes del cambio
    local c = awful.client.focus.history.get(s, 0)
    -- Si hay un cliente disponible
    if c then
        -- Establecer el foco en el cliente
        client.focus = c
        -- Elevar la ventana al frente
        c:raise()
    end
end

-- Conectar la señal "property::minimized" a la función 'backham'
client.connect_signal("property::minimized", backham)

-- Conectar la señal "unmanage" a la función 'backham'
client.connect_signal("unmanage", backham)

-- Conectar la señal "property::selected" de la etiqueta (tag) a la función 'backham'
tag.connect_signal("property::selected", backham)


-- }}}
