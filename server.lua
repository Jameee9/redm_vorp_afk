local VORPcore = {}

TriggerEvent("getCore", function(core)
    VORPcore = core
end)

local AFKTimeLimit = 300 -- 1200 -- 20 minutes in seconds
local AFKWarningTime = 150 -- 900 -- 15 minutes in seconds
local AFKCheckTime = 150 -- 300 -- 5 minutes in seconds

local playersAFK = {}

-- Helper function to generate a random string
local function generateRandomString(length)
    local charset = {}
    for i = 65, 90 do table.insert(charset, string.char(i)) end -- A-Z

    local result = ""
    for i = 1, length do
        local rand = math.random(1, #charset)
        result = result .. charset[rand]
    end

    return result
end

AddEventHandler("playerDropped", function()
    local _source = source
    if playersAFK[_source] then
        playersAFK[_source] = nil
    end
end)

RegisterServerEvent('vorp:playerSpawned')
AddEventHandler('vorp:playerSpawned', function()
    local _source = source
    local user = VORPcore.getUser(_source)
    if user.group ~= "admin" then
        playersAFK[_source] = {lastPosition = GetEntityCoords(GetPlayerPed(_source)), idleTime = 0, isWarningSent = false, randomString = ""}
    end
end)

RegisterServerEvent("vorp:playerMoved")
AddEventHandler("vorp:playerMoved", function()
    local _source = source
    if playersAFK[_source] then
        playersAFK[_source].lastPosition = GetEntityCoords(GetPlayerPed(_source))
        playersAFK[_source].idleTime = 0
        playersAFK[_source].isWarningSent = false
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        for _source, data in pairs(playersAFK) do
            local playerPed = GetPlayerPed(_source)
            if DoesEntityExist(playerPed) then
                local currentPosition = GetEntityCoords(playerPed)
                if currentPosition == data.lastPosition then
                    playersAFK[_source].idleTime = playersAFK[_source].idleTime + 1

                    if playersAFK[_source].idleTime >= AFKWarningTime and not playersAFK[_source].isWarningSent then
                        playersAFK[_source].randomString = generateRandomString(5)
                        TriggerClientEvent("vorp:sendAFKWarning", _source, playersAFK[_source].randomString)
                        playersAFK[_source].isWarningSent = true
                    elseif playersAFK[_source].idleTime >= AFKTimeLimit then
                        DropPlayer(_source, "Kicked for being AFK")
                    end
                end
            end
        end
    end
end)

RegisterCommand("afkcheck", function(source, args)
    local _source = source
    if playersAFK[_source] and playersAFK[_source].isWarningSent then
        if args[1] and args[1]:upper() == playersAFK[_source].randomString then
            playersAFK[_source].idleTime = 0
            playersAFK[_source].isWarningSent = false
            TriggerClientEvent("vorp:notify", _source, "success", "AFK check passed!")
        else
            TriggerClientEvent("vorp:notify", _source, "error", "Incorrect code! You may be kicked if you don't enter the correct code.")
        end
    end
end)
