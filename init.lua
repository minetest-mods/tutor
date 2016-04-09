
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
	"default:grass_5",
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


TTL_PAUSE = 5 * 60 -- break when idle
TTL_MSG = 12       -- how long messages stay up
TTL_NEXT = 2       -- how long in between messages

--
-- goal tracking and update
--

local function hud_show(player, data)
	player:hud_change(data.hud_bg, "position", {x = 0.8, y = 0.5})
	player:hud_change(data.hud, "position", {x = 0.8, y = 0.5})
	data.hud_open = true
end

local function hud_hide(player, data)
	player:hud_change(data.hud_bg, "position", {x = 5.0, y = 0.5})
	player:hud_change(data.hud, "position", {x = 5.0, y = 0.5})
	data.hud_open = false
end

local function hud_display(player, data, item)
	assert(item)
	local goal = goals[item]
	assert(goal.text)
	assert(goal.description)
	local description
	if data.complete[item] then
		description = "You have completed the goal:\n\"" .. goal.text .. "\"!\n\n"
		description = description .. goal.complete
	else
		description = goal.text .. "\n\n" .. goal.description
	end

	player:hud_change(data.hud, "text", description)
	hud_show(player, data)
	data.ttl = TTL_MSG
end

local function hud_update(player, data)
	if data.ttl > 0 then
		data.ttl = data.ttl - 1
		minetest.after(1.0, hud_update, player, data)
		return
	end

	if not data then
		local data = datastorage.get(player:get_player_name(), "tutor")
	end

	if data.hud_open then
		-- close the hud for a second, then return
		-- FIXME assure we've left the last hint open for a minumum of X seconds
		hud_hide(player, data)
		data.ttl = TTL_NEXT
		minetest.after(1.0, hud_update, player, data)
		return
	end

	if data.disable then
		minetest.sound_play("tutor_open", {to_player = player:get_player_name()})
		hud_display(player, data, "disable")
		minetest.chat_send_player(player:get_player_name(), "The tutor is now disabled. Type /tutor to re-enable it.")
		minetest.after(TTL_MSG, hud_hide, player, data)
		return
	end

	-- if we've just completed items, show these first.
	assert(data.complete)
	for k, _ in pairs(data.complete) do
		minetest.sound_play("tutor_complete", {to_player = player:get_player_name()})
		hud_display(player, data, k)
		data.complete[k] = nil
		minetest.after(1.0, hud_update, player, data)
		return
	end

	-- then any new goals
	assert(data.new)
	for k, _ in pairs(data.new) do
		minetest.sound_play("tutor_new", {to_player = player:get_player_name()})
		hud_display(player, data, k)
		data.new[k] = nil
		minetest.after(1.0, hud_update, player, data)
		return
	end

	-- then cycle through active goals
	if data.last_active then
		-- continue from where we left off
		for k, _ in pairs(data.active) do
			if data.last_active == k then
				-- take the next one in the list
				local k = next(data.active, k)
				if k then
					minetest.sound_play("tutor_open", {to_player = player:get_player_name()})
					data.last_active = k
					hud_display(player, data, k)
					minetest.after(1.0, hud_update, player, data)
					return
				end

				-- go away for a while
				data.last_active = false
				data.ttl = TTL_PAUSE
				minetest.after(1.0, hud_update, player, data)
				return
			end
		end
	end

	-- pick first active
	minetest.sound_play("tutor_open", {to_player = player:get_player_name()})
	local k = next(data.active, nil)
	if not (k) then
		-- finished the tutorial!
		-- FIXME some sort of ending message
		return
	end
	data.last_active = k
	hud_display(player, data, k)
	minetest.after(1.0, hud_update, player, data)
end

local function active_update(player, data)
	if not data then
		local data = datastorage.get(player:get_player_name(), "tutor")
	end
	for k, _ in pairs(data.progression) do
		assert(goals[k])
		local vv = goals[k]
		for _, vvv in pairs(vv.n) do
			if not data.progression[vvv] then
				assert(goals[vvv])
				data.new[vvv] = 1
				data.active[vvv] = 1
				minetest.chat_send_player(player:get_player_name(),
					"New goal: \"" .. goals[vvv].text .. "\"!")
			end
		end
	end
end

local function tutor_enable(player, data)
	data.disable = false
	minetest.after(1.0, hud_update, player, data)
	minetest.after(5.0, function()
		-- this triggers "start" and initializes everything
		data.complete["start"] = 1
		data.progression["start"] = 1
		active_update(player, data)
		data.ttl = 0
	end)
end

minetest.register_on_joinplayer(function(player)
	local data = datastorage.get(player:get_player_name(), "tutor")
	if not data.progression then
		data.progression = {}
	end
	if not data.active then
		data.active = {}
	end
	if not type(data.disabled) == "boolean" then
		data.disabled = false
	end
	data.hud_bg = player:hud_add({
		name = "tutor_hints_bg",
		hud_elem_type = "image",
		text = "tutor_bg.png",
		position = {x = 5.0, y = 0.6},
		scale = {x = 30, y = 30},
		offset = {x=0, y=0},
	})
	data.hud = player:hud_add({
		name = "tutor_hints",
		hud_elem_type = "text",
		number = 0xffffff, -- color
		text = "dummy text",
		position = {x = 5.0, y = 0.6},
		scale = {x=2, y=1},
		offset = {x=0, y=0},
	})
	data.hud_open = false
	data.complete = {}
	data.new = {}
	data.ttl = TTL_PAUSE
	if data.disabled then
		return
	end
	active_update(player, data)
	tutor_enable(player, data)
end)

local function check_player_progress(action, player, test)
	assert(action)
	assert(test)
	local data = datastorage.get(player:get_player_name(), "tutor")
	for k, _ in pairs(data.active) do
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
				data.active[k] = nil
				-- mark it completed
				data.complete[k] = 1
				-- and put it in the progression list
				data.progression[k] = 1
				active_update(player, data)
				data.ttl = TTL_NEXT
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
		local data = datastorage.get(player:get_player_name(), "tutor")
		if data.disable then
			data.disable = false
			tutor_enable(player, data)
		else
			data.disable = true
		end
	end
})
