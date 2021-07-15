::BotIdleFix <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
		
		// 观察距离
		ViewRange = 600,
	},
	
	ConfigVar = {},
	
	function Timer_Think(params)
	{
		if(Objects.AnyOfClassname("pipe_bomb_projectile") == null)
			return;
		
		foreach(player in Players.AliveSurvivorBots())
		{
			if(player.IsHangingFromLedge() || player.IsSurvivorTrapped() || player.IsStaggering() || player.IsGettingUp() || player.IsImmobilized())
				continue;
			
			local weapon = player.GetActiveWeapon();
			if(weapon == null || !weapon.IsValid())
				continue;
			
			local canFire = false;
			local classname = weapon.GetClassname();
			local radius = ::BotIdleFix.ConfigVar.ViewRange;
			if(Utils.IsValidFireWeapon(classname) && weapon.GetClip() > 0)
			{
				// 射击
				canFire = true;
			}
			else if(Utils.IsValidMeleeWeapon(classname))
			{
				// 劈砍
				canFire = true;
				radius = Convars.GetFloat("melee_range");
			}
			else
			{
				// 推
				radius = Convars.GetFloat("z_gun_range");
			}
			
			// 试试能不能启动填装
			if(!canFire)
				::BotIdleFix.ForceReload(player, weapon);
			
			local trace = {
				"start" : player.GetEyePosition(),
				"end" : player.GetEyePosition() + player.GetEyeAngles().Forward().Scale(radius),
				"ignore" : player.GetBaseEntity(),
				"mask" : TRACE_MASK_SHOT,
			};
			
			TraceLine(trace);
			
			if(!trace.hit || trace.enthit == null || trace.enthit == trace.ignore || !trace.enthit.IsValid() || trace.enthit.GetEntityIndex() <= 0)
				continue;
			
			local aiming = Utils.GetEntityOrPlayer(trace.enthit);
			if(aiming.GetTeam() != INFECTED)
				continue;
			
			if(canFire)
				::BotIdleFix.ForceFire(player, weapon);
			else
				::BotIdleFix.ForceShove(player, weapon);
			
			printl("bot " + player + " aiming " + aiming + " on canFire " + canFire);
		}
	},
	
	function WeaponCanFire(weapon)
	{
		if(weapon == null || !weapon.IsValid())
			return false;
		
		local classname = weapon.GetClassname();
		if(Utils.IsValidFireWeapon(classname) && weapon.GetClip() > 0)
			return true;
		if(Utils.IsValidMeleeWeapon(classname))
			return true;
		return false;
	},
	
	function ForceReload(player, weapon)
	{
		if(weapon.HasNetProp("m_bInReload") && !weapon.GetNetPropBool("m_bInReload"))
			weapon.Reload();
	},
	
	function ForceFire(player, weapon)
	{
		if(weapon.HasNetProp("m_flNextPrimaryAttack"))
		{
			if(weapon.GetNetPropFloat("m_flNextPrimaryAttack") <= Time())
			{
				player.ForceButton(BUTTON_ATTACK);
				Timers.AddTimerByName("timer_forcefire_" + player.GetIndex(), 0.2, false, ::BotIdleFix.Timer_StopFire, player, 0, { "action" : "reset" });
			}
		}
	},
	
	function Timer_StopFire(player)
	{
		if(player.IsSurvivor())
			player.UnforceButton(BUTTON_ATTACK);
	},
	
	function ForceShove(player, weapon)
	{
		if(player.HasNetProp("m_flNextShoveTime"))
		{
			if(player.GetNetPropFloat("m_flNextShoveTime") <= Time())
			{
				player.ForceButton(BUTTON_SHOVE);
				Timers.AddTimerByName("timer_forceshove_" + player.GetIndex(), 0.2, false, ::BotIdleFix.Timer_StopShove, player, 0, { "action" : "reset" });
			}
		}
	},
	
	function Timer_StopShove(player)
	{
		if(player.IsSurvivor())
			player.UnforceButton(BUTTON_SHOVE);
	},
	
	function Timer_ShutdownPipebomb(params)
	{
		foreach(ent in Objects.OfClassname("pipe_bomb_projectile"))
		{
			ent.SetNetPropInt("m_iHammerID", 19712806);
			ent.SetKeyValue("classname", "prop_physics");
		}
	}
};

/*
function Notifications::FirstSurvLeftStartArea::BotIdleFix(player, params)
{
	Timers.AddTimerByName("timer_sbidlefix", 0.5, true, ::BotIdleFix.Timer_Think);
}

function Notifications::OnSurvivorsLeftStartArea::BotIdleFix()
{
	Timers.AddTimerByName("timer_sbidlefix", 0.5, true, ::BotIdleFix.Timer_Think);
}
*/

function Notifications::OnWeaponFire::BotIdleFix(player, classname, params)
{
	if(!::BotIdleFix.ConfigVar.Enable)
		return;
	
	if(!("weaponid" in params) || params["weaponid"] != 14)
		return;
	
	Timers.AddTimerByName("timer_shutdown_pipebomb", 0.2, false, ::BotIdleFix.Timer_ShutdownPipebomb, null, 0, { "action" : "reset" });
}

::BotIdleFix.PLUGIN_NAME <- PLUGIN_NAME;
::BotIdleFix.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::BotIdleFix.ConfigVarDef);

function Notifications::OnRoundStart::BotIdleFix_LoadConfig()
{
	RestoreTable(::BotIdleFix.PLUGIN_NAME, ::BotIdleFix.ConfigVar);
	if(::BotIdleFix.ConfigVar == null || ::BotIdleFix.ConfigVar.len() <= 0)
		::BotIdleFix.ConfigVar = FileIO.GetConfigOfFile(::BotIdleFix.PLUGIN_NAME, ::BotIdleFix.ConfigVarDef);

	// printl("[plugins] " + ::BotIdleFix.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::BotIdleFix_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::BotIdleFix.PLUGIN_NAME, ::BotIdleFix.ConfigVar);

	// printl("[plugins] " + ::BotIdleFix.PLUGIN_NAME + " saving...");
}
