--[[
ULX Ammo/Weapons Module
	Unlimited Ammo - Setting, Hook, Reset on unset?
	--Set Ammo Amount
	--Set Current Ammo
	--Strip Ammo
	--Strip Weapons
	--Strip Current Weapon
	--Force Drop Weapon
	--Force Drop Weapons
	--Get Ammo ID
	--Get Ammo Name
]]--

local CATEGORY_NAME = "Ammo"

ammotypes = {} -- Setting the ammotypes table, referenced in several functions.
ammotypes[1] = "AR2" -- In GMod, ammoID 1 is the AR2 ammo.
ammotypes[2] = "Combine Balls" -- ID 2 are combine balls.
ammotypes[3] = "Pistol" -- And so on.
ammotypes[4] = "SMG Ammo"
ammotypes[5] = ".357"
ammotypes[6] = "Crossbow Bolts"
ammotypes[7] = "12 Gauge Shells"
ammotypes[8] = "RPG"
ammotypes[9] = "SMG Grenades"
ammotypes[10] = "Grenades"
ammotypes[11] = "SLAM Explosives" 

ammoids = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11} -- List of the ammoID, if we get say, ammoID 11 then the next one is 13.

------ Strip Ammunition ------
function ulx.stripAmmo(calling_ply, target_plys) -- Defining a function
	if not target_plys then -- If the admin didn't specifiy a player.
		target_plys = {} -- Make a new, blank table.
		table.insert(target_plys, calling_ply) -- And insert the calling player into it.
	end -- End the if statement.
		local affected_plys = {} -- Currently, we have affected no players.
	for i = 1, #target_plys do -- For every targeteted player.
		local v = target_plys[i] -- Make it set (ease of access, though we could just reference target_plys[i]
		v:StripAmmo() -- Strip the player's ammo.
		for _, i in pairs(v:GetWeapons()) do -- Bug fix, since stripammo doesn't count clips as ammo.
			i:SetClip1(0) -- Set the primary
			i:SetClip2(0) -- And secondary clips to 0.
		end -- :(
		table.insert(affected_plys, v) -- We affected someone.
	end
	ulx.fancyLogAdmin(calling_ply, "#A stripped ammo from #T", affected_plys) -- Call out the abusers.
end
local stripam = ulx.command(CATEGORY_NAME, "ulx stripammo", ulx.stripAmmo, "!stripammo") -- Make a new command.
stripam:addParam{type=ULib.cmds.PlayersArg, ULib.cmds.optional} -- Since we have it able to target the caller, we don't NEED a player argument.
stripam:defaultAccess(ULib.ACCESS_ADMIN) -- Only admins can abuse this.
stripam:help( "Strips the ammo from target player(s)." ) -- And since admins are dumb, we tell them what it does.

------ Set Current Ammo ------
function ulx.setCurrentAmmo(calling_ply, target_ply, amount, secondary)
	local affected_plys = {}
	if not target_ply then
		target_ply = calling_ply
	end
	if not secondary then
		if ammotypes[target_ply:GetActiveWeapon():GetPrimaryAmmoType()] ~= nil then
			target_ply:SetAmmo(amount, target_ply:GetActiveWeapon():GetPrimaryAmmoType())
				ulx.fancyLogAdmin(calling_ply, "#A set ammotype #s (#s) of #T to #s", target_ply:GetActiveWeapon():GetPrimaryAmmoType(), ammotypes[target_ply:GetActiveWeapon():GetPrimaryAmmoType()], target_ply, amount)
			else
				ULib.tsayError(calling_ply, "No Primary Ammo Type Defined - Try Secondary?", true)
			end
		else
			if ammotypes[target_ply:GetActiveWeapon():GetSecondaryAmmoType()] ~= nil then
				target_ply:SetAmmo(amount, target_ply:GetActiveWeapon():GetSecondaryAmmoType())
				ulx.fancyLogAdmin(calling_ply, "#A set ammotype #s (#s) of #T to #s",target_ply:GetActiveWeapon():GetSecondaryAmmoType() ,ammotypes[target_ply:GetActiveWeapon():GetSecondaryAmmoType()], target_ply, amount)
			else
				ULib.tsayError(calling_ply, "No Secondary Ammo Type Defined - Try Primary?", true)
			end
		end
	end
local stripamd = ulx.command( CATEGORY_NAME, "ulx setcurrentammo", ulx.setCurrentAmmo, "!setcurrentammo" )
stripamd:addParam{ type=ULib.cmds.PlayerArg, ULib.cmds.optional }
stripamd:addParam{ type=ULib.cmds.NumArg, min=0, hint="Amount" }
stripamd:addParam{ type=ULib.cmds.BoolArg, hint="Set Secondary Ammo", ULib.cmds.optional }
stripamd:defaultAccess( ULib.ACCESS_ADMIN )
stripamd:help( "Sets the ammo for the currently selected weapon for targeted player(s)." )

------ Get Current Ammo ID ------
function ulx.getAmmoID(calling_ply)
	ULib.tsay(calling_ply, "---- "..calling_ply:GetActiveWeapon():GetClass().." ----")
	ULib.tsay(calling_ply, "Primary Ammo: "..calling_ply:GetActiveWeapon():GetPrimaryAmmoType())
	ULib.tsay(calling_ply, "Secondary Ammo: "..calling_ply:GetActiveWeapon():GetSecondaryAmmoType())
end
local getammoid = ulx.command(CATEGORY_NAME, "ulx getammoid", ulx.getAmmoID, "!getammoid")
getammoid:defaultAccess(ULib.ACCESS_SUPERADMIN)
getammoid:help("Returns the numerical ammoID for the currently selected weapon (mainly for debug use).")

------- Get Ammo Name ------
function ulx.getAmmoName(calling_ply)
	primary = ammotypes[calling_ply:GetActiveWeapon():GetPrimaryAmmoType()] or "Undefined (ID: "..tostring(calling_ply:GetActiveWeapon():GetPrimaryAmmoType())..")"
	secondary = ammotypes[calling_ply:GetActiveWeapon():GetSecondaryAmmoType()] or "Undefined (ID: "..tostring(calling_ply:GetActiveWeapon():GetSecondaryAmmoType())..")"
	if primary == "Undefined (ID: "..tostring(calling_ply:GetActiveWeapon():GetPrimaryAmmoType())..")" and calling_ply:GetActiveWeapon():GetPrimaryAmmoType() == -1 then
		primary = "Nil"
	end
	if secondary == "Undefined (ID: "..tostring(calling_ply:GetActiveWeapon():GetSecondaryAmmoType())..")" and calling_ply:GetActiveWeapon():GetSecondaryAmmoType() == -1 then
		secondary = "Nil"
	end
	ULib.tsay(calling_ply, "---- "..calling_ply:GetActiveWeapon():GetClass().." ----")
	ULib.tsay(calling_ply, "Primary Ammo: "..primary)
	ULib.tsay(calling_ply, "Secondary Ammo: "..secondary)
end
local getammoname = ulx.command(CATEGORY_NAME, "ulx getammoname", ulx.getAmmoName, "!getammoname")
getammoname:defaultAccess(ULib.ACCESS_SUPERADMIN)
getammoname:help("Returns the name for the ammos of the currently selected weapon (or undefined) - Mostly for debug use.")

------ Drop Current Weapon ------
function ulx.dropCurrentWeapon(calling_ply, target_ply)
	if not target_ply then
		target_ply = calling_ply
	end
	target_ply:DropWeapon(target_ply:GetActiveWeapon())
	ulx.fancyLogAdmin(calling_ply, "#A forced #T to drop their current weapon.", target_ply)
end
dropweapon = ulx.command(CATEGORY_NAME, "ulx dropcurrentweapon", ulx.dropCurrentWeapon, "!dropcurrentweapon")
dropweapon:defaultAccess(ULib.ACCESS_ADMIN)
dropweapon:addParam{type=ULib.cmds.PlayerArg, ULib.cmds.optional}
dropweapon:help("Forces the target to drop their weapon")

------ Drop All Weapons ------
function ulx.dropAllWeapons(calling_ply, target_ply)
	if not target_ply then
		target_ply = calling_ply
	end
	for _, i in pairs(target_ply:GetWeapons()) do
		target_ply:DropWeapon(i)
	end
	ulx.fancyLogAdmin(calling_ply, "#A forced #T to drop all their weapons.", target_ply)
end
dropweapons = ulx.command(CATEGORY_NAME, "ulx dropweapons", ulx.dropAllWeapons, "!dropweapons")
dropweapons:defaultAccess(ULib.ACCESS_ADMIN)
dropweapons:addParam{type=ULib.cmds.PlayerArg, ULib.cmds.optional}
dropweapons:help("Forces the target to drop all their weapons.")

------- Strip All Weapons ------
function ulx.stripWeapons(calling_ply, target_ply)
	if not target_ply then
		target_ply = calling_ply
	end
	target_ply:StripWeapons()
	ulx.fancyLogAdmin(calling_ply, "#A stripped weapons from #T.", target_ply)
end
stripweapons = ulx.command(CATEGORY_NAME, "ulx strip", ulx.stripWeapons, "!strip")
stripweapons:defaultAccess(ULib.ACCESS_ADMIN)
stripweapons:addParam{type=ULib.cmds.PlayerArg, ULib.cmds.optional}
stripweapons:help("Strips weapons from the target.")

------ Strip Current Weapon ------
function ulx.stripWeapon(calling_ply, target_ply)
	if not target_ply then
		target_ply = calling_ply
	end
	
	target_ply:StripWeapon(target_ply:GetActiveWeapon():GetClass())
	ulx.fancyLogAdmin(calling_ply, "#A stripped the current weapon from #T.", target_ply)
end
stripweapon = ulx.command(CATEGORY_NAME, "ulx stripcurrent", ulx.stripWeapon, "!stripcurrent")
stripweapon:defaultAccess(ULib.ACCESS_ADMIN)
stripweapon:addParam{type=ULib.cmds.PlayerArg, ULib.cmds.optional}
stripweapon:help("Strips weapons from the target.")

------ Set Ammo ------
function ulx.setAmmoHelper(calling_ply)
	ULib.tsay(calling_ply, "------ Ammo Types -------", true)
	for i = 1, #ammoids do
		ULib.tsay(calling_ply, ammoids[i]..": "..ammotypes[ammoids[i]], true)
	end
end
gettypes = ulx.command(CATEGORY_NAME, "ulx getammotypes", ulx.setAmmoHelper, "!getammotypes")
gettypes:defaultAccess(ULib.ACCESS_ADMIN)
gettypes:help("Returns ammo types.")

function ulx.setAmmo(calling_ply, target_ply, ammo, amount)
	if not target_ply then
		target_ply = calling_ply
	end
	local isValidAmmo = false
	for i = 1, #ammoids do
		if ammo == ammoids[i] then
			isValidAmmo = true
		end
	end
	if not isValidAmmo then
		ULib.tsayError(calling_ply, "Ammotype not defined.")
	else
	target_ply:SetAmmo(amount, ammo)
	ulx.fancyLogAdmin(calling_ply, "#A set ammotype #s (#s) to #s for #T", ammo, ammotypes[ammo], amount, target_ply)
	end
end
setammo = ulx.command(CATEGORY_NAME, "ulx setammoall", ulx.setAmmo, "!setammoall")
setammo:defaultAccess(ULib.ACCESS_ADMIN)
setammo:addParam{type=ULib.cmds.PlayerArg, ULib.cmds.optional}
setammo:addParam{type=ULib.cmds.NumArg, min=0, hint="AmmoID"}
setammo:addParam{type=ULib.cmds.NumArg, min=0, hint="Amount"}
setammo:help("Returns ammo types.")
	