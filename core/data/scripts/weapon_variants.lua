--[[
	Table example:
	
	#Prometheus S

	$Name:		Red
	$Ships:		GTF Ulysses, GTF Myrmydon, GTF Perseus


	$Name:		Blue
	$Ships:		GTF Ulysses#Pirate, GVF Serapis, GVF Tauret


	#End
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

--[[
	Sets weapon variants for every ship currently in-mission
]]
function setWeaponVariantsMissionWide()
	dPrint_weaponVariant("setWeaponVariantsMissionWide() start")
	
	for sIndex = 1, #mn.Ships do
		local currentShip = mn.Ships[sIndex]
		dPrint_weaponVariant("\tCurrent ship : "..currentShip.Name.." ("..currentShip.Class.Name..")")
		setWeaponVariant(currentShip)
	end
	
	dPrint_weaponVariant("setWeaponVariantsMissionWide() end")
end

--[[
	Sets weapon variants for the specified ship

	@param ship : ship handle
]]
function setWeaponVariant(ship)
	local primaries = ship.PrimaryBanks
	local secondaries = ship.SecondaryBanks
	
	dPrint_weaponVariant("\tPrimary loop")
	setWeaponVariantForBank(ship, primaries, 'primary')
	
	dPrint_weaponVariant("\tSecondary loop")
	setWeaponVariantForBank(ship, secondaries, 'secondary')
end

--[[
	Sets weapon variants for each weapon in the specified bank
	
	@param ship : ship handle
	@param bank : weapon bank handle
	@param bankType : weapon bank type, 'primary' or 'secondary'
]]
function setWeaponVariantForBank(ship, bank, bankType)
	-- For each weapon in the specified bank
	for wIndex = 1, #bank do
		local currentClass = bank[wIndex].WeaponClass
		dPrint_weaponVariant("\t\tCurrent weapon : "..currentClass.Name.." (bank #"..wIndex..")")
		
		if (hasWeaponVariants(currentClass.Name)) then
			dPrint_weaponVariant("\t\t\tWeapon has variants")
			
			local variants = weaponVariantTable.Categories[currentClass.Name].Entries
			-- Find the Ship's variant, if it exists
			for index, entry in pairs(variants) do
				if (contains(entry.Attributes['Ships'].Value, ship.Class.Name)) then
					local weaponVariantName = currentClass.Name.."#"..entry.Name
					dPrint_weaponVariant("\t\t\tReplacing "..bankType.." "..currentClass.Name.." with "..weaponVariantName)
					mn.evaluateSEXP([[
						(when  (true)
							(set-]]..bankType..[[-weapon
								"]]..ship.Name..[["
								]]..(wIndex-1)..[[
								"]]..weaponVariantName..[["
							)
						)
					]])
					break
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


--[[
	Call on a "$On Warp In" hook. Sets the weapon variants for the newly arrived ship
]]
function setWeaponVariantDelayed()
	local shipName = hv.Self.Name
	local ship = mn.Ships[shipName]
	dPrint_weaponVariant("Setting delayed weapon variant for "..shipName.." ("..ship.Class.Name..")")
	
	setWeaponVariant(ship)
end


----------
-- main --
----------

weaponVariantTable = TableObject:create("weapon_variants.tbl")
dPrint_weaponVariant(weaponVariantTable:toString())
