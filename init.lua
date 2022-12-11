local items = {}
local selected = {}
core.register_on_mods_loaded(function()
	for item,_ in pairs(core.registered_items) do
		if item and item ~= "" then
			table.insert(items,item)
		end
	end
	table.sort(items)
end)

local function giveui(name)
	if not name then return end
	local preview = items[selected[name]] or "air"
	local players = {}
	for _,player in ipairs(core.get_connected_players()) do
		if player then
			table.insert(players,player:get_player_name())
		end
	end
	local fs = "size[12,10]" ..
		"textlist[0.1,0.11;6,10;items;"..table.concat(items,",").."]" ..
		"item_image[7.7,0.3;3,3;"..preview.."]" ..
		"field[8.6,3.5;1.4,1;amount;Amount;1]" ..
		"field_close_on_enter[amount;false]" ..
		"button[8.3,3.9;1.4,1;givemebtn;Giveme]" ..
		"button[8,4.6;2,1;givebtn;GiveToPlayer:]" ..
		"dropdown[7.6,5.4;3,1;player;"..table.concat(players,",")..";1]"
	core.show_formspec(name, "giveui", fs)
end

core.register_chatcommand("giveui",{
  description = "Open GIVE UI",
  privs = {give=true},
  func = function(name,param)
	giveui(name)
end})

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "giveui" then return end
	local name = player:get_player_name()
	if not name then return end
	if fields.items then
		local evnt = core.explode_textlist_event(fields.items)
		if evnt.type == "DCL" then
			selected[name] = evnt.index
			giveui(name)
		end
	end
	if fields.givemebtn then
		local item = items[selected[name]]
		local amount = fields.amount or 1
		local check = core.check_player_privs(name,{give=true})
		if item and check then
			core.chatcommands["giveme"].func(name,item.." "..amount)
		end
	end
	if fields.givebtn then
		local item = items[selected[name]]
		local player = fields.player or name
		local amount = fields.amount or 1
		local check = core.check_player_privs(name,{give=true})
		if item and check then
			core.chatcommands["give"].func(name,player.." "..item.." "..amount)
		end
	end
end)
