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
	
	function CanPickupPills(player)
	{
		if(player == null || !player.IsSurvivor() || player.IsDead())
			return false;
		
		local inv = player.GetHeldItems();
		return (!("slot4" in inv) || inv["slot4"] == null || !inv["slot4"].IsValid());
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
			printl("player " + params["player"].GetName() + " pickup a " + params["weapon"].GetName());
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
	
	printl("player " + player + " drop " + weapon);
	
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
	
	if(!trace.hit || trace.enthit == null || trace.enthit == trace.ignore)
		return;
	
	if(!trace.enthit.IsValid() || trace.enthit.GetClassname() != "player")
		return;
	
	local receiver = Utils.GetEntityOrPlayer(trace.enthit);
	if(!::PillPassFix.CanPickupPills(receiver))
	{
		foreach(survivor in Objects.OfClassnameWithin("player", player.GetLocation(), radius))
		{
			if(survivor == receiver || survivor == player || !survivor.IsSurvivor() || survivor.IsDead())
				continue;
			
			if(!player.CanSeeOtherEntity(survivor, 90))
				continue;
			
			receiver = survivor;
			break;
		}
	}
	if(::PillPassFix.CanPickupPills(receiver))
	{
		Timers.AddTimerByName("pillpass_" + weapon.GetIndex(), 0.01, true,
			::PillPassFix.Timer_PickupWeapon, {
			"player" : receiver,
			"giver" : player,
			"weapon" : weapon,
		});
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
