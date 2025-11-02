local Locale = {}
Locale.__index = Locale

function Locale:new(data)
    local phrases = data and data.phrases or {}
    local warn = data and data.warnOnMissing
    local obj = {
        phrases = phrases,
        warnOnMissing = warn,
    }
    return setmetatable(obj, Locale)
end

local function resolve(phrases, key)
    local current = phrases
    for segment in string.gmatch(key, '([^.]+)') do
        current = current and current[segment]
        if current == nil then
            return nil
        end
    end
    return current
end

function Locale:t(key)
    if not key then return '' end
    if type(self) ~= 'table' then
        return key
    end
    local phrase = resolve(self.phrases, key)
    if not phrase and self.warnOnMissing then
        print(('[locale] missing translation for "%s"'):format(key))
        return key
    end
    return phrase or key
end

_G.Locale = Locale

return Locale
