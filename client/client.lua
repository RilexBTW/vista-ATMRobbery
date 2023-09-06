local QBCore = exports['qb-core']:GetCoreObject()
local inventory = exports.ox_inventory


--[[
Process to Rob ATM:

1) Approach ATM Prop and third eye it
2) If you choose to hack the ATM, then you can hack it using a UART and have a chance to get away with a delayed police noti.
3) If you choose to drill the ATM, then police are notified immediately, but the process is simpler.
4) If you hack the ATM then you get the money without needing a vehicle, but if you use the drill then you have to pull the ATM. Each vehicle type will take a different amount of time to complete the process.
]]


-- Third Eye ATM Entity
-- Third Eye Targets
Citizen.CreateThread(function()
exports.ox_target:addEntity(Config.ATMProps, {
    name = "startdrill",
    radius = 3.0, 
    label = "Start Drilling",
    icon = 'fa-solid fa-male',
    event = "vista-atmrob:startDrilling" 
})

exports.ox_target:addEntity(Config.ATMProps, {
    name = "starthack",
    radius = 3.0, 
    label = "Start Hacking",
    icon = 'fa-solid fa-male',
    event = "vista-atmrob:startHacking" 
})
end)

-- Start Drilling ATM

RegisterNetEvent('vista-atmrob:startDrilling')
AddEventHandler('vista-atmrob:startDrilling', function()

-- Do Drill Anim
QBCore.Functions.PlayAnim(amb@world_human_const_drill@male@drill@base, base, 'false', Config.DrillDuration)
QBCore.Functions.Progressbar("random_task", "Doing something", 5000, false, true, {
    disableMovement = true,
    disableCarMovement = true,
    disableMouse = false,
    disableCombat = true,
 }, {
    animDict = "@world_human_const_drill@ambmale@drill@base",
    anim = "base",
    flags = 49,
 }, {}, {}, function() -- Done
    StopAnimTask(PlayerPedId(), "@world_human_const_drill@ambmale@drill@base", "base", 1.0)
    -- Once Anim finished, allow pulling the ATM
 end, function() -- Cancel
    StopAnimTask(PlayerPedId(), "@world_human_const_drill@ambmale@drill@base", "base", 1.0)
    QBCore.Functions.Notify("You didn't finish drilling the ATM! Get out of here!", 'alert', '300')
 end)



--[[
amb@world_human_const_drill@male@drill@base
	base

amb@world_human_const_drill@male@drill@idle_a
	idle_a
	idle_b
	idle_c
]]





end)

-- Start Pulling ATM

RegisterNetEvent('vista-atmrob:pullATM')
AddEventHandler('vista-atmrob:pullATM', function()

    local playerPed = PlayerPedId()

    -- Check if the player is near the ATM and has the rope attached
    if IsNearATM(playerPed) and IsRopeAttachedToVehicle() then
        local atmCoords = GetEntityCoords(atmObject)
        local vehicleCoords = GetEntityCoords(attachedVehicle)

        -- Calculate the distance between the ATM and the attached vehicle
        local distance = GetDistanceBetweenCoords(atmCoords.x, atmCoords.y, atmCoords.z, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, true)

        -- Calculate the time it takes to pull the ATM based on vehicle type
        local pullTime = CalculatePullTime(vehicleType)

        local playerPed = PlayerPedId()

        -- Check if the player is near the ATM and has the rope attached
        if IsNearATM(playerPed) and not IsRopeAttachedToVehicle() then
            local atmCoords = GetEntityCoords(atmObject)
            local vehicle = GetVehiclePedIsIn(playerPed, false)
    
            if DoesEntityExist(vehicle) then
                -- Attach the rope to the vehicle
                local vehicleCoords = GetEntityCoords(vehicle)
                local ropeHandle = StartRopeWinding(ropeType, ropeLength, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 1.0, true)
                AttachRopeToEntity(ropeHandle, vehicle, 1.0, 0.0, 0.0, false)
                RopeConvertToSimple(ropeHandle)
                ropeObject = ropeHandle
    
                -- Notify the player that the rope is attached to the vehicle
                QBCore.Functions.Notify("Rope attached to the vehicle.")
            end
        end

        if distance <= Config.MaxPullDistance then
            -- Play a pulling animation or perform any other necessary animations

            -- Simulate the pulling process
            QBCore.Functions.Progressbar("pull_atm", "Pulling ATM", pullTime, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function()
                -- Pulling is successful, delete the ATM entity
                DeleteEntity(atmObject)
                atmObject = nil

                -- Notify the player that the ATM has been successfully pulled
                QBCore.Functions.Notify("You successfully pulled the ATM!", 'success')

                -- Trigger server-side code for reward collection and exploit checks
                TriggerServerEvent('vista-atmrob:server:completeRob')

                -- Detach the rope from the vehicle
                DetachRope(playerPed)
            end, function()
                -- Pulling was canceled or interrupted
                QBCore.Functions.Notify("You canceled the ATM pulling!", 'error')

                -- Detach the rope from the vehicle
                DetachRope(playerPed)
            end)
        else
            -- The player is too far from the ATM to pull it
            QBCore.Functions.Notify("You are too far from the ATM to pull it!", 'error')
        end
    else
        -- The player is not near the ATM or does not have the rope attached
        QBCore.Functions.Notify("You need to be near the ATM and have the rope attached to pull it!", 'error')
    end
-- Pull ATM and Collect Reward


end)

-- pull ATM



-- Third Eye Vehicle

-- Connect chain to ATM
-- Unused snippet for right now
 --[[   local ped = PlayerPedId()
    if HoldingElectricNozzle then return end
    local lefthand = GetPedBoneIndex(ped, 18905)
    local pumpCoords, pump = GetClosestPump(grabbedelectricnozzlecoords, true)
    local atmCoords, atm = GetEntityCoords(entity)
    RopeLoadTextures()
    while not RopeAreTexturesLoaded() do
        Wait(0)
        RopeLoadTextures()
    end
    while not atm do
        Wait(0)
    end
    Rope = AddRope(atmCoords.x, atmCoords.y, atmCoords.z, 0.0, 0.0, 0.0, 3.0, Config.RopeType, 8.0 , 0.0, 1.0, false, false, false, 1.0, true)
    while not Rope do
        Wait(0)
    end
    ActivatePhysics(Rope)
    Wait(100)
    -- attach rope to vehicle -- AttachEntitiesToRope(Rope, --vehicletntity, ElectricNozzle, pumpCoords.x, pumpCoords.y, pumpCoords.z + 1.76, nozzlePos.x, nozzlePos.y, nozzlePos.z, 5.0, false, false, nil, nil)
    CreateThread(function()
        while HoldingElectricNozzle do
            local currentcoords = GetEntityCoords(ped)
            local dist = #(grabbedelectricnozzlecoords - currentcoords)
            if not TargetCreated then if Config.FuelTargetExport then exports[Config.TargetResource]:AllowRefuel(true, true) end end
            TargetCreated = true
            if dist > 7.5 then
                if TargetCreated then if Config.FuelTargetExport then exports[Config.TargetResource]:AllowRefuel(false, true) end end
                TargetCreated = true
                HoldingElectricNozzle = false
                DeleteObject(ElectricNozzle)
                if Config.PumpHose == true then
                    if Config.Debug then print("Removing ELECTRIC Rope.") end
                    RopeUnloadTextures()
                    DeleteRope(Rope)
                end
            end
            Wait(2500)
        end
    end)]]


RegisterNetEvent('vista-atmrob:collectReward')
AddEventHandler('vista-atmrob:collectReward', function()

-- Allow ATM on ground to be third eyeable

-- Trigger Server Side Code for exploit checks and give reward
TriggerServerEvent('vista-atmrob:server:completeRob')
end)

RegisterNetEvent('vista-atmrob:startHacking')
AddEventHandler('vista-atmrob:startHacking', function()
    TriggerEvent("mhacking:show")
    TriggerEvent("mhacking:start", math.random(5, 9), math.random(10, 15), function()
        TriggerServerEvent('vista-atmrob:server:completeRob')
    end)
-- if hack is sucessful then trigger server event to give money and start timer to notify cops
end)



-- Functions

function fetchVehicleType()
    QBCore.Functions.TriggerCallback('fetchvehicletype', function(vehicletype)
        print('I got this from the CreateCallBack -->  '..vehicletype)
    end, GetVehiclePedIsIn())
end

function ripATM(atmObject) -- function to handle deleting ATM in the wall, that will also spawn ATM somewhere else
DeleteEntity(atmObject)
atmObject = nil

local atmCoords = GetEntityCoords(atmObject)
local groundZ, isGroundFound = GetGroundZFor_3dCoord(atmCoords.x, atmCoords.y, atmCoords.z, 0.0, false)

if isGroundFound then
    local heading = GetEntityHeading(attachedVehicle)
    local spawnX = atmCoords.x
    local spawnY = atmCoords.y
    local spawnZ = groundZ + 0.2 

    local newATM = CreateObject(atmModel, spawnX, spawnY, spawnZ, true, true, true)
    SetEntityHeading(newATM, heading)

end
end