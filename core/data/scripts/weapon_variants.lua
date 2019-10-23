--[[
	TODO : doc
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
