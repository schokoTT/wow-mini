local addonName, ns = ...

local addon = CreateFrame ("Frame", addonName, UIParent);
addon.talents = { }

TIER_MAX = 7
COL_MAX = 3

TabDB = TabDB or { }
TabDB.enabled = TabDB.enabled or true
TabDB.macroEnabled = TabDB.macroEnabled or false
TabDB.chatOutput = TabDB.chatOutput or true
TabDB.saveActiveSpells = TabDB.saveActiveSpells or true
TabDB.blacklistMacro = TabDB.blacklistMacro or { }
TabDB.blacklistSpell = TabDB.blacklistSpell or { }

TabCharDB = TabCharDB or { }
TabCharDB.savedActionBarSpells = TabCharDB.savedActionBarSpells or { }

addon:RegisterEvent ("ADDON_LOADED")
addon:RegisterEvent ("PLAYER_LOGIN")

addon:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)

local options = {
	name = addonName,
	type = "group",
	args = {
		Enabled = {
			type = 'toggle', width = "full",
			name = "Enable action button replacing on talent change",
			desc = "",
			order = 1,
			get = function() return TabDB.enabled end,
			set = function(_,v)	addon:SetEnabled (v) end,
		},
		MacroEnabled = {
			type = 'toggle', width = "full",
			name = "Enable replacing of spell names in macros",
			desc = "",
			order = 2,
			get = function() return TabDB.macroEnabled end,
			set = function(_,v)	TabDB.macroEnabled = v end,
		},
		ChatOutput = {
			type = 'toggle', width = "full",
			name = "Chatframe output",
			desc = "Report in chatframe what action buttons and macros have changed",
			order = 3,
			get = function() return TabDB.chatOutput end,
			set = function(_,v)	TabDB.chatOutput = v; end,
		},
		ActiveSpells = {
			type = 'toggle', width = "full",
			name = "Save Active Spells",
			desc = "Save active spells on your action bars when switching to passive ones",
			order = 4,
			get = function() return TabDB.saveActiveSpells end,
			set = function(_,v)	
				TabDB.saveActiveSpells = v; 
				if v then 
					for tier = 1, TIER_MAX do
						for col = 1, COL_MAX do
							local id, name, texture, selected = GetTalentInfo (tier, col, GetActiveSpecGroup())
							if selected and IsPassiveSpell (name) then addon:saveActiveSpells (tier) end
						end
					end					
				end 
			end,
		},

	}
}

LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, options)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName)

function addon:print (st)
	if TabDB.chatOutput then print (st) end
end

function GetTalentId (nr)
	local link = GetTalentLink (nr)
	if link == nil then return nil end
	return tonumber (link:match ("talent:(%d+)"))
end

function GetSpellId (nr)
	local link = GetSpellLink (nr)
	if link == nil then return nil end
	return tonumber (link:match ("spell:(%d+)"))
end

function addon:SetEnabled (bool)
	TabDB.enabled = bool
	if bool then 
		addon:RegisterEvent ("LEARNED_SPELL_IN_TAB")
		addon:RegisterEvent ("ACTIVE_TALENT_GROUP_CHANGED")
		addon:print ("Talent Action Bar enabled")
	else
		addon:UnregisterEvent ("LEARNED_SPELL_IN_TAB")
		addon:UnregisterEvent ("ACTIVE_TALENT_GROUP_CHANGED")
		addon:print ("Talent Action Bar disabled")
	end
end

function addon:BlackList (item, list) 
	if list [item] then
		print (format ("Removing %s from blacklist", item))
		list [item] = nil
	else
		print (format ("Blacklisting %s", item))
		list [item] = true			
	end
end

function addon:fix () 
	for tier = 1, TIER_MAX do
		for col = 1, COL_MAX do
			local id, name, texture, selected = GetTalentInfo (tier, col, GetActiveSpecGroup())
			if selected and not IsPassiveSpell (name) then addon:talentChanged (GetSpellId (name)) end
		end
	end
end

function addon:ADDON_LOADED (event, msg)
	addon:UnregisterEvent ("ADDON_LOADED");
	SLASH_TAB1 = "/tab";
	SlashCmdList ["TAB"] = function (msg)
		local command, rest = msg:match("^(%S*)%s*(.-)$")
		if command == "" then
			print (" /tab fix|cffaaaaaa - Go through all your talents fixing your action bars")			
			print (" /tab config|cffaaaaaa - Open configuration")			
			print (" /tab listbl|cffaaaaaa - List blacklisted spells and macros")			
			print (" /tab blmacro|cffaaaaaa - Blacklist a macro based on name")			
			print (" /tab blspell|cffaaaaaa - Blacklist a spell based on name")			
			print (" /tab clearsavedbuttons|cffaaaaaa - Clear buttons that are saved when switching between active and passive talents")			
		end
		if command == "debug" then
			addon:PLAYER_LEAVING_WORLD ("asdf", "a", "b")
		elseif command == "clearsavedbuttons" then
			print ("Cleared saved buttons")
			TabCharDB.savedActionBarSpells = { }
		elseif command == "fix" then
			addon:fix ()
		elseif command == "enable" then
			addon:SetEnabled (true)
		elseif command == "disable" then
			addon:SetEnabled (false)
		elseif (command == "config") then
			InterfaceOptionsFrame_OpenToCategory (addonName)
		elseif (command == "blmacro") then
			addon:BlackList (rest, TabDB.blacklistMacro)
		elseif (command == "blspell") then
			addon:BlackList (rest, TabDB.blacklistSpell)
		elseif (command == "listbl") then
			print ("Blaclisted Macros")
			for k, v in pairs (TabDB.blacklistMacro) do
				print ("|cffaaaaaa"..k)
			end
			print ("Blaclisted Spells")
			for k, v in pairs (TabDB.blacklistSpell) do
				print ("|cffaaaaaa"..k)
			end
		end			
	end
	local tmp = TabDB.chatOutput
	TabDB.chatOutput = false
	addon:SetEnabled (TabDB.enabled)
	TabDB.chatOutput = tmp
end

function addon:PLAYER_LOGIN (event, msg)
	for tier = 1, TIER_MAX do
		for col = 1, COL_MAX do	
			local id, name = GetTalentInfo (tier, col, GetActiveSpecGroup())	
			addon.talents [name] = tier
			if addon.talents [tier] == nil then addon.talents [tier] = { } end
			addon.talents [tier][col] = name
		end
	end
end

function addon:saveActiveSpells (tier) 
	for i = 1,120 do
		local tpe, id, subType = GetActionInfo (i) 
		if tpe == "spell" then
			local spellName = GetSpellInfo (id)
			for col = 1, COL_MAX do
				local id, name, texture, selected = GetTalentInfo (tier, col, GetActiveSpecGroup())
				if name == spellName then
					TabCharDB.savedActionBarSpells [GetSpecialization ()] = TabCharDB.savedActionBarSpells [GetSpecialization ()] or {}
					TabCharDB.savedActionBarSpells [GetSpecialization ()][tier] = i
				end
			end
		end
	end		
end

function addon:talentChanged (learnId) 
	local learnName = GetSpellInfo (learnId)	
	local tier = addon.talents [learnName]
	if tier == nil then
		return
	end
	local arena, _ = IsActiveBattlefieldArena ()
	if select (2, IsInInstance ()) == "arena" then
		addon:RegisterEvent ("PLAYER_ENTERING_WORLD")
	end
	if IsPassiveSpell (learnName) then 
		if TabDB.saveActiveSpells then addon:saveActiveSpells (tier) end		
		return -- Exit because you can't put passive spells on bars
	end
	if TabDB.saveActiveSpells and TabCharDB.savedActionBarSpells [GetSpecialization ()] then
		if TabCharDB.savedActionBarSpells [GetSpecialization ()][tier] then
			local tpe, id, subType = GetActionInfo (TabCharDB.savedActionBarSpells [GetSpecialization ()][tier])
			if id == nil then
				PickupSpell (learnId)
				PlaceAction (TabCharDB.savedActionBarSpells [GetSpecialization ()][tier])
			else
				TabCharDB.savedActionBarSpells [GetSpecialization ()][tier] = nil
			end
		end
	end		
	for i = 1,120 do
		local tpe, id, subType = GetActionInfo (i)
		if tpe == "macro" and TabDB.macroEnabled then
			local name, texture, body = GetMacroInfo (id)
			if not TabDB.blacklistMacro [name] then
				local macro = GetMacroBody (id)
				if macro then
					for col = 1, 3 do
						if (macro:find ("/cast(.*)"..addon.talents [tier][col]) ~= nil or macro:find ("/use(.*)"..addon.talents [tier][col]) ~= nil) and addon.talents [tier][col] ~= learnName then
							local newMacro, rep = macro:gsub (addon.talents [tier][col], learnName)
							EditMacro (id, nil, nil, newMacro)
							addon:print (format ("Replaced %s in macro %s with %s", addon.talents [tier][col], name, learnName))
						end
					end
				end
			end
		end
		if tpe == "spell" then
			local name = GetSpellInfo (id)
			if not TabDB.blacklistSpell [name] then
				for col = 1, 3 do
					if name == addon.talents [tier][col] and addon.talents [tier][col] ~= learnName then 
						PickupAction (i)
						ClearCursor()
						PickupSpell (learnId)
						PlaceAction (i)
						addon:print (format ("Replaced %s with %s on action bar spot %d", name, learnName, i))
					end
				end
			end
		end
	end
	ClearCursor()
end

local totalTime = 0

function addon:onUpdate (elapsed)
	totalTime = totalTime + elapsed
    if totalTime >= 1 then
		addon:SetScript ("OnUpdate", nil)
		addon:fix ()
        totalTime = 0
		addon:RegisterEvent ("LEARNED_SPELL_IN_TAB")
    end
end

function addon:PLAYER_ENTERING_WORLD (event)
	addon:UnregisterEvent ("PLAYER_ENTERING_WORLD")
	addon:fix ()
end 

function addon:ACTIVE_TALENT_GROUP_CHANGED (event)
	addon:SetScript ("OnUpdate", addon.onUpdate)
	addon:UnregisterEvent ("LEARNED_SPELL_IN_TAB")
end

function addon:LEARNED_SPELL_IN_TAB (event, learnId, tab, x1, x2)
	addon:talentChanged (learnId)
end
