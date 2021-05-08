::PillPassFix <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,
		
		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
	},
	
	ConfigVar = {},
	
	function CanPickupItem(player, slot = "slot4")
	{
		if(player == null || !player.IsSurvivor() || player.IsDead())
			return false;
		
		local inv = player.GetHeldItems();
		return (!(slot in inv) || inv[slot] == null || !inv[slot].IsValid());
	},
	
	function FindGiveReceiver(player, radius = 600, tolerance = 75, ignore = null)
	{
		local clientPos = player.GetEyePosition();
		local clientAimVector = player.GetEyeAngles().Forward();
		
		local minAng = tolerance;
		local receiver = null;
		
		foreach(survivor in Objects.OfClassnameWithin("player", player.GetLocation(), radius))
		{
			if(survivor == ignore || survivor == player || !::PillPassFix.CanPickupItem(survivor))
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
	
	function Timer_PickupWeapon(params)
	{
		if(!params["weapon"].IsValid() || !params["player"].IsSurvivor() || params["player"].IsDead())
			return false;
		
		local owner = params["weapon"].GetOwnerEntity();
		
		// 还没飞出来
		if(owner == params["giver"])
			return;
		
		// 飞出去了
		if(owner == null || !owner.IsValid())
		{
			params["weapon"].Input("Use", "", 0, params["player"]);
			printl("player " + params["player"] + " pickup a " + params["weapon"]);
			return false;
		}
		
		// 被别人抢走了
		if(owner != params["giver"])
		{
			printl("weapon " + params["weapon"] + " have owner " + owner);
			return false;
		}
	},
};

function Notifications::OnWeaponDropped::PillPassFix(player, weapon, params)
{
	if(!::PillPassFix.ConfigVar.Enable)
		return;
	
	// printl("player " + player + " drop " + weapon);
	
	if(player == null || weapon == null || !player.IsSurvivor() || !weapon.IsValid())
		return;
	
	local classname = weapon.GetClassname();
	if(classname != "weapon_adrenaline" && classname != "weapon_pain_pills")
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
	if(!::PillPassFix.CanPickupItem(receiver))
		receiver = ::PillPassFix.FindGiveReceiver(player, radius, 30, receiver);
	
	if(::PillPassFix.CanPickupItem(receiver))
	{
		Timers.AddTimerByName("pillpass_" + weapon.GetIndex(), 0.01, true,
			::PillPassFix.Timer_PickupWeapon, {
			"player" : receiver,
			"giver" : player,
			"weapon" : weapon,
		});
		
		printl("player " + player + " drop " + weapon + " to " + receiver);
	}
	else
	{
		printl("player " + player + " drop " + weapon + " to unknown.");
	}
}

/*
function Notifications::OnWeaponGiven::PillPassFix(receiver, giver, weapon, params)
{
	if(!::PillPassFix.ConfigVar.Enable)
		return;
	
	printl("player " + giver + " give " + receiver + " a " + weapon);
	
	if(receiver == null || giver == null || weapon == null ||
		!receiver.IsSurvivor() || !giver.IsSurvivor() || !weapon.IsValid())
		return;
	
	if(params["weapon"] == 15 || params["weapon"] == 23)
	{
		// 此时已经拿到物品了，正准备切出来
		Timers.AddTimerByName("pillpass_" + weapon.GetIndex(), 0.01, true,
			::PillPassFix.Timer_PickupWeapon, {
			"player" : receiver,
			"giver" : giver,
			"weapon" : weapon,
		});
	}
}
*/

::PillPassFix.PLUGIN_NAME <- PLUGIN_NAME;
::PillPassFix.ConfigVar = ::PillPassFix.ConfigVarDef;

function Notifications::OnRoundStart::PillPassFix_LoadConfig()
{
	RestoreTable(::PillPassFix.PLUGIN_NAME, ::PillPassFix.ConfigVar);
	if(::PillPassFix.ConfigVar == null || ::PillPassFix.ConfigVar.len() <= 0)
		::PillPassFix.ConfigVar = FileIO.GetConfigOfFile(::PillPassFix.PLUGIN_NAME, ::PillPassFix.ConfigVarDef);

	// printl("[plugins] " + ::PillPassFix.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::PillPassFix_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::PillPassFix.PLUGIN_NAME, ::PillPassFix.ConfigVar);

	// printl("[plugins] " + ::PillPassFix.PLUGIN_NAME + " saving...");
}
