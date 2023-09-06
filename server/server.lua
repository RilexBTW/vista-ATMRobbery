local QBCore = exports['qb-core']:GetCoreObject()
local inventory = exports.ox_inventory





RegisterNetEvent('vista-atmrob:server:completeRob')
AddEventHandler('vista-atmrob:completeRob', function()
-- verify that the atm has actually been robbed using player cords and callbacks
    if nearATM then
        if completedRob then
            inventory:AddItem(source, "black_money", Config.Payout)
            QBCore.Functions.Notify(source, 'You got'..Config.Payout.. 'Dirty Money! Now get out of here before the cops get you', 'alert')
        else
            TriggerEvent('vista-atmrob:server:stinky', source)
        end
    else
        TriggerEvent('vista-atmrob:server:stinky', source)
    end
end)


RegisterNetEvent('vista-atmrob:server:stinky')
AddEventHandler('vista-atmrob:server:stinky', function(source)
    DropPlayer(source, 'You smell bad')
    print('Kicked player'..GetPlayerName(source)..'for exploiting')
end)

-- TODO: Add Server Side Check to set timer on ATM (so that players can't rob the same atm by relogging)




-- Callbacks
QBCore.Functions.CreateCallback('fetchvehicletype', function(source, vehicleType, cb)
    cb(GetVehicleType(vehicleType))
end)