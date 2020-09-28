::HelpBouns <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,

		// 给队友打包奖励多少(根据治疗量决定)
		Heal = 10,

		// 给队友递药奖励多少
		GivePills = 4,

		// 给队友递针奖励多少
		GiveAdren = 3,

		// 保护队友奖励多少
		Protect = 1,

		// 使用电击器复活队友励多少
		Defib = 5,

		// 救起倒地队友奖励多少
		Incap = 2,

		// 救起挂边队友奖励多少
		Ledge = 1,

		// 救出被控的队友奖励多少
		Special = 3,

		// 打开复活房门救出队友每一个奖励多少
		Resuce = 1,

		// 爆头击杀特感奖励多少
		Headshot = 2,

		// 奖励的方式.0=长期血量.1=临时血量.3=护甲(上限127).4=根据情况动态调整(默认临时，临时满了长期，还不行就护甲)
		BonusMode = 3,

		// 是否禁止救人打包
		AntiReviveHeal = true,

		// 允许打包的最小血量百分比(血量大于这个禁止给自己打包).0=禁用
		HealSelfLimit = 0
	},

	ConfigVar = {},

	DelayBouns = {},
	IsHealing = {},
	IsReviveing = {},
	
	function Timer_GivePlayerHealth(params)
	{
		local player = params["target"];
		local amount = params["count"];
		
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead())
			return;
		
		local index = player.GetIndex();
		if(player.IsIncapacitated() || player.IsHangingFromLedge())
		{
			if(amount == 0)
				return;
			
			// 在倒地时忽略奖励
			// 只保留最后一次获得的奖励
			::HelpBouns.DelayBouns[index] <- amount;
			return;
		}
		
		local moreAmount = amount;
		if(index in ::HelpBouns.DelayBouns)
		{
			// 检查数据有效性
			if(typeof(::HelpBouns.DelayBouns) == "integer" || typeof(::HelpBouns.DelayBouns) == "float" &&
				::HelpBouns.DelayBouns[index] > 0)
			{
				// 从上一次多余的部分获取
				moreAmount += ::HelpBouns.DelayBouns[index];
			}
			
			delete ::HelpBouns.DelayBouns[index];
		}
		
		if(moreAmount == 0)
			return;
		
		local armor = player.GetNetPropInt("m_ArmorValue");
		local health = player.GetRawHealth();
		local buffer = player.GetHealthBuffer();
		local maxHealth = player.GetMaxHealth();
		
		switch(::HelpBouns.ConfigVar.BonusMode)
		{
			case 1:
			{
				health += moreAmount;
				break;
			}
			case 2:
			{
				buffer += moreAmount;
				break;
			}
			case 3:
			{
				armor += moreAmount;
				break;
			}
			case 4:
			{
				buffer += moreAmount;
				if(buffer + health > maxHealth)
				{
					// 多余的部分
					local moreValue = buffer + health - maxHealth;
					
					// 将多余的部分视为转换
					health += moreValue;
					
					// 将多余的部分以及转换的部分去掉
					buffer -= moreValue * 2;
					
					// 清空多余的部分，防止被无意使用
					moreValue = 0;
					
					// 多余(转换)部分太大了，当前上限无法完全利用
					if(buffer < 0.0)
					{
						// 获取转换后超出的部分
						moreValue = -buffer;
						
						// 将超出的部分去除
						health += buffer;
						
						// 转换后临时必须为 0
						buffer = 0.0;
					}
					
					// 实在用不完就扔给护甲
					if(moreValue > 0)
						armor += moreValue;
				}
				break;
			}
		}
		
		moreAmount = 0;
		
		// 验证是否超过了上限
		if(health + buffer > maxHealth)
		{
			moreAmount += health + buffer - maxHealth;
			buffer = maxHealth - health;
			
			if(buffer < 0.0)
			{
				health = maxHealth;
				buffer = 0;
			}
		}
		
		// signed byte 上限为 127
		if(armor > 127)
		{
			moreAmount += armor - 127;
			armor = 127;
		}
		
		if(moreAmount > 0)
		{
			// 将多出来的部分分配到下一次
			::HelpBouns.DelayBouns[index] <- moreAmount;
		}
		
		player.SetRawHealth(health);
		player.SetHealthBuffer(buffer);
		player.SetNetPropInt("m_ArmorValue", armor);
		printl("player " + player.GetName() + " gain bonus " + amount);
	},
	
	function GivePlayerHealth(player, amount = 0)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead())
			return;
		
		Timers.AddTimerOne("timer_give_health_" + player.GetIndex(), 0.1,
			::HelpBouns.Timer_GivePlayerHealth, {target = player, count = amount});
	},
	
	function TimerButton_OnReviveStart(player)
	{
		if(player == null || !player.IsPlayerEntityValid())
			return;
		
		player.EnableButton(BUTTON_ATTACK);
	},
	
	function SetProgressBarTime(player, time = 0.0)
	{
		if(player == null || !player.IsPlayerEntityValid())
			return;
		
		player.SetNetPropFloat("m_flProgressBarStartTime", Time());
		player.SetNetPropFloat("m_flProgressBarDuration", time);
	},
	
	function IsNeedHelp(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead() || !player.IsSurvivor())
			return false;
		
		if(player.IsIncapacitated() || player.IsHangingFromLedge() || player.IsHangingFromTongue() ||
			player.IsBeingJockeyed() || player.IsPounceVictim() || player.IsTongueVictim() ||
			player.IsCarryVictim() || player.IsPummelVictim())
			return true;
		
		return false;
	},
	
	function Timer_AntiHealSelf(params)
	{
		if(::HelpBouns.ConfigVar.HealSelfLimit <= 0)
			return;
		
		foreach(player in Players.AliveSurvivors())
		{
			if(::HelpBouns.IsNeedHelp(player))
				continue;
			
			local weapon = player.GetActiveWeapon();
			if(weapon != null && weapon.GetClassname() == "weapon_first_aid_kit" &&
				(player.GetRawHealth() / player.GetMaxHealth() * 100) > ::HelpBouns.ConfigVar.HealSelfLimit)
			{
				// 阻止玩家使用鼠标左键来给自己打包
				weapon.SetNetPropFloat("m_flNextPrimaryAttack", Time() + 1.0);
				player.SetNetPropFloat("m_flNextAttack", Time() + 1.0);
			}
		}
	},
	
	function Timer_UpdateMaxAllowHealAmount(params)
	{
		local maxHealth = 100;
		local heightMaxHealth = 100;
		foreach(player in Players.AliveSurvivors())
		{
			maxHealth = player.GetMaxHealth();
			if(maxHealth > heightMaxHealth)
				heightMaxHealth = maxHealth;
		}
		
		if(heightMaxHealth > 1268)
			heightMaxHealth = 1268;
		
		heightMaxHealth = heightMaxHealth.tostring();
		Convars.SetValue("first_aid_kit_max_heal", heightMaxHealth);
		Convars.SetValue("pain_pills_health_threshold", heightMaxHealth);
	},
	
	function OnHealSuccess(player, amount)
	{
		if(player == null || !player.IsPlayerEntityValid() || !player.IsSurvivor())
			return;
		
		local healPercent = Convars.GetFloat("first_aid_heal_percent");
		
		local maxHealth = player.GetMaxHealth();
		
		if(amount > maxHealth || amount < 1)
			amount = floor(maxHealth * healPercent);
		
		local curHealth = player.GetRawHealth();
		// local lossHealth = maxHealth - curHealth + amount;
		local lossHealth = floor(amount / healPercent);
		local beforeHealth = maxHealth - lossHealth;
		
		if((lossHealth / maxHealth) <= (1.0 - healPercent))
			player.SetRawHealth(maxHealth);
		else
			player.SetRawHealth(beforeHealth + floor(lossHealth * healPercent));
		
		/*
		if(beforeHealth < 10)
			player.SetRawHealth(maxHealth * healPercent);
		else if(lossHealth > 10)
			player.SetRawHealth(lossHealth * healPercent + beforeHealth);
		else
			player.SetRawHealth(maxHealth);
		*/
		
		/*
		player.ShowHint("health: " + curHealth + ", beforeHealth: " + beforeHealth +
			", lossHealth: " + lossHealth + ", healAmount: " + amount);
		*/
	},
	
	function OnRespawnSuccess(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || !player.IsSurvivor())
			return;
		
		local healthPercent = Convars.GetFloat("z_survivor_respawn_health") / 100;
		player.SetRawHealth(player.GetMaxHealth() * healthPercent);
	},
	
	function OnHealthBufferChanged(player, amount)
	{
		if(player == null || !player.IsPlayerEntityValid() || !player.IsSurvivor() || player.IsDead())
			return;
		
		local health = player.GetRawHealth();
		local maxHealth = player.GetMaxHealth();
		local buffer = player.GetHealthBuffer();
		
		// player.ShowHint("health: " + health + ", buffer: " + buffer + ", maxHealth: " + maxHealth + ", amount: " + amount);
		
		buffer -= amount;
		buffer += maxHealth * amount / 100.0;
		if(buffer + health > maxHealth)
			buffer = maxHealth - health;
		if(buffer < 0)
			buffer = 0;
		
		// player.ShowHint("new buffer: " + buffer);
		player.SetHealthBuffer(buffer);
	},
	
	function OnPillsUsed(player)
	{
		return ::HelpBouns.OnHealthBufferChanged(player, Convars.GetFloat("pain_pills_health_value"));
	},
	
	function OnAdrenalineUsed(player)
	{
		return ::HelpBouns.OnHealthBufferChanged(player, Convars.GetFloat("adrenaline_health_buffer"));
	},
	
	function OnReviveSuccess(player, hasLedge)
	{
		if(player == null || !player.IsPlayerEntityValid() || !player.IsSurvivor() || player.IsDead())
			return;
		
		local amount = Convars.GetFloat("survivor_revive_health");
		
		if(hasLedge)
		{
			if(player.GetRawHealth() > 1 || player.GetHealthBuffer() > amount)
				return;
		}
		
		return ::HelpBouns.OnHealthBufferChanged(player, amount);
	}
};

function Notifications::OnRoundBegin::HealBlock_Active(params)
{
	Timers.AddTimerByName("timer_block_heal_self", 0.1, true, ::HelpBouns.Timer_AntiHealSelf);
}

function Notifications::FirstSurvLeftStartArea::HealBlock_Active(player, params)
{
	Timers.AddTimerByName("timer_block_heal_self", 0.1, true, ::HelpBouns.Timer_AntiHealSelf);
}

function Notifications::OnPlayerReplacedBot::HelpBouns_UpdateHeightMaxHealth(player, bot, params)
{
	Timers.AddTimerOne("timer_update_max_health",
		Convars.GetFloat("first_aid_kit_use_duration"),
		::HelpBouns.Timer_UpdateMaxAllowHealAmount);
}

function Notifications::OnTeamChanged::HelpBouns_UpdateHeightMaxHealth(player, oldTeam, newTeam, params)
{
	Timers.AddTimerOne("timer_update_max_health",
		Convars.GetFloat("first_aid_kit_use_duration"),
		::HelpBouns.Timer_UpdateMaxAllowHealAmount);
}

function Notifications::OnHealSuccess::HelpBouns(subject, player, amount, params)
{
	if(!::HelpBouns.ConfigVar.Enable)
		return;
	
	if(subject == null || player == null || !subject.IsPlayerEntityValid() || !player.IsPlayerEntityValid())
		return;
	
	subject.SetRenderMode(RENDER_NORMAL);
	subject.SetRenderEffects(RENDERFX_NONE);
	subject.SetColor(255, 255, 255, 255);
	
	if(subject.GetSurvivorCharacter() == player.GetSurvivorCharacter())
	{
		::HelpBouns.OnHealSuccess(subject, params["health_restored"]);
		::HelpBouns.GivePlayerHealth(subject);
		return;
	}
	
	if(::HelpBouns.ConfigVar.Heal > 0)
	{
		::HelpBouns.GivePlayerHealth(player, ceil((params["health_restored"] / subject.GetMaxHealth() * 0.8) * ::HelpBouns.ConfigVar.Heal));
		// player.PlaySoundEx("ui/bigreward.wav");
	}
	
	subject.SetRawHealth(subject.GetMaxHealth());
	printl("player " + player.GetName() + " heal " + subject.GetName());
}

function Notifications::OnIncapacitated::HelpBouns_ClearDying(victim, attacker, params)
{
	if(victim == null || !victim.IsPlayerEntityValid())
		return;
	
	victim.SetRenderMode(RENDER_NORMAL);
	victim.SetRenderEffects(RENDERFX_NONE);
	victim.SetColor(255, 255, 255, 255);
}

function Notifications::OnDeath::HelpBouns_RemoveDyingInfo(victim, attacker, params)
{
	try
	{
		if(params["headshot"] && attacker != null && victim != null && attacker.IsPlayer() && victim.IsPlayer() &&
			attacker.GetTeam() == SURVIVORS && victim.GetTeam() == INFECTED)
			::HelpBouns.GivePlayerHealth(attacker, ::HelpBouns.ConfigVar.Headshot);
	}
	catch(err)
	{
		printl("HelpBouns_RemoveDyingInfo error " + err);
		return;
	}
	
	if(victim != null && victim.IsSurvivor())
	{
		victim.SetRenderMode(RENDER_NORMAL);
		victim.SetRenderEffects(RENDERFX_NONE);
		victim.SetColor(255, 255, 255, 255);
	}
}

function Notifications::OnDefibSuccess::HelpBouns(subject, player, params)
{
	if(!::HelpBouns.ConfigVar.Enable)
		return;
	
	if(subject == null || player == null || !subject.IsPlayerEntityValid() || !player.IsPlayerEntityValid())
		return;
	
	if(subject.GetSurvivorCharacter() == player.GetSurvivorCharacter())
	{
		::HelpBouns.OnRespawnSuccess(subject);
		::HelpBouns.GivePlayerHealth(subject);
		return;
	}
	
	if(::HelpBouns.ConfigVar.Defib > 0)
	{
		::HelpBouns.GivePlayerHealth(player, ::HelpBouns.ConfigVar.Defib);
		// player.PlaySoundEx("ui/bigreward.wav");
	}
	
	subject.SetRawHealth(subject.GetMaxHealth());
	printl("player " + player.GetName() + " defib " + subject.GetName());
}

function Notifications::OnSurvivorRescued::HelpBouns_OnRescued(player, subject, params)
{
	if(!::HelpBouns.ConfigVar.Enable)
		return;
	
	if(subject == null || player == null || !subject.IsPlayerEntityValid() || !player.IsPlayerEntityValid())
		return;
	
	if(subject.GetSurvivorCharacter() != player.GetSurvivorCharacter())
		::HelpBouns.OnRespawnSuccess(subject);
}

function Notifications::OnReviveSuccess::HelpBouns(subject, player, params)
{
	if(!::HelpBouns.ConfigVar.Enable)
		return;
	
	if(subject == null || player == null || !subject.IsPlayerEntityValid() || !player.IsPlayerEntityValid())
		return;
	
	if(subject.GetSurvivorCharacter() != player.GetSurvivorCharacter())
	{
		if(params["ledge_hang"])
		{
			if(::HelpBouns.ConfigVar.Ledge > 0)
				::HelpBouns.GivePlayerHealth(player, ::HelpBouns.ConfigVar.Ledge);
		}
		else
		{
			if(::HelpBouns.ConfigVar.Incap > 0)
				::HelpBouns.GivePlayerHealth(player, ::HelpBouns.ConfigVar.Incap);
		}
		
		// player.PlaySoundEx("ui/littlereward.wav");
	}
	
	if(params["lastlife"])
	{
		subject.SetRenderMode(RENDER_TRANSCOLOR);
		subject.SetRenderEffects(RENDERFX_PULSE_SLOW);
		subject.SetColor(255, 255, 255, 192);
	}
	
	::HelpBouns.GivePlayerHealth(subject);
	printl("player " + player.GetName() + " revive " + subject.GetName());
}

function Notifications::OnAwarded::HelpBouns(player, subject, award, params)
{
	if(subject == null || player == null || !subject.IsPlayerEntityValid() || !player.IsPlayerEntityValid())
		return;
	
	if(award == 67)
	{
		if(::HelpBouns.ConfigVar.Protect > 0)
			::HelpBouns.GivePlayerHealth(player, ::HelpBouns.ConfigVar.Incap);
		
		// player.PlaySoundEx("ui/littlereward.wav");
		printl("player " + player.GetName() + " protect " + subject.GetName());
	}
	else if(award == 68)
	{
		if(::HelpBouns.ConfigVar.GivePills > 0)
			::HelpBouns.GivePlayerHealth(player, ::HelpBouns.ConfigVar.GivePills);
		
		// player.PlaySoundEx("ui/littlereward.wav");
		printl("player " + player.GetName() + " give pills " + subject.GetName());
	}
	else if(award == 69)
	{
		if(::HelpBouns.ConfigVar.GiveAdren > 0)
			::HelpBouns.GivePlayerHealth(player, ::HelpBouns.ConfigVar.GiveAdren);
		
		// player.PlaySoundEx("ui/littlereward.wav");
		printl("player " + player.GetName() + " give adrenaline " + subject.GetName());
	}
	else if(award == 75)
	{
		if(::HelpBouns.ConfigVar.Ledge > 0)
			::HelpBouns.GivePlayerHealth(player, ::HelpBouns.ConfigVar.Ledge);
		
		// player.PlaySoundEx("ui/littlereward.wav");
		printl("player " + player.GetName() + " revive " + subject.GetName() + " from ledge");
	}
	else if(award == 76)
	{
		if(::HelpBouns.ConfigVar.Special > 0)
			::HelpBouns.GivePlayerHealth(player, ::HelpBouns.ConfigVar.Special);
		
		// player.PlaySoundEx("ui/beep22.wav");
		printl("player " + player.GetName() + " rescue " + subject.GetName() + " from special");
	}
	else if(award == 80)
	{
		if(::HelpBouns.ConfigVar.Resuce > 0)
			::HelpBouns.GivePlayerHealth(player, ::HelpBouns.ConfigVar.Resuce);
		
		// player.PlaySoundEx("ui/beep22.wav");
		printl("player " + player.GetName() + " rescue " + subject.GetName() + " from room");
	}
}

function Notifications::OnPillsUsed::HelpBouns(player, params)
{
	if(player == null || !player.IsPlayerEntityValid())
		return;
	
	if(Convars.GetStr("mp_gamemode") == "mutation3")
	{
		player.SetRenderMode(RENDER_NORMAL);
		player.SetRenderEffects(RENDERFX_NONE);
		player.SetColor(255, 255, 255, 255);
	}
	
	::HelpBouns.OnPillsUsed(player);
	::HelpBouns.GivePlayerHealth(player);
}

function Notifications::OnAdrenalineUsed::HelpBouns(player, params)
{
	if(player == null || !player.IsPlayerEntityValid())
		return;
	
	::HelpBouns.OnAdrenalineUsed(player);
	::HelpBouns.GivePlayerHealth(player);
}

function Notifications::OnReviveBegin::HelpBouns_ReviveHeal(subject, player, params)
{
	if(!::HelpBouns.ConfigVar.AntiReviveHeal)
		return;
	
	if(player == null || subject == null || !player.IsSurvivor() || !subject.IsSurvivor())
		return;
	
	if(!("IsPlayerEntityValid" in player))
		player = ::VSLib.Player(player);
	if(!("IsPlayerEntityValid" in subject))
		subject = ::VSLib.Player(subject);
	
	if(!player.IsPlayer() || !subject.IsPlayer() || subject.GetSurvivorCharacter() == player.GetSurvivorCharacter())
		return;
	
	local weapon = player.GetActiveWeapon();
	if(weapon == null || !weapon.IsEntityValid() || weapon.GetClassname() != "weapon_first_aid_kit")
		return;
	
	// player.ClientCommand("lastinv");
	player.DisableButton(BUTTON_ATTACK);
	::HelpBouns.IsReviveing[player.GetIndex()] <- true;
	
	::HelpBouns.SetProgressBarTime(player, Convars.GetFloat("survivor_revive_duration") *
		(player.GetNetPropBool("m_bAdrenalineActive") ? Convars.GetFloat("adrenaline_revive_speedup") : 1.0));
}

function Notifications::OnReviveEnd::HelpBouns_ReviveHeal(subject, player, params)
{
	if(player == null || !player.IsSurvivor())
		return;
	
	local index = player.GetIndex();
	if(!(index in ::HelpBouns.IsReviveing))
		return;
	
	player.EnableButton(BUTTON_ATTACK);
	delete ::HelpBouns.IsReviveing[index];
}

function Notifications::OnReviveSuccess::HelpBouns_ReviveHeal(subject, player, params)
{
	Notifications.OnReviveEnd.HelpBouns_ReviveHeal(subject, player, params);
	
	if(player == null || !player.IsSurvivor() || subject == null || !subject.IsSurvivor())
		return;
	
	::HelpBouns.OnReviveSuccess(subject, params["ledge_hang"]);
}

function Notifications::OnHealStart::HelpBouns_HealSelf(subject, player, params)
{
	if(::HelpBouns.ConfigVar.HealSelfLimit <= 0)
		return;
	
	if(player == null || subject == null || !player.IsSurvivor() || !subject.IsSurvivor())
		return;
	
	if(!("IsPlayerEntityValid" in player))
		player = ::VSLib.Player(player);
	if(!("IsPlayerEntityValid" in subject))
		subject = ::VSLib.Player(subject);
	
	if(!player.IsPlayer() || !subject.IsPlayer() || subject.IsBot() ||
		subject.GetSurvivorCharacter() != player.GetSurvivorCharacter())
		return;
	
	local weapon = player.GetActiveWeapon();
	if(weapon == null || !weapon.IsEntityValid() || weapon.GetClassname() != "weapon_first_aid_kit")
		return;
	
	if(player.GetRawHealth() <= ::HelpBouns.ConfigVar.HealSelfLimit)
		return;
	
	// subject.ClientCommand("lastinv");
	player.DisableButton(BUTTON_ATTACK);
	::HelpBouns.IsHealing[player.GetIndex()] <- true;
	
	::HelpBouns.SetProgressBarTime(player, Convars.GetFloat("first_aid_kit_use_duration") *
		(player.GetNetPropBool("m_bAdrenalineActive") ? Convars.GetFloat("adrenaline_backpack_speedup") : 1.0));
}

function Notifications::OnHealEnd::HelpBouns_HealSelf(subject, player, params)
{
	if(player == null || !player.IsSurvivor())
		return;
	
	local index = player.GetIndex();
	if(!(index in ::HelpBouns.IsHealing))
		return;
	
	if(!(index in ::HelpBouns.IsReviveing))
		player.EnableButton(BUTTON_ATTACK);
	
	delete ::HelpBouns.IsHealing[index];
}

function Notifications::OnHealInterrupted::HelpBouns_HealSelf(subject, player, params)
{
	Notifications.OnHealEnd.HelpBouns_HealSelf(subject, player, params);
}

function Notifications::OnHealSuccess::HelpBouns_HealSelf(subject, player, healAmount, params)
{
	Notifications.OnHealEnd.HelpBouns_HealSelf(subject, player, params);
}

function CommandTriggersEx::bonus(player, arg, fullText)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	local strTarget = GetArgument(1);
	local amount = GetArgument(2);
	local target = Utils.GetPlayerFromName(strTarget);
	
	if(strTarget == null || strTarget == "")
	{
		Utils.PrintTable(::HelpBouns.DelayBouns);
		return;
	}
	
	if(strTarget)
	{
		strTarget = strTarget.tolower();
		if(amount != null && amount != "")
		{
			if(strTarget == "all" || strTarget == "survivor")
			{
				foreach(client in Players.AliveSurvivors())
					::HelpBouns.GivePlayerHealth(client, amount.tointeger());
			}
			else if(strTarget == "bots")
			{
				foreach(client in Players.AliveSurvivorBots())
					::HelpBouns.GivePlayerHealth(client, amount.tointeger());
			}
			else if(strTarget == "human")
			{
				foreach(client in Players.AliveSurvivors())
				{
					if(!client.IsBot())
						::HelpBouns.GivePlayerHealth(client, amount.tointeger());
				}
			}
			else
			{
				if(!target)
					return;
				
				::HelpBouns.GivePlayerHealth(target, amount.tointeger());
			}
		}
		else
			::HelpBouns.GivePlayerHealth(player, strTarget.tointeger());
	}
	else
	{
		::HelpBouns.GivePlayerHealth(player);
		printl("health = " + player.GetHealth() + ", armor = " + player.GetNetPropInt("m_ArmorValue"));
	}
}


::HelpBouns.PLUGIN_NAME <- PLUGIN_NAME;
::HelpBouns.ConfigVar = ::HelpBouns.ConfigVarDef;

function Notifications::OnRoundStart::HelpBouns_LoadConfig()
{
	RestoreTable(::HelpBouns.PLUGIN_NAME, ::HelpBouns.ConfigVar);
	if(::HelpBouns.ConfigVar == null || ::HelpBouns.ConfigVar.len() <= 0)
		::HelpBouns.ConfigVar = FileIO.GetConfigOfFile(::HelpBouns.PLUGIN_NAME, ::HelpBouns.ConfigVarDef);

	// printl("[plugins] " + ::HelpBouns.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::HelpBouns_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::HelpBouns.PLUGIN_NAME, ::HelpBouns.ConfigVar);

	// printl("[plugins] " + ::HelpBouns.PLUGIN_NAME + " saving...");
}
