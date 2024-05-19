-- Theme handling library
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
--local awful = require("awful")

require("color") -- Importando paleta de colores

-- Función para dibujar un rectángulo redondeado
local function draw_rounded_rect(cr, width, height, radius)
    cr:move_to(0, radius)
    cr:arc(radius, radius, radius, math.pi, math.pi * 1.5)
    cr:line_to(width - radius, 0)
    cr:arc(width - radius, radius, radius, math.pi * 1.5, 0)
    cr:line_to(width, height - radius)
    cr:arc(width - radius, height - radius, radius, 0, math.pi * 0.5)
    cr:line_to(radius, height)
    cr:arc(radius, height - radius, radius, math.pi * 0.5, math.pi)
    cr:close_path()
end



function polybar(awful, set_wallpaper, tasklist_buttons, wibox, gears, color, taglist_buttons)
    awful.screen.connect_for_each_screen(function(s)

        --awful.screen.connect_signal("request::desktop_decoration", function(s)
        -- Wallpaper
        set_wallpaper(s)

        --Cada pantalla tiene su propia tabla de etiquetas.
        awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])

        --Crear un cuadro de aviso para cada pantalla
        s.mypromptbox = awful.widget.prompt()
        --Cree un widget de cuadro de imagen que contendrá un icono que indique qué diseño estamos usando.
        --Necesitamos un cuadro de diseño por pantalla.

        s.mylayoutbox = awful.widget.layoutbox(s)
        s.mylayoutbox:buttons(gears.table.join(
            awful.button({}, 1, function() awful.layout.inc(1) end),
            awful.button({}, 3, function() awful.layout.inc(-1) end),
            awful.button({}, 4, function() awful.layout.inc(1) end),
            awful.button({}, 5, function() awful.layout.inc(-1) end))
        )

        --Crear un widget de lista de etiquetas
        s.mytaglist = awful.widget.taglist {
            screen  = s,
            filter  = awful.widget.taglist.filter.all,
            style = {
                bg_empty = color_950,
                fg_empty = color_50,
                bg_focus = color_500,
                fg_focus = color_dark_gray,
                bg_occupied = color_800,
                fg_occupied = color_100,
            },

            buttons = taglist_buttons
        }
        -- Crear una caja de widgets para contener la lista de etiquetas
        s.mytaglist_widget = wibox.widget {
            {
                s.mytaglist,
                layout = wibox.layout.flex.horizontal  -- Usa un diseño horizontal
            },
            widget = wibox.container.place,  -- Coloca la lista de etiquetas en el centro
            halign = "center"  -- Alinea la lista de etiquetas horizontalmente al centro
        }

        --Crear un widget de lista de tareas
        s.mytasklist = awful.widget.tasklist {
            screen          = s,
            filter          = awful.widget.tasklist.filter.currenttags,
            margins = {
                top = 30,
                bottom = 30
            },
            style = {
                bg_normal = color_900,
                bg_focus = color_800,
                disable_task_name = true, -- desactiva el nombre de la ventana
                border_width = 2,
                border_color = color_700,
                shape = gears.shape.rounded_bar
            },
            layout = { --etiquetas de la ventana mostrada
                spacing_widget = {
                    {
                        forced_width = 5,
                        forced_height = 24,
                        thickness = 1,
                        color = color_900,
                        widget = wibox.widget.separator
                    },
                    valign = "center",
                    halign = "center",
                    widget = wibox.container.place
                },
                spacing = 10,
                layout = wibox.layout.fixed.horizontal
            },
            buttons = tasklist_buttons,
        }

        
        --Crear la wibox
        s.my_vertical_wibox = awful.wibar({
           
            type = "dock",
            position = "top",
            border_width = 2,--borde
            border_color = color_400,--color de borde
            screen = s,
            height = dpi(30),
            width = "98%",
            bg = color_900, --beautiful.transparent,
            fg = color_200,
            --ontop = true,
            --visible = true,

            stretch = false,
            margins = {
                top = 30,
                bottom = 5
            },
            
            shape = function(cr, width, height)
                draw_rounded_rect(cr, width, height, 5)
            end
        })

        --Agregar widgets al wibox
        s.my_vertical_wibox:setup{
            layout = wibox.layout.align.horizontal,
            --expand = "none",
            { --Widgets de la parte superior
                mylauncher,
                spacing = dpi(20),
                s.mytasklist,
                --spacing = dpi(20),
                --s.mypromptbox,
                layout = wibox.layout.fixed.horizontal,
            },
            
            -- Widget central
            s.mytaglist_widget,

            { -- Widgets de la parte inferior
                --mykeyboardlayout,
                layout = wibox.layout.fixed.horizontal,
                wibox.widget.systray{},
                --spacing = dpi(16),
                --mytextclock,

                -- las terea en segundo plano
                wibox.widget.textclock('%B %d -- %H:%M --'), -- Crear un widget de reloj de texto (https://awesomewm.org/apidoc/widgets/wibox.widget.textclock.html)
                -- informacino de sistema  
                --info(4),       
                --info(3),
                --info(1),
                --info(2),
                --power,
                -- default
                --logout_menu_widget(),
                s.mylayoutbox,
            }
        }
    end)
end
