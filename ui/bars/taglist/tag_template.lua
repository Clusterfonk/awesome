-- @license APGL-3.0 <https://www.gnu.org/licenses/>
-- @author Clusterfonk <https://github.com/Clusterfonk>
local setmetatable = setmetatable
local wibox = require("wibox")
local bt = require("beautiful")
local dpi = bt.xresources.apply_dpi


tag_template = { mt = {} }

-- TODO: redo this without setting the width of it and let it all take place like they need
function tag_template.new(s, bar_width, bar_height)
    local font_size = bar_height / 2

    local available_space = (bar_width / 2) - (bar_height / 2)

    local n_tags = #s.tags / 2
    local spaces = ((n_tags - 1) * 2) + 2

    local tab_ocupied_space = n_tags *font_size * 1.6
    available_space = available_space - tab_ocupied_space
    local tag_spacing = available_space / spaces
    local underline_height = dpi(bt.taglist_underline_height, s)

    return {
    {
        {
            {
                layout = wibox.layout.fixed.vertical,
                spacing = -underline_height/2,
                {
                    {
                        id = 'text_role',
                        widget = wibox.widget.textbox
                    },
                    widget = wibox.container.place,
                },
                {
                    {
                        id = "underline",
                        widget = wibox.container.background,
                        forced_height = underline_height,
                        forced_width = 0.8 * font_size * 2,
                    },
                    widget = wibox.container.place,
                }
            },
            widget = wibox.container.place,
        },
        left = tag_spacing,
        right = tag_spacing,
        widget = wibox.container.margin,
        forced_height = bar_height,
    },
    id = "background_role",
    widget = wibox.container.background,
    create_callback = function(self, tag, index, tags)
        tag:connect_signal("request::select",
            function()
                self:get_children_by_id("underline")[1].bg = bt.taglist_fg_focus
        end)

        tag:connect_signal("request::deselect",
            function()
                self:get_children_by_id("underline")[1].bg = bt.taglist_bg_normal
        end)

        tag:connect_signal("property::urgent", function(t)
            if t.urgent then
                self:get_children_by_id("underline")[1].bg = bt.taglist_fg_focus
            end
        end)

        if tag.selected then
            tag:emit_signal("request::select")
        end
    end
}
end

function tag_template.mt:__call(...)
    return tag_template.new(...)
end

return setmetatable(tag_template, tag_template.mt)
