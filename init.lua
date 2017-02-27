
--
-- Minetest Tutor
--

--[[

A Minetest gameplay tutor Mod.

This mod aims to provide hints to the casual singleplayer to get
her or him to know the Minetest game better. The mod provides useful
clues in text form to the player at certain events in time, as well
as some relevant non-event gameplay hints that may appear at random
points in time, reminding the player of things to look out for.

--]]

local goals = {}

local function _item(id, text, description, complete, func, target, n)
	goals[id] = {
		text = text,
		description = description,
		complete = complete,
		func = func,
		target = target,
		n = n,
	}
end

_item("disable",
	"Tutor disabled",
	"The tutor is now disabled. You can\nturn it back on by typing\n\n/tutor",
	"dummy",
	"",
	"",
	{})
_item("start",
	"Start the game!",
	"dummy text",
	"Welcome to minetest!\n\nThank you for trying out minetest.\nThis information text is part of the \nMinetest Tutor. In this panel \nyou will read useful tips for when\nyou first play minetest. As you \nprogress through the game, the \nhints will change and focus on things\nthat are useful for you at that time.\n\nIf you want to disable this tutor,\nor re-enable it at a later point in\ntime, just type /tutor !" ,
	"",
	"",
	{"punch_tree"})
_item("punch_tree",
	"Punch a tree",
	"Since you don't have any tools\nyet, you're going to have to\npunch a tree with your bare\nhands. Fortunately, it won't hurt!",
	"Great! You've got some wood!\n\nNow that you have some raw material\nyou can try crafting things with it.\n",
	"dig",
	"group:tree",
	{"craft_wood"})
_item("craft_wood",
	"Craft wooden planks",
	"Planks are crafted from trees,\njust put a tree trunk in one\nof the slots in the crafting grid.",
	"Good job! Planks are used to make many\ndifferent items, and can be used\nas decoration and placed where\nyou want. It is a nice block to\nbuild your first house or shelter.",
	"craft",
	"group:wood",
	{"craft_stick"})
_item("craft_stick",
	"Craft sticks",
	"You can make sticks by placing\nplanks on the crafting grid.",
	"Sticks are a craft item, and\ncan't be placed in the world as\na block. They are used for crafting.",
	"craft",
	"default:stick",
	{"craft_wood_axe", "craft_wood_pickaxe", "craft_wood_shovel", "craft_wood_hoe", "craft_wood_sword"})
_item("craft_wood_axe",
	"Craft a wooden axe",
	"Make a wooden axe out of two sticks\nand three wooden planks!",
	"A wooden axe is a great way to speed\nup logging. You'll cut down those\ntrees much faster than by\nhand.",
	"craft",
	"default:axe_wood",
	{})
_item("craft_wood_pickaxe",
	"Craft a wooden pickaxe",
	"Make a wooden axe out of two sticks\nand three wooden planks!",
	"A wooden pickaxe is needed to dig\nmost stone blocks. Without it you\nwon't be able to get stone.\n\nTry finding some stone and\nusing your pickaxe on it.",
	"craft",
	"default:pick_wood",
	{})
_item("craft_wood_shovel",
	"Craft a wooden shovel",
	"Make a wooden axe out of two sticks\nand one wooden planks!",
	"A shovel is useful for digging dirt,\nsand and other loose sediment.\nIt will go much faster with\na shovel than by hand.",
	"craft",
	"default:shovel_wood",
	{})
_item("craft_wood_hoe",
	"Craft a wooden hoe",
	"Make a wooden hoe out of two sticks\nand two wooden planks!",
	"A hoe is a farming tool and allows\nyou to make farmable soil by\nusing it on dirt. Now you just\nhave to find some seeds to\nplant.",
	"craft",
	"farming:hoe_wood",
	{"dig_grass","dig_junglegrass"})
_item("craft_wood_sword",
	"Craft a wooden sword",
	"Make yourself a wooden sword out of\none stick and two wooden planks!\n",
	"Besides being a weapon, the sword's\nsharp edge can be used to cut\nall sorts of blocks easily.",
	"craft",
	"default:sword_wood",
	{})
_item("dig_grass",
	"Dig some grass",
	"Wild grass plants grow on grassland\nand many other places, usually\non dirt blocs. If you dig them\nyou may get wheat seeds.",
	"Looks like you didn't get any seeds\nbut don't worry, just dig a few\nmore grass plants until you\nget some seeds. It only takes\na single seed to get started\nwith a wheat farm.",
	"dig",
	"default:grass_1",
	{"farm_wheat"})
_item("dig_junglegrass",
	"Dig some jungle grass",
	"Jungle grass plants grow in jungles\nand can be hard to find! Some of\nthem are cotton plants and give\nyou some cotton seed which can\nbe used to make a cotton\nfarm. Just find more until you get\nsome seeds.",
	"Looks like you didn't get any seeds\nbut don't worry, just dig a few\nmore wild jungle grass plants until\nyou get some seeds. It only takes\na single seed to get started\nwith a cotton farm.",
	"dig",
	"default:junglegrass",
	{"farm_cotton"})
_item("farm_wheat",
	"Farm wheat",
	"Wheat can be used to make bread which\ncan be used to regain health.\nYou'll have to make some farmable soil\nwith a hoe near water and place the\nseed on it. It will take several\ndays for it to fully grow. Make sure\nyou don't harvest too soon!",
	"You farmed some wheat! You should have\nalso gotten some seeds from\nthe wheat plant. You can replant\nthose to keep your farm growing. You\nwill also want to make some bread",
	"dig",
	"farming:wheat_8",
	{})
_item("farm_cotton",
	"Farm cotton",
	"Cotton is useful to make wool blocks\nwhich are decorative but also\nthe main ingredient for making a bed.",
	"You farmed some cotton! Make sure to\nreplant the cotton seeds back on\nyour farm. To make wool, you have\nto craft the cotton that you got in\nto wool blocks",
	"dig",
	"farming:cotton_8",
	{})


-- verify that the goal tree is complete and functional
for _, v in pairs(goals) do
	if v.target ~= "" and v.target:sub(1,6) ~= "group:" then
		if not minetest.registered_items[v.target] then
			print("error in goal target item: (" .. v.target .. ")")
			print(dump(v))
		end
	end
	for k, vv in pairs(v.n) do
		if not goals[vv] then
			print("error in goal next item: (" .. vv .. ")")
			print(dump(v))
		end
	end
end

TTL_PAUSE = 5 * 60 -- break when idle
TTL_MSG = 12       -- how long messages stay up
TTL_NEXT = 2       -- how long in between messages


--
-- state table for runtime caching of tutor progress
--
local data = {}

--
-- goal tracking and update
--

local function hud_show(player)
	player:hud_change(data[player].hud_bg, "position", {x = 0.8, y = 0.5})
	player:hud_change(data[player].hud, "position", {x = 0.8, y = 0.5})
	data[player].hud_open = true
end

local function hud_hide(player)
	player:hud_change(data[player].hud_bg, "position", {x = 5.0, y = 0.5})
	player:hud_change(data[player].hud, "position", {x = 5.0, y = 0.5})
	data[player].hud_open = false
end

local function hud_display(player, item)
	assert(item)
	local goal = goals[item]
	assert(goal.text)
	assert(goal.description)
	local description
	if data[player].complete[item] then
		description = "You have completed the goal:\n\"" .. goal.text .. "\"!\n\n"
		description = description .. goal.complete
	else
		description = goal.text .. "\n\n" .. goal.description
	end

	player:hud_change(data[player].hud, "text", description)
	hud_show(player)
	data[player].ttl = TTL_MSG
end

local function hud_update(player)
	if data[player].ttl > 0 then
		data[player].ttl = data[player].ttl - 1
		minetest.after(1.0, hud_update, player)
		return
	end

	if data[player].hud_open then
		-- close the hud for a second, then return
		-- FIXME assure we've left the last hint open for a minumum of X seconds
		hud_hide(player)
		data[player].ttl = TTL_NEXT
		minetest.after(1.0, hud_update, player)
		return
	end

	if data[player].disable then
		minetest.sound_play("tutor_open", {to_player = player:get_player_name()})
		hud_display(player, "disable")
		minetest.chat_send_player(player:get_player_name(), "The tutor is now disabled. Type /tutor to re-enable it.")
		minetest.after(TTL_MSG, hud_hide, player)
		return
	end

	-- if we've just completed items, show these first.
	assert(data[player].complete)
	local k, _ = next(data[player].complete)
	if k then
		minetest.sound_play("tutor_complete", {to_player = player:get_player_name()})
		hud_display(player, k)
		data[player].complete[k] = nil
		minetest.after(1.0, hud_update, player)
		return
	end

	-- then any new goals
	assert(data[player].new)
	k, _ = next(data[player].new)
	if k then
		minetest.sound_play("tutor_new", {to_player = player:get_player_name()})
		hud_display(player, k)
		data[player].new[k] = nil
		minetest.after(1.0, hud_update, player)
		return
	end

	-- then cycle through active goals
	if data[player].last_active then
		-- continue from where we left off
		for kk, _ in pairs(data[player].active) do
			if data[player].last_active == k then
				-- take the next one in the list
				kk = next(data[player].active, kk)
				if kk then
					minetest.sound_play("tutor_open", {to_player = player:get_player_name()})
					data[player].last_active = kk
					hud_display(player, kk)
					minetest.after(1.0, hud_update, player)
					return
				end

				-- go away for a while
				data[player].last_active = false
				data[player].ttl = TTL_PAUSE
				minetest.after(1.0, hud_update, player)
				return
			end
		end
	end

	-- pick first active
	minetest.sound_play("tutor_open", {to_player = player:get_player_name()})
	k = next(data[player].active, nil)
	if not (k) then
		-- finished the tutorial!
		-- FIXME some sort of ending message
		return
	end
	data[player].last_active = k
	hud_display(player, k)
	minetest.after(1.0, hud_update, player)
end

local function active_update(player)
	for k, _ in pairs(data[player].progression) do
		assert(goals[k])
		local vv = goals[k]
		for _, vvv in pairs(vv.n) do
			if not data[player].progression[vvv] then
				assert(goals[vvv])
				data[player].new[vvv] = 1
				data[player].active[vvv] = 1
				minetest.chat_send_player(player:get_player_name(),
					"New goal: \"" .. goals[vvv].text .. "\"!")
			end
		end
	end
end

local function tutor_enable(player)
	data[player].disable = false
	minetest.after(1.0, hud_update, player)
	minetest.after(5.0, function()
		-- this triggers "start" and initializes everything
		data[player].complete["start"] = 1
		data[player].progression["start"] = 1
		active_update(player)
		data[player].ttl = 0
	end)
end

--
-- shutdown/leave/join handlers loading/saving data
--
local function save_player(player)
	player:set_attribute("tutor_data", minetest.write_json(data[player]))
	data[player] = nil
end

minetest.register_on_shutdown(function()
	for _, player in pairs(minetest.get_connected_players()) do
		save_player(player)
	end
end)
minetest.register_on_leaveplayer(save_player)

minetest.register_on_joinplayer(function(player)
	local stored = player:get_attribute("tutor_data")
	if not stored then
		data[player] = {
			complete = {},
			new = {},
			active = {},
			progression = {},
			disabled = false,
		}
	else
		data[player] = minetest.parse_json(stored)
		if not data[player].complete then
			data[player].complete = {}
		end
		if not data[player].new then
			data[player].new = {}
		end
		if not data[player].active then
			data[player].active = {}
		end
		if not data[player].progression then
			data[player].progression = {}
		end
		if not data[player].disabled then
			data[player].disabled = false
		end
	end
	data[player].hud_bg = player:hud_add({
		name = "tutor_hints_bg",
		hud_elem_type = "image",
		text = "tutor_bg.png",
		position = {x = 5.0, y = 0.6},
		scale = {x = 30, y = 30},
		offset = {x=0, y=0},
	})
	data[player].hud = player:hud_add({
		name = "tutor_hints",
		hud_elem_type = "text",
		number = 0xffffff, -- color
		text = "dummy text",
		position = {x = 5.0, y = 0.6},
		scale = {x=2, y=1},
		offset = {x=0, y=0},
	})
	data[player].hud_open = false
	data[player].complete = {}
	data[player].new = {}
	data[player].ttl = TTL_PAUSE
	if data[player].disabled then
		return
	end
	active_update(player)
	tutor_enable(player)
end)

local function check_player_progress(action, player, test)
	assert(action)
	assert(test)
	for k, _ in pairs(data[player].active) do
		assert(goals[k])
		local vv = goals[k]
		if vv.func == action then
			assert(vv.func)
			assert(vv.target)
			-- is this the node player needs to dig?
			if vv.target == test or
					(vv.target:sub(1,6) == "group:" and
					minetest.get_item_group(test, vv.target:sub(7)) > 0)
			then
				-- remove this one from active list
				data[player].active[k] = nil
				-- mark it completed
				data[player].complete[k] = 1
				-- and put it in the progression list
				data[player].progression[k] = 1
				active_update(player)
				data[player].ttl = TTL_NEXT
				minetest.chat_send_player(player:get_player_name(),
						"Completed the goal: \"" .. goals[k].text .. "\"!")
			end
		end
	end
end

--
-- Triggers
--

minetest.register_on_dignode(function(pos, oldnode, digger)
	if not digger or not pos or not oldnode then
		return
	end

	check_player_progress("dig", digger, oldnode.name)
end)

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if not player or not itemstack then
		return
	end

	check_player_progress("craft", player, itemstack:get_name())
end)

--
-- chatcommands
--

minetest.register_chatcommand("tutor", {
	params = "reset",
	description = "Toggle the tutor state (on|off)",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if data[player].disable then
			data[player].disable = false
			tutor_enable(player)
		else
			data[player].disable = true
		end
	end
})
