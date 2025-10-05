local blacklisted = {}
for _,w in ipairs(Config.blacklistedWeapons) do blacklisted[w] = true end
local function getLocale(key)
    local t = Config.Locales[Config.Locale] or Config.Locales['en']
    return t[key] or ''
end
local function notify(text)
    local nt = Config.Notify or 'chat'
    if nt == 'okok' then
        if exports and exports['okokNotify'] and exports['okokNotify'].SendNotification then
            exports['okokNotify']:SendNotification(text)
            return
        end
    elseif nt == 'mythic' then
        if exports and exports['mythic_notify'] and exports['mythic_notify'].DoLongHudText then
            exports['mythic_notify']:DoLongHudText('inform', text)
            return
        end
    elseif nt == 'ox' then
        if exports and exports.ox and exports.ox.notify then
            exports.ox:notify(text)
            return
        end
    elseif nt == 'esx' then
        TriggerEvent('esx:showNotification', text)
        return
    end
    TriggerEvent('chat:addMessage', { args = { text } })
end
local function hasAnyBlacklistedWeapon()
    local ped = PlayerPedId()
    if not ped or ped == 0 then return false, nil end
    for name,_ in pairs(blacklisted) do
        local hash = GetHashKey(name)
        if HasPedGotWeapon(ped, hash, false) then
            return true, name
        end
    end
    return false, nil
end
CreateThread(function()
    while true do
        local found, weapon = hasAnyBlacklistedWeapon()
        if found then
            local msg = string.format(getLocale('detected'), weapon)
            notify(msg)
            local ped = PlayerPedId()
            local hash = GetHashKey(weapon)
            RemoveWeaponFromPed(ped, hash)
            notify(string.format(getLocale('removed'), weapon))
            TriggerServerEvent('antiSpawnWeapon:detected', weapon)
            Wait((Config.graceSeconds or 2) * 1000)
        end
        Wait((Config.scanInterval or 5) * 1000)
    end
end)
RegisterNetEvent('antiSpawnWeapon:kickNotify')
AddEventHandler('antiSpawnWeapon:kickNotify', function(text, kickDelay)
    notify(text)
    if kickDelay and type(kickDelay) == 'number' then
        Wait(kickDelay)
    end
end)
CreateThread(function()
    Wait(1000)
    print(('[%s] Lokalní verze %s | GitHub: https://github.com/%s'):format(GetCurrentResourceName(), Config.Version, Config.GitHubRepo))
end)
