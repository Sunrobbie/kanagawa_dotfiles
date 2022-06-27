local awful       = require("awful")
local wibox       = require("wibox")
local beautiful   = require("beautiful")
local gears       = require("gears")
local dpi         = beautiful.xresources.apply_dpi
local pb          = require("widgets.progress_bar")
local shape_utils = require("commons.shape")
local mb          = require("widgets.monitor_stat_bar_std")


local parameters = {}
parameters.max_val = 100
parameters.margin = 15

local ram = mb.create("", parameters)
local cpu = mb.create("", parameters)
local pow = mb.create("", parameters)
local tmp = mb.create("", parameters)

awesome.connect_signal("sysstat::ram", function(used, total)
    local label_val = math.floor(100 * (used / total))
    mb.set_val(ram, parameters, label_val)
    ram[3].text = label_val .. '%'
end)

awesome.connect_signal("sysstat::cpu", function(cpu_val)
    mb.set_val(cpu, parameters, cpu_val)
    cpu[3].text = cpu_val .. '%'
end)

--Alternate widgets using bash commands to get system data
--as sysstat was not working on my system
awful.widget.watch('bash -c "sensors | grep Tctl"', 15, function(widget, stdout)
	out = string.match(stdout, "%d+%.%d")
	mb.set_val(tmp, parameters, tonumber(out))
	tmp[3].text = out .. '°C'
end)

awful.widget.watch('bash -c "acpi"', 15, function(widget, stdout)
	out = string.match(stdout, '%d+%.-%d+')
	mb.set_val(pow, parameters, tonumber(out))
	pow[3].text = out .. '%'
end)

local monitor_panel = wibox.widget(
{
  {
    {
        cpu,
        widget = wibox.container.margin,
        margins = dpi(5)
    },
    {
        ram,
        widget = wibox.container.margin,
        margins = dpi(5)
    },
    {
        pow,
        widget = wibox.container.margin,
        margins = dpi(5)
    },
    {
        tmp,
        widget = wibox.container.margin,
        margins = dpi(5)
    },
    layout = wibox.layout.flex.vertical
  },
  forced_height = dpi(130),
  forced_width = dpi(400),
  widget = wibox.container.background
})

return monitor_panel
