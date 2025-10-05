local ESX = nil
if GetResourceState('es_extended') == 'started' then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end
local function isWhitelisted(identifiers)
    for _, id in ipairs(identifiers) do
        for _, w in ipairs(Config.whitelistIdentifiers or {}) do
            if id == w then return true end
        end
    end
    return false
end
local function getIdentifiers(src)
    local ids = {}
    for k,v in pairs(GetPlayerIdentifiers(src)) do table.insert(ids, v) end
    return ids
end
local function webhookLog(name, weapon, reason)
    if not Config.logWebhook or Config.logWebhook == '' then return end
    local data = {
        username = name,
        embeds = {{ title = 'AntiSpawnWeapon', fields = { { name = 'Player', value = name, inline = true }, { name = 'Weapon', value = weapon, inline = true }, { name = 'Reason', value = reason or '' , inline = false } }, footer = { text = 'AntiSpawnWeapon' } }}
    }
    PerformHttpRequest(Config.logWebhook, function() end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json' })
end
local function notifyThenKick(src, reasonText)
    TriggerClientEvent('antiSpawnWeapon:kickNotify', src, reasonText, 800)
    Wait(800)
    DropPlayer(src, reasonText)
end
RegisterNetEvent('antiSpawnWeapon:detected')
AddEventHandler('antiSpawnWeapon:detected', function(weapon)
    local _src = source
    local name = GetPlayerName(_src) or ('Player #'.._src)
    local ids = getIdentifiers(_src)
    if isWhitelisted(ids) then return end
    webhookLog(name, weapon, Config.kickReason)
    if Config.kickOnDetect then
        local locale = Config.Locales[Config.Locale] or Config.Locales['en']
        local kickMsg = string.format(locale.kicked or 'You have been kicked: %s', weapon)
        notifyThenKick(_src, kickMsg)
    end
end)
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    print(('[%s] Verze %s | GitHub: https://github.com/%s'):format(resourceName, Config.Version, Config.GitHubRepo))
    PerformVersionCheck()
end)
function PerformVersionCheck()
    local repo = Config.GitHubRepo
    if not repo or repo == '' then
        print(('[%s] GitHub repo není nastaveno'):format(GetCurrentResourceName()))
        return
    end
    local url = ('https://api.github.com/repos/%s/releases/latest'):format(repo)
    PerformHttpRequest(url, function(status, response, headers)
        if status == 200 and response then
            local ok, data = pcall(json.decode, response)
            if ok and data and data.tag_name then
                local latest = data.tag_name:gsub('v','')
                if latest ~= Config.Version then
                    print(('[%s] Novější verze dostupná: %s (tvá: %s)'):format(GetCurrentResourceName(), latest, Config.Version))
                    print(('[%s] Stáhni aktualizaci: https://github.com/%s/releases'):format(GetCurrentResourceName(), repo))
                else
                    print(('[%s] Jsi na nejnovější verzi (%s)'):format(GetCurrentResourceName(), Config.Version))
                end
            else
                print(('[%s] Nelze zpracovat odpověď GitHubu'):format(GetCurrentResourceName()))
            end
        else
            print(('[%s] Nepodařilo se ověřit verzi na GitHubu (HTTP %s)'):format(GetCurrentResourceName(), tostring(status)))
        end
    end, 'GET', '', { ['User-Agent']='FiveM' })
end
