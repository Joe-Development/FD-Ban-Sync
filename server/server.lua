-------------------
-- SERVER EVENTS --
-------------------

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    
    if Config.DebugMode then print('[Freech Ban Sync] Player Connecting Called') end
    
    local src = source

    deferrals.defer()
    Wait(0)
    deferrals.update(string.format('[Freech Ban Sync] Checking %s', name))
    
    local discordId = GetPlayerIdentifierByType(src, 'discord') and GetPlayerIdentifierByType(src, 'discord'):gsub('discord:', '') or false
    
    Wait(0)
    
    if not discordId then
        if Config.DebugMode then print("[Freech Ban Sync] Kicked Player " .. name .. " ID: " .. src .. " for no discord identifier") end
        deferrals.done("You need to have discord linked to join this server.")
    end
    
    hasDiscord, isBanned = CheckBan(discordId)
        
    if isBanned then 
        print("[Freech Ban Sync] Rejected Player " .. name .. " ID: " .. src .. " for being banned - Discord: " .. discordId)
        deferrals.done(Config.Setup.BanMessage)
    else
        deferrals.done()
    end

end)

-------------
-- THREADS --
------------- 

if Config.BanThread then 
    Citizen.CreateThread(function()
        while true do Wait(10000)
            if Config.DebugMode then print('[Freech Ban Sync] Thread Called') end
            local src = source
            local identifiers = ExtractIdentifiers(src)
            local discordId = identifiers.discord:gsub("discord:", "")  
            local hasDiscord, isBanned = CheckBan(discordId)
            if isBanned then
                DropPlayer(src, Config.Setup.BanMessage)
            end    
        end 
    end)
end

---------------
-- FUNCTIONS --
---------------

function CheckBan(userId)
    if Config.DebugMode then print('[Freech Ban Sync] CheckBan Called') end
    PerformHttpRequest(
        'https://discordapp.com/api/guilds/' .. Config.Setup.GuildId .. '/bans/' .. userId,
        function(err, responseCode, body)
            local isBanned = false
            if err == 200 then
                isBanned = true
            end
            if Config.DebugMode then print('[Freech Ban Sync] CheckBan Returned ' .. tostring(hasDiscord) .. ' - ' .. tostring(isBanned)) end
            return isBanned
        end,
        'GET',
        '',
        {['Authorization'] = 'Bot ' .. Config.Setup.BotToken,
        ['Content-Type'] = 'application/json'}
    )
end