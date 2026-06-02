local M = {}

-- Hardcode monitor and its mode until the API allows fetching those values
local MONITOR_RATES = {
    ["eDP-1"] = { min = 60, max = 144 },
    ["DP-3"] = { min = 60, max = 165 },
}

function M.toggle_refresh_rate()
    local monitors = hl.get_monitors()
    local target_m = nil
    for _, m in ipairs(monitors) do
        if m.focused then
            target_m = m
            break
        end
    end
    if not target_m then
        return
    end

    local rates = MONITOR_RATES[target_m.name]
    if not rates then
        return
    end

    local current_rate = math.floor(target_m.refresh_rate + 0.5)
    local target_rate = (current_rate >= rates.max) and rates.min or rates.max

    hl.monitor({
        output = target_m.name,
        mode = target_m.width .. "x" .. target_m.height .. "@" .. target_rate,
        position = target_m.x .. "x" .. target_m.y,
        scale = target_m.scale,
    })

    os.execute("notify-send 'Refresh Rate' 'Set to " .. target_rate .. "Hz'")
end

return M
