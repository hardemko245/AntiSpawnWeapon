Config = {}

Config.Locale = 'cs'

Config.Notify = 'okok' -- options: 'okok', 'mythic', 'ox', 'esx', 'chat'

Config.blacklistedWeapons = {
    'WEAPON_RPG',
    'WEAPON_MINIGUN',
    'WEAPON_RAILGUN',
    'WEAPON_RAYPISTOL'
}

Config.kickOnDetect = true
Config.graceSeconds = 2
Config.scanInterval = 5
Config.logWebhook = ''
Config.kickReason = 'Spawned blacklisted weapon.'
Config.whitelistIdentifiers = {}

Config.GitHubRepo = 'hardemko245/AntiSpawnWeapon'
Config.Version = '1.0.0'

Config.Locales = {
    cs = {
        detected = 'Byla zjištěna zakázaná zbraň: %s',
        removed = 'Zakázaná zbraň odstraněna: %s',
        kicked = 'Byl jsi vyhozen: %s'
    },
    en = {
        detected = 'Blacklisted weapon detected: %s',
        removed = 'Blacklisted weapon removed: %s',
        kicked = 'You have been kicked: %s'
    }
}
