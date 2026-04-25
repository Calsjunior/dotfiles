require("full-border"):setup()
require("simple-tag"):setup({
    ui_mode = "icon",
    colors = {
        ["c"] = "green",
    },
    icons = {
        ["c"] = "󰄲 ",
    },
})

function Entity:icon()
    local icon = self._file:icon()
    if not icon then
        return ui.Span("")
    end

    local span = ui.Span(icon.text .. " ")

    local hovered = cx.active.current.hovered
    if hovered and tostring(hovered.url) == tostring(self._file.url) then
        return span
    end

    if self._file.cha.is_dir then
        return span:fg("blue")
    end

    if icon.style then
        return span:style(icon.style)
    else
        return span
    end
end
