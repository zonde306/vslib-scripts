::GriefProtection <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,
		
		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
		
		// 保护持续时间
		Duration = 45,
		
		// 请出去模式.1=投票.2=直接kick
		KickType = 2,
		
		// 黑枪伤害
		DamageAllowance = 200,
		
		// 跳楼次数
		SuicideAllowance = 3,
	},
	
	ConfigVar = {},
	
	LastJump = {},
	FirstSpawn = {},
	TotalDamage = {},
	TotalSuicide = {},
	
	function Timer_Teleport(player)
	{
		if(player == null || !player.IsSurvivor())
			return;
		
		local steamID = player.GetSteamID();
		if(steamID in ::GriefProtection.LastJump)
		{
			player.SetLocation(::GriefProtection.LastJump[steamID]);
			player.SetVelocity(Vector(0, 0, 0));
		}
		
		if(::GriefProtection.ConfigVar.SuicideAllowance > 0 && ::GriefProtection.TotalSuicide[steamID] >= ::GriefProtection.ConfigVar.SuicideAllowance)
		{
			switch(::GriefProtection.ConfigVar.KickType)
			{
				case 1:
				{
					SendToServerConsole("callvote kick " + dmgTable["Attacker"].GetUserID());
					break;
				}
				case 2:
				{
					SendToServerConsole("kickid " + steamID + " \"suicide\"");
					break;
				}
			}
		}
	},
};

function EasyLogic::OnTakeDamage::GriefProtection_OnTakeDamage(dmgTable)
{
	if(!::GriefProtection.ConfigVar.Enable)
		return;
	
	if(dmgTable["Victim"] == null || !dmgTable["Victim"].IsSurvivor())
		return;
	
	if(dmgTable["Attacker"] != null && dmgTable["Attacker"].IsSurvivor() && dmgTable["Victim"].GetIndex() != dmgTable["Attacker"].GetIndex())
	{
		local steamID = dmgTable["Attacker"].GetSteamID();
		
		// 黑枪保护
		if(dmgTable["DamageDone"] <= 0.0 || (steamID in ::GriefProtection.FirstSpawn && ::GriefProtection.FirstSpawn[steamID] > Time()))
		{
			if(steamID in ::GriefProtection.TotalDamage)
				::GriefProtection.TotalDamage[steamID] += dmgTable["DamageDone"];
			else
				::GriefProtection.TotalDamage[steamID] <- dmgTable["DamageDone"];
			
			if(::GriefProtection.ConfigVar.DamageAllowance > 0 && ::GriefProtection.TotalDamage[steamID] >= ::GriefProtection.ConfigVar.DamageAllowance)
			{
				switch(::GriefProtection.ConfigVar.KickType)
				{
					case 1:
					{
						SendToServerConsole("callvote kick " + dmgTable["Attacker"].GetUserID());
						break;
					}
					case 2:
					{
						SendToServerConsole("kickid " + steamID + " \"ff\"");
						break;
					}
				}
			}
			
			return false;
		}
	}
	else if((dmgTable["DamageType"] & DMG_FALL) && dmgTable["DamageDone"] > 0)
	{
		local steamID = dmgTable["Victim"].GetSteamID();
		
		// 跳楼保护
		if(steamID in ::GriefProtection.FirstSpawn && ::GriefProtection.FirstSpawn[steamID] > Time())
		{
			if(steamID in ::GriefProtection.TotalSuicide)
				::GriefProtection.TotalSuicide[steamID] += 1;
			else
				::GriefProtection.TotalSuicide[steamID] <- 1;
			
			Timers.AddTimerByName("timer_suicide_" + steamID, 0.1, false, ::GriefProtection.Timer_Teleport, dmgTable["Victim"]);
			return false;
		}
	}
}

function Notifications::OnPlayerJoined::GriefProtection_FirstSpawn(player, name, ipAddress, steamID, params)
{
	if(steamID != "" && steamID != "BOT")
		::GriefProtection.FirstSpawn[steamID] <- Time() + ::GriefProtection.ConfigVar.Duration;
}

function Notifications::OnJump::GriefProtection_Jumping(player, params)
{
	if(player == null || !player.IsSurvivor() || player.IsBot())
		return;
	
	local steamID = player.GetSteamID();
	if(steamID in ::GriefProtection.FirstSpawn && ::GriefProtection.FirstSpawn[steamID] > Time())
		::GriefProtection.LastJump[steamID] <- player.GetLocation();
}

::GriefProtection.PLUGIN_NAME <- PLUGIN_NAME;
::GriefProtection.ConfigVar = ::GriefProtection.ConfigVarDef;

function Notifications::OnRoundStart::GriefProtection_LoadConfig()
{
	RestoreTable(::GriefProtection.PLUGIN_NAME, ::GriefProtection.ConfigVar);
	if(::GriefProtection.ConfigVar == null || ::GriefProtection.ConfigVar.len() <= 0)
		::GriefProtection.ConfigVar = FileIO.GetConfigOfFile(::GriefProtection.PLUGIN_NAME, ::GriefProtection.ConfigVarDef);

	// printl("[plugins] " + ::GriefProtection.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::GriefProtection_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::GriefProtection.PLUGIN_NAME, ::GriefProtection.ConfigVar);

	// printl("[plugins] " + ::GriefProtection.PLUGIN_NAME + " saving...");
}
