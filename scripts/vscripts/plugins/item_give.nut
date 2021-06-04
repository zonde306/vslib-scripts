::ItemGive <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
		
		// 允许通过推来递给别人的物品.1=医疗包.2=电击.4=燃烧升级包.8=高爆升级包.16=土制炸弹.32=燃烧瓶.64=胆汁瓶
		ShoveGive = 2 + 4 + 8 + 16 + 32 + 64,
		
		// 允许通过R键来递给别人的物品.1=医疗包.2=电击.4=燃烧升级包.8=高爆升级包.16=土制炸弹.32=燃烧瓶.64=胆汁瓶
		ReloadGive = 1 + 2 + 4 + 8 + 16 + 32 + 64,
		
		// 捡起物品延迟
		PickupDelay = 0.5,
		
		// 检查间隔
		ThinkInterval = 0.3,
	},
	
	ConfigVar = {},
	
	function CanGiveItem(classname, flags)
	{
		switch(classname)
		{
			case "weapon_first_aid_kit":
				return !!(flags & 1);
			case "weapon_defibrillator":
				return !!(flags & 2);
			case "weapon_upgradepack_incendiary":
				return !!(flags & 4);
			case "weapon_upgradepack_explosive":
				return !!(flags & 8);
			case "weapon_pipe_bomb":
				return !!(flags & 16);
			case "weapon_molotov":
				return !!(flags & 32);
			case "weapon_vomitjar":
				return !!(flags & 64);
		}
		
		return false;
	},
	
	function GetWeaponSlot(classname)
	{
		switch(classname)
		{
			case "weapon_first_aid_kit":
			case "weapon_defibrillator":
			case "weapon_upgradepack_incendiary":
			case "weapon_upgradepack_explosive":
				return SLOT_MEDKIT;
			case "weapon_pipe_bomb":
			case "weapon_molotov":
			case "weapon_vomitjar":
				return SLOT_THROW;
		}
		
		return null;
	},
	
	function Timer_CheckGive(params)
	{
		foreach(player in Players.AliveSurvivors())
		{
			if(player.IsBot() || !player.IsPressingReload() || player.IsIncapacitated() || player.IsHangingFromLedge())
				continue;
			
			local weapon = player.GetActiveWeapon();
			if(weapon == null || !weapon.IsValid())
				return;
			
			local classname = weapon.GetClassname();
			local slot = ::ItemGive.GetWeaponSlot(classname);
			if(slot == null)
				return;
			
			if(!::ItemGive.CanGiveItem(classname, ::ItemGive.ConfigVar.ShoveGive))
				return;
			
			local radius = 600;
			local startPt = player.GetEyePosition();
			local endPt = startPt + player.GetEyeAngles().Forward().Scale(radius);
			
			local trace = {
				start = startPt,
				end = endPt,
				ignore = player.GetBaseEntity(),
				mask = TRACE_MASK_SHOT,
			};
			
			TraceLine(trace);
			
			local receiver = null
			if(trace.hit && trace.enthit && trace.enthit != trace.ignore && trace.enthit.IsValid() && trace.enthit.GetClassname() == "player")
				receiver = Utils.GetEntityOrPlayer(trace.enthit);
			if(!::ItemGive.CanPickupItem(receiver, slot))
				receiver = ::ItemGive.FindGiveReceiver(player, slot, radius, 30, receiver);
			
			if(::ItemGive.CanPickupItem(receiver, slot))
			{
				player.Drop(classname);
				weapon.Input("Use", "", ::ItemGive.ConfigVar.PickupDelay, receiver);
			}
		}
	},
	
	function FindGiveReceiver(player, slot, radius = 600, tolerance = 75, ignore = null)
	{
		local clientPos = player.GetEyePosition();
		local clientAimVector = player.GetEyeAngles().Forward();
		
		local minAng = tolerance;
		local receiver = null;
		
		foreach(survivor in Objects.OfClassnameWithin("player", player.GetLocation(), radius))
		{
			if(survivor == ignore || survivor == player || !::ItemGive.CanPickupItem(survivor, slot))
				continue;
			
			local targetPos = survivor.GetLocation();
			
			// 中间
			targetPos.z += fabs(survivor.GetEyePosition().z - targetPos.z) / 2.0;
			
			local clientToTargetVec = targetPos - clientPos;
			local angToFind = acos(Utils.VectorDotProduct(clientAimVector, clientToTargetVec) / (clientAimVector.Length() * clientToTargetVec.Length())) * 360 / 2 / 3.14159265;
			if(angToFind > minAng)
				continue;
			
			local trace = {
				start = clientPos,
				end = targetPos,
				ignore = player.GetBaseEntity(),
				mask = TRACE_MASK_SHOT,
			};
			
			TraceLine(trace);
			
			if(trace.fraction > 0.97 || (trace.hit && trace.enthit == survivor.GetBaseEntity()))
			{
				receiver = survivor;
				minAng = angToFind;
			}
		}
		
		return receiver;
	},
	
	function CanPickupItem(player, slot)
	{
		if(player == null || !player.IsSurvivor() || player.IsDead())
			return false;
		
		if(player.GetWeaponSlot(slot) != null || player.IsIncapacitated() || player.IsHangingFromLedge())
			return false;
		
		return true;
	},
};

function Notifications::OnRoundBegin::BotPickupActtive(params)
{
	if(!::ItemGive.ConfigVar.Enable)
		return;
	
	Timers.AddTimerByName("timer_itemgive", ::ItemGive.ConfigVar.ThinkInterval, true, ::ItemGive.Timer_CheckGive);
}

function Notifications::FirstSurvLeftStartArea::BotPickupActtive(player, params)
{
	if(!::ItemGive.ConfigVar.Enable)
		return;
	
	Timers.AddTimerByName("timer_itemgive", ::ItemGive.ConfigVar.ThinkInterval, true, ::ItemGive.Timer_CheckGive);
}

function Notifications::OnPlayerShoved::ItemGive_Give(victim, attacker, params)
{
	if(!::ItemGive.ConfigVar.Enable)
		return;
	
	if(attacker == null || victim == null || !attacker.IsSurvivor() || !victim.IsSurvivor())
		return;
	
	local weapon = attacker.GetActiveWeapon();
	if(weapon == null || !weapon.IsValid())
		return;
	
	local classname = weapon.GetClassname();
	local slot = ::ItemGive.GetWeaponSlot(classname);
	if(slot == null)
		return;
	
	if(!::ItemGive.CanGiveItem(classname, ::ItemGive.ConfigVar.ShoveGive))
		return;
	
	if(victim.GetWeaponSlot(slot) != null)
		return;
	
	attacker.Drop(classname);
	weapon.Input("Use", "", ::ItemGive.ConfigVar.PickupDelay, victim);
}

::ItemGive.PLUGIN_NAME <- PLUGIN_NAME;
::ItemGive.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::ItemGive.ConfigVarDef);

function Notifications::OnRoundStart::ItemGive_LoadConfig()
{
	RestoreTable(::ItemGive.PLUGIN_NAME, ::ItemGive.ConfigVar);
	if(::ItemGive.ConfigVar == null || ::ItemGive.ConfigVar.len() <= 0)
		::ItemGive.ConfigVar = FileIO.GetConfigOfFile(::ItemGive.PLUGIN_NAME, ::ItemGive.ConfigVarDef);

	// printl("[plugins] " + ::ItemGive.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::ItemGive_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::ItemGive.PLUGIN_NAME, ::ItemGive.ConfigVar);

	// printl("[plugins] " + ::ItemGive.PLUGIN_NAME + " saving...");
}
