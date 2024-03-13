local show3DText = false
local ownerPed = 0

local function Draw3D(coords, text)
    local camCoords = GetGameplayCamCoord()
    local dist = #(coords - camCoords)
    local scale = 200 / (GetGameplayCamFov() * dist)

    SetTextColour(Config.TextColour.r, Config.TextColour.g, Config.TextColour.b, Config.TextColour.a)
    SetTextScale(0.0, Config.TextScale * scale)
    SetTextFont(0)
    SetTextDropshadow(0, 0, 0, 0, 55)
    SetTextDropShadow()
    SetTextCentre(true)
    SetTextOutline(5)

    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(coords, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

local function fetchPlayers()
    local p = promise.new()
    local players = GetActivePlayers()
    local selectedPlayers = {}

    table.insert(selectedPlayers, GetPlayerServerId(PlayerId()))

    for _, player in ipairs(players) do
        if player ~= PlayerId() then
            table.insert(selectedPlayers, GetPlayerServerId(player))
        end
    end

    p:resolve(selectedPlayers)

	return Citizen.Await(p)
end

RegisterNetEvent("tiz-typing:input", function(status)
    if not (GetInvokingResource() == Config.ChatName) then
        return
    end
    local selectedPlayers = fetchPlayers()
    TriggerServerEvent("tiz-typing:sync", status, selectedPlayers)
end)

RegisterNetEvent("tiz-typing:show", function(status, src)
    show3DText = status
    ownerPed = GetPlayerPed(GetPlayerFromServerId(src))
end)

CreateThread(function()
    while true do
        local wait = 0
        if show3DText then
            wait = 0
            local ped = PlayerPedId()
            local myCoords = GetEntityCoords(ped)
            local ownerCoords = GetEntityCoords(ownerPed)
            local los = HasEntityClearLosToEntity(ownerPed, ped, 17)
            local distance = #(myCoords - ownerCoords)
            
            if (los and distance <= 10) then
                Draw3D(vector3(ownerCoords.x, ownerCoords.y, ownerCoords.z + 1), Config.Text)
            end
        else
            wait = 200
        end
        Wait(wait)
    end
end)