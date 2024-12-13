RegisterNetEvent("vorp:sendAFKWarning")
AddEventHandler("vorp:sendAFKWarning", function(randomString)
    PlaySoundFrontend(-1, "Out_of_Breath", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", true)
    local message = "You have been idling for 15 minutes. You will be kicked in 5 minutes. Type /afkcheck " .. randomString .. " in chat to avoid being kicked."
    TriggerEvent("vorp:NotifyLeft", "warning", message)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)

        if IsControlJustReleased(0, 32) or IsControlJustReleased(0, 34) or IsControlJustReleased(0, 35) or IsControlJustReleased(0, 33) then
            TriggerServerEvent("vorp:playerMoved")
        end
    end
end)

