::PointTeleport <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = false,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 7,

		// 允许使用该功能的队伍.1=全部.2=生还者.3=感染者
		AllowTeam = 1,

		// 在玩家受到多少掉落伤害时自动读点
		FallTeleport = 0,

		// 两次存点的最小间隔(秒)
		SaveInterval = 3,

		// 两次读点的最小间隔(秒)
		LoadInterval = 3,

		// 允许回退多少层
		Backtracking = 1,

		// 是否必须要在地上才能存点
		Ground = true,

		// 存点次数上限.0=无限制
		SaveLimit = 0,

		// 读点次数上限.0=无限制
		LoadLimit = 0,

		// 回退次数上限.0=无限制
		BackLimit = 1,

		// 是否开启读点防摔死
		FallDamage = true
	},

	ConfigVar = {},

	PlayerPoint = {},
	HistoryPoint = {},
	LoadUsed = {},
	BackUsed = {},
	BacktrackingUsed = {},
	
	NextAllowSave = {},
	NextAllowLoad = {},
	AntiFallDamage = {},
	
	function Timer_ResetAntiFallDamage(index)
	{
		if(index in ::PointTeleport.AntiFallDamage)
			delete ::PointTeleport.AntiFallDamage[index];
	},
	
	function DoNoFallDamage(index)
	{
		::PointTeleport.AntiFallDamage[index] <- true;
		Timers.AddTimerByName("timer_tp_nofalldamage_" + index, 0.1, false,
			::PointTeleport.Timer_ResetAntiFallDamage, index);
	}
};

function EasyLogic::OnTakeDamage::PointTeleport_AntiFallDamage(dmgTable)
{
	if(!::PointTeleport.ConfigVar.Enable || !::PointTeleport.ConfigVar.FallDamage)
		return true;
	
	if(dmgTable["Victim"] == null || dmgTable["DamageDone"] <= 0.0 || !dmgTable["Victim"].IsSurvivor())
		return true;
	
	if(dmgTable["DamageType"] & DMG_FALL)
	{
		local index = dmgTable["Victim"].GetIndex();
		if(index in ::PointTeleport.AntiFallDamage && ::PointTeleport.AntiFallDamage[index])
		{
			delete ::PointTeleport.AntiFallDamage[index];
			return false;
		}
		
		if(::PointTeleport.ConfigVar.FallTeleport > 0 && dmgTable["DamageDone"] >= ::PointTeleport.ConfigVar.FallTeleport &&
			index in ::PointTeleport.PlayerPoint)
		{
			// 掉落伤害自动读点
			CommandTriggersEx.dd(dmgTable["Victim"], null, null);
			
			if(::AdminSystem.IsAdmin(dmgTable["Victim"], false))
				return false;
			
			// 保证不会摔死(但是会倒地)
			return dmgTable["Victim"].GetHealth();
		}
	}
	
	return true;
}

function CommandTriggersEx::cd(player, args, text)
{
	if(!::PointTeleport.ConfigVar.Enable)
	{
		player.ShowHint("This command is disabled", 9);
		return;
	}
	
	if(::PointTeleport.ConfigVar.AllowTeam != 1 && ::PointTeleport.ConfigVar.AllowTeam != player.GetTeam())
	{
		player.ShowHint("Your team can not use this command", 9);
		return;
	}
	
	if(player.IsDead() || player.IsGhost())
	{
		player.ShowHint("This command can only be used if it is alive");
		return;
	}
	
	if(::PointTeleport.ConfigVar.Ground && !(player.GetFlags() & FL_ONGROUND))
	{
		player.ShowHint("Must stand on the ground");
		return;
	}
	
	local index = player.GetIndex();
	if(index in ::PointTeleport.HistoryPoint)
	{
		if(::PointTeleport.ConfigVar.SaveLimit > 0 && ::PointTeleport.HistoryPoint[index].len() - 1 >= ::PointTeleport.ConfigVar.SaveLimit)
		{
			player.ShowHint("Has reached the limit of use");
			return;
		}
	}
	
	local time = Time();
	if(index in ::PointTeleport.NextAllowSave && ::PointTeleport.NextAllowSave[index] > time)
	{
		player.ShowHint("You need to wait " + (::PointTeleport.NextAllowSave[index] - time) +
			" seconds before you can use it", 9);
		return;
	}
	
	if(index in ::PointTeleport.PlayerPoint)
	{
		if(!(index in ::PointTeleport.HistoryPoint))
			::PointTeleport.HistoryPoint[index] <- [::PointTeleport.PlayerPoint[index]];
		else
			::PointTeleport.HistoryPoint[index].push(::PointTeleport.PlayerPoint[index]);
	}
	
	if(index in ::PointTeleport.BacktrackingUsed && ::PointTeleport.BacktrackingUsed[index] > 0)
		::PointTeleport.BacktrackingUsed[index] -= 1;
	
	::PointTeleport.NextAllowSave[index] <- time + ::PointTeleport.ConfigVar.SaveInterval;
	::PointTeleport.PlayerPoint[index] <-
	{
		position = player.GetLocation(),
		angles = player.GetEyeAngles()
	};
	
	player.PlaySoundEx("ui/alert_clink.wav");
	player.ShowHint("Save finished");
}

function CommandTriggersEx::dd(player, args, text)
{
	if(!::PointTeleport.ConfigVar.Enable)
	{
		player.ShowHint("This command is disabled", 9);
		return;
	}
	
	if(::PointTeleport.ConfigVar.AllowTeam != 1 && ::PointTeleport.ConfigVar.AllowTeam != player.GetTeam())
	{
		player.ShowHint("Your team can not use this command", 9);
		return;
	}
	
	if(player.IsDead() || player.IsGhost())
	{
		player.ShowHint("This command can only be used if it is alive");
		return;
	}
	
	local index = player.GetIndex();
	if(index in ::PointTeleport.LoadUsed)
	{
		if(::PointTeleport.ConfigVar.LoadLimit > 0 && ::PointTeleport.LoadUsed[index] >= ::PointTeleport.ConfigVar.LoadLimit)
		{
			player.ShowHint("Has reached the limit of use");
			return;
		}
	}
	
	local time = Time();
	if(index in ::PointTeleport.NextAllowLoad && ::PointTeleport.NextAllowLoad[index] > time)
	{
		player.ShowHint("You need to wait " + (::PointTeleport.NextAllowLoad[index] - time) +
			" seconds before you can use it", 9);
		return;
	}
	
	if(!(index in ::PointTeleport.PlayerPoint))
	{
		player.ShowHint("You have not saved any position");
		return;
	}
	
	::PointTeleport.NextAllowLoad[index] <- time + ::PointTeleport.ConfigVar.LoadInterval;
	if(index in ::PointTeleport.LoadUsed)
		::PointTeleport.LoadUsed[index] += 1;
	else
		::PointTeleport.LoadUsed[index] <- 1;
	
	if(args != null || text != null)
		::PointTeleport.DoNoFallDamage(index);
	
	player.SetLocation(::PointTeleport.PlayerPoint[index].position + Vector(0, 0, 3));
	player.SetAngles(::PointTeleport.PlayerPoint[index].angles);
	player.SetVelocity(Vector(0, 0, 0));
	player.PlaySoundEx("ui/beep07.wav");
}

function CommandTriggersEx::hd(player, args, text)
{
	if(!::PointTeleport.ConfigVar.Enable)
	{
		player.ShowHint("This command is disabled", 9);
		return;
	}
	
	if(::PointTeleport.ConfigVar.AllowTeam != 1 && ::PointTeleport.ConfigVar.AllowTeam != player.GetTeam())
	{
		player.ShowHint("Your team can not use this command", 9);
		return;
	}
	
	if(player.IsDead() || player.IsGhost())
	{
		player.ShowHint("This command can only be used if it is alive");
		return;
	}
	
	local index = player.GetIndex();
	if(!(index in ::PointTeleport.PlayerPoint) || !(index in ::PointTeleport.HistoryPoint))
	{
		player.ShowHint("There are not enough times to save");
		return;
	}
	
	if(index in ::PointTeleport.BackUsed)
	{
		if(::PointTeleport.ConfigVar.BackLimit > 0 && ::PointTeleport.BackUsed[index] >= ::PointTeleport.ConfigVar.BackLimit)
		{
			player.ShowHint("Has reached the limit of use");
			return;
		}
	}
	
	if(index in ::PointTeleport.BacktrackingUsed)
	{
		if(::PointTeleport.ConfigVar.Backtracking > 0 &&
			::PointTeleport.BacktrackingUsed[index] >= ::PointTeleport.ConfigVar.Backtracking ||
			::PointTeleport.HistoryPoint[index].len() <= 0)
		{
			player.ShowHint("Can not continue backtracking");
			return;
		}
	}
	
	if(!(index in ::PointTeleport.BacktrackingUsed))
		::PointTeleport.BacktrackingUsed[index] <- 1;
	else
		::PointTeleport.BacktrackingUsed[index] += 1;
	
	if(!(index in ::PointTeleport.BackUsed))
		::PointTeleport.BackUsed[index] <- 1;
	else
		::PointTeleport.BackUsed[index] += 1;
	
	::PointTeleport.PlayerPoint[index] <- ::PointTeleport.HistoryPoint[index].pop();
	::PointTeleport.DoNoFallDamage(index);
	player.SetLocation(::PointTeleport.PlayerPoint[index].position + Vector(0, 0, 3));
	player.SetAngles(::PointTeleport.PlayerPoint[index].angles);
	player.SetVelocity(Vector(0, 0, 0));
	player.PlaySoundEx("ui/beep22.wav");
}


::PointTeleport.PLUGIN_NAME <- PLUGIN_NAME;
::PointTeleport.ConfigVar = ::PointTeleport.ConfigVarDef;

function Notifications::OnRoundStart::PointTeleport_LoadConfig()
{
	RestoreTable(::PointTeleport.PLUGIN_NAME, ::PointTeleport.ConfigVar);
	if(::PointTeleport.ConfigVar == null || ::PointTeleport.ConfigVar.len() <= 0)
		::PointTeleport.ConfigVar = FileIO.GetConfigOfFile(::PointTeleport.PLUGIN_NAME, ::PointTeleport.ConfigVarDef);

	// printl("[plugins] " + ::PointTeleport.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::PointTeleport_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::PointTeleport.PLUGIN_NAME, ::PointTeleport.ConfigVar);

	// printl("[plugins] " + ::PointTeleport.PLUGIN_NAME + " saving...");
}
