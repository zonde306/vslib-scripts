::Swimming <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = false,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
		
		// 是否允许玩家潜水
		AllowDive = true,
		
		// 被特感抓住是强制下潜
		GrabDrawn = true,
		
		// 潜水时玩家每秒失去多少氧气，当玩家氧气为 0 时会掉血
		DiveLostRate = 0.1,
		
		// 玩家下潜速度
		DiveDownSpeed = -30.0,
		
		// 玩家不动时的上升速度
		DiveIdleSpeed = 15.0,
		
		// 玩家上升速度
		DiveUpSpeed = 400.0,
		
		// 玩家行走速度
		DiveWalkSpeed = 30.0
	},
	
	ConfigVar = {},
	
	HasSwimming = {},
	LastHealth = {},
	LastHealthBuffer = {},
	
	function Timer_OnPlayerThink(params)
	{
		if(!::Swimming.ConfigVar.Enable)
			return;
		
		foreach(player in Players.All())
		{
			if(player.IsDead() || player.IsIncapacitated())
				continue;
			
			local index = player.GetIndex();
			local waterLevel = player.GetNetPropInt("m_nWaterLevel");
			local isSwimming = (index in ::Swimming.HasSwimming ? ::Swimming.HasSwimming[index] : false);
			
			if(waterLevel >= 1)
			{
				if(waterLevel == 1)
				{
					if(isSwimming && ::Swimming.ConfigVar.DiveLostRate > 0 &&
						index in ::Swimming.LastHealth && index in ::Swimming.LastHealthBuffer)
					{
						player.SetRawHealth(::Swimming.LastHealth[index]);
						player.SetHealthBuffer(::Swimming.LastHealthBuffer[index]);
						delete ::Swimming.LastHealth[index];
						delete ::Swimming.LastHealthBuffer[index];
					}
				}
				else
				{
					if(!isSwimming)
					{
						// 开始游泳
						::Swimming.HasSwimming[index] <- true;
					}
					
					local velocity = player.GetVelocity();
					local button = player.GetPressedButtons();
					
					if((::Swimming.ConfigVar.AllowDive && (button & BUTTON_DUCK)) ||
						(::Swimming.ConfigVar.GrabDrawn && player.GetCurrentAttacker() != null))
					{
						// 潜水
						velocity.z = ::Swimming.ConfigVar.DiveDownSpeed;
					}
					else if(button & BUTTON_JUMP)
					{
						// 上浮
						if(waterLevel == 2)
						{
							player.Input("DisableLedgeHang");
							velocity.z = ::Swimming.ConfigVar.DiveUpSpeed;
						}
						else
						{
							velocity.z = ::Swimming.ConfigVar.DiveWalkSpeed;
						}
					}
					else
					{
						velocity.z = ::Swimming.ConfigVar.DiveIdleSpeed;
					}
					
					player.SetVelocity(velocity);
					
					if(::Swimming.ConfigVar.DiveLostRate > 0 && waterLevel > 2)
					{
						if(!(index in ::Swimming.LastHealth) || !(index in ::Swimming.LastHealthBuffer))
						{
							::Swimming.LastHealth[index] <- player.GetRawHealth();
							::Swimming.LastHealthBuffer[index] <- player.GetHealthBuffer();
							
							player.SetRawHealth(1);
							player.SetHealthBuffer(100);
						}
						
						local health = player.GetHealthBuffer() - ::Swimming.ConfigVar.DiveLostRate;
						if(health <= 0)
							player.Kill();
						else
							player.SetHealthBuffer(health);
					}
				}
			}
			else if(isSwimming)
			{
				delete ::Swimming.HasSwimming[index];
				player.Input("EnableLedgeHang");
			}
		}
	}
};

function Notifications::OnRoundBegin::Swimming_ActiveThink(params)
{
	Timers.AddTimerByName("timer_swimming", 0.1, true, ::Swimming.Timer_OnPlayerThink);
}

function Notifications::FirstSurvLeftStartArea::Swimming_ActiveThink(player, params)
{
	Timers.AddTimerByName("timer_swimming", 0.1, true, ::Swimming.Timer_OnPlayerThink);
}

function EasyLogic::OnTakeDamage::Swimming_SwimmingDamage(dmgTable)
{
	if(!::Swimming.ConfigVar.Enable)
		return true;
	
	if(dmgTable["Victim"] == null || dmgTable["DamageDone"] <= 0.0 ||
		!dmgTable["Victim"].IsSurvivor() /*|| !(dmgTable["DamageType"] & DMG_DROWN)*/)
		return true;
	
	if(dmgTable["Victim"].GetCurrentAttacker() != null)
		return true;
	
	local index = dmgTable["Victim"].GetIndex();
	if(index in ::Swimming.HasSwimming)
		return ::Swimming.HasSwimming[index];
	
	return true;
}

function CommandTriggersEx::sw(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	::Swimming.ConfigVar.Enable = !::Swimming.ConfigVar.Enable;
	
	printl("swimming setting " + ::Swimming.ConfigVar.Enable);
}

::Swimming.PLUGIN_NAME <- PLUGIN_NAME;
::Swimming.ConfigVar = ::Swimming.ConfigVarDef;

function Notifications::OnRoundStart::ObjectSpawner_LoadConfig()
{
	RestoreTable(::Swimming.PLUGIN_NAME, ::Swimming.ConfigVar);
	if(::Swimming.ConfigVar == null || ::Swimming.ConfigVar.len() <= 0)
		::Swimming.ConfigVar = FileIO.GetConfigOfFile(::Swimming.PLUGIN_NAME, ::Swimming.ConfigVarDef);

	// printl("[plugins] " + ::Swimming.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::ObjectSpawner_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::Swimming.PLUGIN_NAME, ::Swimming.ConfigVar);

	// printl("[plugins] " + ::Swimming.PLUGIN_NAME + " saving...");
}
