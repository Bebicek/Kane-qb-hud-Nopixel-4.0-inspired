local ESX = exports['es_extended']:getSharedObject()
local ResetStress = false
local PlayerStress = {}

ESX.RegisterCommand('cash', 'user', function(xPlayer)
    local cashamount = xPlayer.getMoney()
    TriggerClientEvent('hud:client:ShowAccounts', xPlayer.source, 'cash', cashamount)
end, false, { help = 'Check Cash Balance' })

ESX.RegisterCommand('bank', 'user', function(xPlayer)
    local bankAccount = xPlayer.getAccount('bank')
    local bankamount = bankAccount and bankAccount.money or 0
    TriggerClientEvent('hud:client:ShowAccounts', xPlayer.source, 'bank', bankamount)
end, false, { help = 'Check Bank Balance' })

ESX.RegisterCommand('dev', 'admin', function(xPlayer)
    TriggerClientEvent('hud:client:ToggleDevmode', xPlayer.source)
    TriggerClientEvent('qb-admin:client:ToggleDevmode', xPlayer.source)
end, false, { help = 'Enable/Disable developer Mode' })

RegisterNetEvent('hud:server:GainStress', function(amount)
    if Config.DisableStress then return end
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    local job = xPlayer.job and xPlayer.job.name
    local jobType = xPlayer.job and xPlayer.job.type
    if Config.WhitelistedJobs[job] or (jobType and Config.WhitelistedJobs[jobType]) then return end
    if not PlayerStress[src] then PlayerStress[src] = 0 end
    local newStress
    if not ResetStress then
        newStress = (PlayerStress[src] or 0) + amount
        if newStress <= 0 then newStress = 0 end
    else
        newStress = 0
    end
    if newStress > 100 then
        newStress = 100
    end
    PlayerStress[src] = newStress
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    TriggerClientEvent('esx:showNotification', src, Lang:t('notify.stress_gain'))
end)

RegisterNetEvent('hud:server:RelieveStress', function(amount)
    if Config.DisableStress then return end
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    if not PlayerStress[src] then PlayerStress[src] = 0 end
    local newStress
    if not ResetStress then
        newStress = PlayerStress[src] - amount
        if newStress <= 0 then newStress = 0 end
    else
        newStress = 0
    end
    if newStress > 100 then
        newStress = 100
    end
    PlayerStress[src] = newStress
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    TriggerClientEvent('esx:showNotification', src, Lang:t('notify.stress_removed'))
end)

ESX.RegisterServerCallback('hud:server:getMenu', function(_, cb)
    cb(Config.Menu)
end)

AddEventHandler('esx:playerLoaded', function(playerId)
    PlayerStress[playerId] = PlayerStress[playerId] or 0
end)

AddEventHandler('playerDropped', function()
    PlayerStress[source] = nil
end)
