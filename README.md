# Eidolon Crucible Automaton

Automate the crucible from Eidolon through ComputerCraft on Minecraft 1.16.5

# Intended setup

![Setup](https://i.imgur.com/45W3xJi.png)

# Usage

- Install `eidolon_crucible.lua` and `stdlib.lua` alongside each other
- Run the program
	- `eidolon_crucible.lua`
- Put the exact items that the recipe requires in the turtle
	- The program computes a CRC32 hash of the inventory's contents and matches it against its known recipes
- The program executes the recipe
	- **Water**: 
		- The turtle will output redstone *down* to put water inside the crucible (with intent to trigger an item user loaded with a water bucket)
	- **Items**: 
		- The turtle will drop items *up* (with intent to drop into a precision dropper) to insert in the crucible
	- **Stirring**: 
		- The turtle will output redstone *left* to stir the crucible (with intent to trigger a right-click user with an empty hand)
	- The turtle won't catch the results of the crafting recipe (the item jumps around, too finicky to catch). It assumes the recipe worked
- Recipe format
		- If the recipe specifies "wait", it waits 1s
		- If the recipe specifies "stir", it stirs
		- Water is placed before each craft

# Adding recipes

Recipes are just data. You can edit them at the start of the code.

Here's an excerpt of the format

This recipe crafts some "Essence of death"

```lua
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
```

