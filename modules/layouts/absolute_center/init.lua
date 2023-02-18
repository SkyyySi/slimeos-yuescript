local wibox = require("wibox")
return function(left, center, right, buttons)
	local center_container = wibox.widget({
		{
			{
				left,
				layout = wibox.layout.fixed.horizontal
			},
			{
				layout = wibox.layout.fixed.horizontal,
				buttons = buttons
			},
			expand = "inside",
			layout = wibox.layout.align.horizontal
		},
		{
			nil,
			{
				center,
				layout = wibox.layout.fixed.horizontal
			},
			layout = wibox.layout.align.horizontal
		},
		{
			nil,
			{
				layout = wibox.layout.fixed.horizontal,
				buttons = buttons
			},
			{
				right,
				layout = wibox.layout.fixed.horizontal
			},
			layout = wibox.layout.align.horizontal
		},
		expand = "outside",
		layout = wibox.layout.align.horizontal
	})
	if callback then
		callback(center_container)
	end
	return center_container
end
