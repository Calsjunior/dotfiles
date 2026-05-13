local scheme = {}
local schemeFile = os.getenv("HOME") .. "/.config/hypr/scheme/current.conf"
for line in io.lines(schemeFile) do
    local key, value = line:match("^%$([%w_]+)%s*=%s*(%x+)")
    if key and value then
        scheme[key] = value
    end
end
return scheme
