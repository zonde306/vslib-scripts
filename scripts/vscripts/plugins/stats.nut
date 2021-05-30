::Stats <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
		
		// 显示持续时间
		Duration = 5,
		
		// 最大字符数
		MaxLength = 200,
	},
	
	ConfigVar = {},
	
	iSIKills = {},
	iCIKills = {},
	iWitchKills = {},
	iSIHeadshots = {},
	iCIHeadshots = {},
	iDamages = {},
	iFF = {},
	
	function PrintDamageInfo(player)
	{
		if(player == null || !player.IsSurvivor())
			return;
		
		local auid = player.GetUserID();
		if(!(auid in ::Stats.iDamages))
			return;
		
		local message = "";
		local toBeDelete = [];
		local time = Time() - ::Stats.ConfigVar.Duration;
		foreach(vuid, data in ::Stats.iDamages[auid])
		{
			if(data["time"] <= time)
			{
				toBeDelete.append(vuid);
				continue;
			}
			
			if(data["killed"])
			{
				if(data["headshot"])
					message += "headshot|" + data["name"];
				else
					message += "killed|" + data["name"];
			}
			else if(data["total_damage"] > data["damage"])
			{
				message += "-" + data["damage"] + "/" + data["total_damage"] + "|" + data["name"] + "|" + data["health"] + "rem";
			}
			else
			{
				message += "-" + data["damage"] + "|" + data["name"] + "|" + data["health"] + "rem";
			}
			message += "\n";
			
			if(message.len() > ::Stats.ConfigVar.MaxLength)
			{
				message = Utils.StringReplace(message, @"\n[^\n]+\n$", "");
				break;
			}
		}
		
		player.PrintToCenter(message);
		
		foreach(vuid in toBeDelete)
		{
			if(vuid in ::Stats.iDamages[auid])
				delete ::Stats.iDamages[auid][vuid];
		}
	},
};

function Notifications::OnDeath::Stats(victim, attacker, params)
{
	if(!::Stats.ConfigVar.Enable)
		return;
	
	if(attacker == null || victim == null || !attacker.IsSurvivor() || !victim.IsValid() || victim.GetTeam() != INFECTED)
		return;
	
	local auid = attacker.GetUserID();
	local vuid = victim.GetIndex();
	local type = victim.GetType();
	local name = "";
	if(type == Z_COMMON)
	{
		if(!(auid in ::Stats.iCIKills))
			::Stats.iCIKills[auid] <- 1;
		else
			::Stats.iCIKills[auid] += 1;
		
		if("headshot" in params && params["headshot"])
		{
			if(!(auid in ::Stats.iCIHeadshots))
				::Stats.iCIHeadshots[auid] <- 1;
			else
				::Stats.iCIHeadshots[auid] += 1;
		}
		
		name = "Infected(" + vuid + ")";
	}
	else if(type == Z_WITCH || type == Z_WITCH_BRIDE)
	{
		if(!(auid in ::Stats.iWitchKills))
			::Stats.iWitchKills[auid] <- 1;
		else
			::Stats.iWitchKills[auid] += 1;
		
		name = "Witch(" + vuid + ")";
	}
	else if((type >= Z_SMOKER && type <= Z_CHARGER) || type == Z_TANK)
	{
		if(!(auid in ::Stats.iSIKills))
			::Stats.iSIKills[auid] <- 1;
		else
			::Stats.iSIKills[auid] += 1;
		
		if("headshot" in params && params["headshot"])
		{
			if(!(auid in ::Stats.iSIHeadshots))
				::Stats.iSIHeadshots[auid] <- 1;
			else
				::Stats.iSIHeadshots[auid] += 1;
		}
		
		name = victim.GetName();
	}
	
	if(!(auid in ::Stats.iDamages))
		::Stats.iDamages[auid] <- {};
	
	if(!(vuid in ::Stats.iDamages[auid]))
	{
		::Stats.iDamages[auid][vuid] <- {
			"damage" : 0,
			"health" : 0,
			"killed" : true,
			"name" : name,
			"time" : Time(),
			"headshot" : ("headshot" in params && params["headshot"]),
			"total_damage" : 0,
		};
	}
	else
	{
		::Stats.iDamages[auid][vuid]["health"] <- 0;
		::Stats.iDamages[auid][vuid]["killed"] <- true;
		::Stats.PrintDamageInfo(attacker);
	}
}

function Notifications::OnHurt::Stats(victim, attacker, params)
{
	if(!::Stats.ConfigVar.Enable)
		return;
	
	if(attacker == null || victim == null || !attacker.IsSurvivor() || !victim.IsValid())
		return;
	
	local auid = attacker.GetUserID();
	local vuid = victim.GetIndex();
	
	local type = victim.GetType();
	if((type >= Z_SMOKER && type <= Z_CHARGER) || type == Z_TANK)
	{
		if(!(auid in ::Stats.iDamages))
			::Stats.iDamages[auid] <- {};
		
		if(!(vuid in ::Stats.iDamages[auid]))
		{
			::Stats.iDamages[auid][vuid] <- {
				"damage" : params["dmg_health"],
				"health" : params["health"],
				"killed" : (params["health"] <= 0),
				"name" : victim.GetName(),
				"time" : Time(),
				"headshot" : (params["hitgroup"] == 1),
				"total_damage" : params["dmg_health"],
			};
		}
		else
		{
			::Stats.iDamages[auid][vuid]["damage"] = params["dmg_health"];
			::Stats.iDamages[auid][vuid]["total_damage"] += params["dmg_health"];
			::Stats.iDamages[auid][vuid]["health"] = params["health"];
			::Stats.iDamages[auid][vuid]["killed"] = (params["health"] <= 0);
			::Stats.iDamages[auid][vuid]["time"] = Time();
			::Stats.iDamages[auid][vuid]["headshot"] = (params["hitgroup"] == 1);
		}
		
		if(!(params["type"] & (DMG_BURN|DMG_BUCKSHOT)) && params["weapon"].find("shotgun") == null)
			::Stats.PrintDamageInfo(attacker);
		else
			Timers.AddTimerByName("stats_" + auid, 0.01, false, ::Stats.PrintDamageInfo, attacker, 0, { "action" : "reset" });
	}
	else if(type == Z_SURVIVOR && attacker != victim)
	{
		if(!(auid in ::Stats.iFF))
			::Stats.iFF[auid] <- params["dmg_health"];
		else
			::Stats.iFF[auid] += params["dmg_health"];
	}
}

function Notifications::OnInfectedHurt::Stats(victim, attacker, params)
{
	if(!::Stats.ConfigVar.Enable)
		return;
	
	if(attacker == null || victim == null || !attacker.IsSurvivor() || !victim.IsValid())
		return;
	
	local auid = attacker.GetUserID();
	local vuid = victim.GetIndex();
	local name = "";
	local health = victim.GetHealth() - params["amount"];
	
	if(victim.GetType() == Z_COMMON)
		name = "Infected(" + vuid + ")";
	else
		name = "Witch(" + vuid + ")";
	
	if(!(auid in ::Stats.iDamages))
		::Stats.iDamages[auid] <- {};
	
	if(!(vuid in ::Stats.iDamages[auid]))
	{
		::Stats.iDamages[auid][vuid] <- {
			"damage" : params["amount"],
			"health" : health,
			"killed" : (health <= 0),
			"name" : name,
			"time" : Time(),
			"headshot" : (params["hitgroup"] == 1),
			"total_damage" : params["amount"],
		};
	}
	else
	{
		::Stats.iDamages[auid][vuid]["damage"] = params["amount"];
		::Stats.iDamages[auid][vuid]["total_damage"] += params["amount"];
		::Stats.iDamages[auid][vuid]["health"] = health;
		::Stats.iDamages[auid][vuid]["killed"] = (health <= 0);
		::Stats.iDamages[auid][vuid]["time"] = Time();
		::Stats.iDamages[auid][vuid]["headshot"] = (params["hitgroup"] == 1);
	}
	
	if(!(params["type"] & (DMG_BURN|DMG_BUCKSHOT)))
		::Stats.PrintDamageInfo(attacker);
	else
		Timers.AddTimerByName("stats_" + auid, 0.01, false, ::Stats.PrintDamageInfo, attacker, 0, { "action" : "reset" });
}

function Notifications::OnSurvivorsDead::Stats()
{
	if(!::Stats.ConfigVar.Enable)
		return;
	
	local messages = "";
	foreach(player in Players.Survivors())
	{
		local uid = player.GetUserID();
		local message = player.GetName() + " - ";
		
		if(uid in ::Stats.iSIKills)
		{
			message += "" + ::Stats.iSIKills[uid] + "si";
			if(uid in ::Stats.iSIHeadshots)
				message += "/" + ::Stats.iSIHeadshots[uid] + "hs";
			else
				message += "/0hs";
		}
		else
		{
			message += "0si/0hs";
		}
		
		if(uid in ::Stats.iCIKills)
		{
			message += ", " + ::Stats.iCIKills[uid] + "ci";
			if(uid in ::Stats.iCIHeadshots)
				message += "/" + ::Stats.iCIHeadshots[uid] + "hs";
			else
				message += "/0hs";
		}
		else
		{
			message += ", 0ci/0hs";
		}
		
		if(uid in ::Stats.iWitchKills)
		{
			message += ", " + ::Stats.iWitchKills[uid] + "witch";
		}
		
		if(uid in ::Stats.iFF)
		{
			message += ", " + ::Stats.iFF[uid] + "ff";
		}
		
		messages += message + "\n";
		Utils.PrintToChatAll("\x05" + message);
	}
	
	HUDPlace(HUD_MID_BOX, 0.25, 0.3, 0.5, 0.4);
	HUDSetLayout({
		"Fields" : {
			"stats" : {
				"slot" : HUD_MID_BOX,
				"flags" : HUD_FLAG_ALIGN_CENTER|HUD_FLAG_TEAM_SURVIVORS,
				"name" : "stats",
				"dataval" : messages,
			},
		},
	});
	
	::Stats.iCIHeadshots <- {};
	::Stats.iCIKills <- {};
	::Stats.iDamages <- {};
	::Stats.iSIHeadshots <- {};
	::Stats.iSIKills <- {};
	::Stats.iWitchKills <- {};
}

::Stats.PLUGIN_NAME <- PLUGIN_NAME;
::Stats.ConfigVar = ::Stats.ConfigVarDef;

function Notifications::OnRoundStart::Stats_LoadConfig()
{
	RestoreTable(::Stats.PLUGIN_NAME, ::Stats.ConfigVar);
	if(::Stats.ConfigVar == null || ::Stats.ConfigVar.len() <= 0)
		::Stats.ConfigVar = FileIO.GetConfigOfFile(::Stats.PLUGIN_NAME, ::Stats.ConfigVarDef);

	// printl("[plugins] " + ::Stats.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::Stats_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::Stats.PLUGIN_NAME, ::Stats.ConfigVar);

	// printl("[plugins] " + ::Stats.PLUGIN_NAME + " saving...");
}
