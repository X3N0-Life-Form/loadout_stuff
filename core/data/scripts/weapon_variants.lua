-- do a weapon_variant.tbl
-- and adapt the variant script
--[[
		---------------------------------
		-- ship variant manager script --
		---------------------------------
In order to work, this script needs:
	- a descriptor table file in data/config
	- a lua table parser
	- the global variable variantFileName needs to point to this file, eg. "data/config/ship_variants.tbl"
	- call the setWeaponVariant() function via scrip-eval, with the name of the ship you want to alter and the name of the variant of the appropriate class as the function's argument.
		For instance "setWeaponVariant(Colly, bunny)" means you want Colly to be of the "bunny" variant.

Descriptor table logic:
	- Variants are classified by ship category, which starts with '#'
	- Each variant starts with '$Name:', follow by attributes that start with "$"
	- These may be followed by sub attributes, who themselves start with "+"

Descriptor table sample:
	#SC Rakshasa

	$Name:	Lance Assault Cruiser
	$ai class: Big
	$subsystem armor: Hell Armor
	$hull armor:	 Shivan Destroyer Armor
	$hull:		 80k	;; hull values can be defined using orders of magnitude, eg. 80k = 80,000; 80M = 80,000,000 & 80G = 80,000,000
	$turret01:Shivan Multi Turret Up
		+Rof:200
	$turret02:Shivan Huge Lance
	$turret03:Shivan Huge Lance
	$turret04:Shivan Multi Turret Up
		+Rof:200
	$turret05:Shivan Multi Turret Up
	$turret06:Shivan Multi Turret Up
	$turret07:Shivan Lance
	$turret08:Shivan Lance
	$turret09:Shivan Lance
	$turret10:Shivan Lance
	$turret11:Shivan Multi Turret Up
	$turret12:Shivan Multi Turret Up
	$turret13:Shivan Multi Turret Up
	$turret14:Shivan Multi Turret Up

	#End


Valid attributes:
	hull						: special hit points (note: accepts order of magnitude multipliers, eg. 1M = 1000k = 1000000)
	armor						: hull armor type
	turret armor				: ship-wide turret armor type
	subsystem armor				: ship-wide subsystem armor type
	texture:name=replacement	: doesn't work
	team color					: change team color
	ai class					: change ai class

Valid sub-attributes:
	armor	: armor type
	RoF		: new rate of fire (in percentage)

Sample entry:
	$GTC Aeolus: nerfed
			hull: 15k
			armor: Fancy Armor
			turret armor: Fancy Armor
			subsystem armor: Fancy Armor
			turret01: Terran Huge Turret
				+armor: Weak Armor
			turret02: Terran Huge Turret
				+armor: Weak Armor
			turret03: Terran Huge Turret
			turret04: Terran Huge Turret
			turret05: Terran Huge Turret
]]--
----------------------
-- global variables --
----------------------
weaponVariant_enableDebugPrint = true

weaponVariantTable = {}

weaponVariantShipsToSet = {}


-----------------------
-- utility functions --
-----------------------

function dPrint_weaponVariant(message)
	if (weaponVariant_enableDebugPrint) then
		ba.print("[weaponVariant.lua] "..message.."\n")
	end
end

--------------------
-- core functions --
--------------------

function setWeaponVariantsMissionWide()
	dPrint_weaponVariant("setWeaponVariantsMissionWide() start")
	
	
	for sIndex = 1, #mn.Ships do
		local currentShip = mn.Ships[sIndex]
		dPrint_weaponVariant("\tCurrent ship : "..currentShip.Name.." ("..currentShip.Class.Name..")")
		local primaries = currentShip.PrimaryBanks
		local secondaries = currentShip.SecondaryBanks
		
		dPrint_weaponVariant("\tPrimary loop")
		setWeaponVariant(currentShip, primaries, 'primary')
		
		dPrint_weaponVariant("\tSecondary loop")
		setWeaponVariant(currentShip, secondaries, 'secondary')
	end
	
	dPrint_weaponVariant("setWeaponVariantsMissionWide() end")
end

--[[

]]
function setWeaponVariant(currentShip, bank, bankType)
	for wIndex = 1, #bank do
		local currentClass = bank[wIndex].WeaponClass
		dPrint_weaponVariant("\t\tCurrent weapon : "..currentClass.Name.." (bank #"..wIndex..")")
		
		if (hasWeaponVariants(currentClass.Name)) then
			dPrint_weaponVariant("\t\t\tWeapon has variants")
			
			local variants = weaponVariantTable.Categories[currentClass.Name].Entries
			for index, entry in pairs(variants) do
				if (contains(entry.Attributes['Ships'].Value, currentShip.Class.Name)) then
					local weaponVariantName = currentClass.Name.."#"..entry.Name
					dPrint_weaponVariant("\t\t\tReplacing "..bankType.." "..currentClass.Name.." with "..weaponVariantName)
					mn.evaluateSEXP([[
						(when  (true)
							(set-]]..bankType..[[-weapon
								"]]..currentShip.Name..[["
								]]..(wIndex-1)..[[
								"]]..weaponVariantName..[["
							)
						)
					]])
				end
			end
		end
	end
end

--[[
	Checks wether the specified weapon class has variants
	
	@return true if it has
]]
function hasWeaponVariants(weaponClassName)
	if (weaponVariantTable.Categories[weaponClassName] ~= nil) then
		return true
	else
		return false
	end
end


-- TODO
function setWeaponVariantDelayed()
	for shipName, variantName in pairs(weaponVariantShipsToSet) do
		local ship = mn.Ships[shipName]
		if not (ship == nil) then
			dPrint_weaponVariant("setWeaponVariantDelayed: setting weapon variant "..shipName.." ==> "..variantName)
			weaponVariantShipsToSet[shipName] = nil
			setWeaponVariant(shipName, variantName)
		end
	end
end


----------
-- main --
----------

weaponVariantTable = TableObject:create("weapon_variants.tbl")
dPrint_weaponVariant(weaponVariantTable:toString())
