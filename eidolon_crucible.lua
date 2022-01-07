require "stdlib"

local user = peripheral.find("cyclic:user")
local waterSide = "bottom"
local stirSide = "left"

local recipes = {
	[1]={
		{
			{count=1, name="eidolon:zombie_heart"},
			{count=1, name="minecraft:rotten_flesh"},
			"wait",
			"wait",
			"wait",
			"wait",
		}, 
		{
			{count=2, name="minecraft:bone_meal"},
			"stir",
			"stir",
		}, 
		{
			{count=1, name="minecraft:charcoal"}
		}
	}
}

function turtle.list()
	local inv = {}
	for i=1,16 do
		inv[i] = turtle.getItemDetail(i)
	end
	return inv
end

local function inventoryToTableOfStrings(inv)
	local t = {}
	for i,v in pairs(inv) do
		t[i] = v.count .. ":" .. v.name
	end

	return t
end

local function serializeInventory(inv)
	local t = inventoryToTableOfStrings(inv)
	return table.concat(t, ";")
end

local function hashInventory(inv)
	local t = inventoryToTableOfStrings(inv)
	table.sort(t)
	return Crypto.crc32(table.concat(t, ";"))
end

local function recipeToInventory(recipe)
	local inv = {}
	local counter = 1
	for i,step in pairs(recipe) do
		for j,ingredient in pairs(step) do
			if type(ingredient) == "table" then
				inv[counter] = ingredient
				counter = counter+1
			end
		end
	end

	return inv
end

local function serializeRecipe(recipe)
	local inv = recipeToInventory(recipe)
	return serializeInventory(inv)
end

local function recipesByHash(recipes)
	local ht = {}
	for i,v in pairs(recipes) do
		local hash = hashInventory( recipeToInventory(recipes[i]) )
		ht[hash] = v
	end

	return ht
end

local function hasItemsInInventory()
	for i=1,16 do
		if turtle.getItemCount(i) > 0 then
			return true
		end
	end
	return false
end

function turtle.find(item)
	for i=1,16 do
		local v = turtle.getItemDetail(i)
		if v and v.name == item then
			return i
		end
	end

	return nil
end

function turtle.findSelect(item)
	local t = turtle.find(item)
	if t then
		return turtle.select(t)
	end

	return false
end

local function water()
	redstone.setOutput(waterSide, true)
	sleep(0.30)
	redstone.setOutput(waterSide, false)
	sleep(1)
end

local function stir()
	redstone.setOutput(stirSide, true)
	sleep(0.30)
	redstone.setOutput(stirSide, false)
	sleep(0.7)
end

local function executeRecipe(recipe, stepWait)
	for i,step in pairs(recipe) do
		for j,ingredient in pairs(step) do
			if type(ingredient) == "table" then
				turtle.findSelect(ingredient.name)
				turtle.dropUp(ingredient.count)
			elseif type(ingredient) == "string" then
				if     ingredient == "stir" then
					stir()
				elseif ingredient == "wait" then
					sleep(1)
				end
			end
		end

		sleep(stepWait or 3.5)
	end
end

local recipesHTable = recipesByHash(recipes)

local lastRecipe = -1
while true do
	local hash = hashInventory(turtle.list())
	if recipesHTable[hash] then
		Debug.info("Recipe recognized " .. hash)

		water()
		sleep(6.5)
		executeRecipe(recipesHTable[hash])
	else
		if hash ~= lastRecipe then
			lastRecipe = hash
			Debug.info("Recipe not recognized (" .. hash .. ")")
			sleep(1)
		end
	end

	sleep(0.5)
end
