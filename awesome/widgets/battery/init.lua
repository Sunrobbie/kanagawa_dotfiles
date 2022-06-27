local awful             = require("awful")
local gears             = require("gears")
local wibox             = require("wibox")
local beautiful         = require("beautiful")
local dpi               = beautiful.xresources.apply_dpi
local icons             = require("commons.icons")
local commands          = require("commons.commands")

is_power_popup_opened = false

local create_btn_container = function(glyph, tooltip, cmd)
  local btn = wibox.widget{
    {
      icons.wbi(glyph, 25),
      margins = 10,
      widget  = wibox.container.margin
    },
    widget  = wibox.container.background,
    shape              = gears.shape.rounded_rect,
    bg                 = beautiful.bg_normal,
    shape_border_color = beautiful.fg_normal,
    shape_border_width = 2
  }


  if cmd then
    btn:connect_signal('button::press', function()
      awful.spawn.with_shell(cmd)
    end)
  end



  return {
      btn,
      margins = 10,
      widget  = wibox.container.margin
  }
end



battery_widget_factory = {}
battery_widget_factory.create = function(parameters)
  local value = 0
  local battery_icon = wibox.widget{
      text    = "",
      align   = parameters.alignment or beautiful.battery_aligment,
      opacity = parameters.opacity or beautiful.battery_opacity,
      font    = beautiful.icons_font .. (parameters.size or beautiful.battery_size),
      widget  = wibox.widget.textbox,
  }

  local battery_icon_t = awful.tooltip {}
  battery_icon_t:add_to_object(battery_icon)
  battery_icon:connect_signal('mouse::enter', function()
    battery_icon_t.text = tostring(value) .. "%"
  end)

  awful.spawn.easy_async([[bash -c 'acpi']], function(stdout, _, _, _)
      pow_val = string.match(stdout, '= (%d+)%%')
      value = tonumber(pow_val)
      if string.match(stdout, 'Charging') == "Charging" then
        battery_icon.text = ""
      elseif pow_val > 75 then
        battery_icon.text = ""
      elseif pow_val > 50 then
        battery_icon.text = ""
      elseif pow_val > 25 then
        battery_icon.text = ""
      elseif pow_val < 25 then
        battery_icon.text = ""
      end
end)


  local pp = awful.popup {
    widget = {
        {
            create_btn_container("", "Shutdown", commands.shutdown),
            create_btn_container("", "Reboot", commands.reboot),
            create_btn_container("X", "Cancel"),
            layout = wibox.layout.fixed.horizontal,
        },
        margins = 10,
        widget  = wibox.container.margin
    },
    type = "dropdown_menu",
    border_width = 5,
    visible = false,
    ontop = true,
    hide_on_right_click = true,
    shape = gears.shape.rounded_rect,
    placement = awful.placement.centered
  }

  battery_icon:connect_signal('button::press', function()
    is_power_popup_opened = not is_power_popup_opened
    pp.visible = is_power_popup_opened
  end)

  return battery_icon

end

return battery_widget_factory
