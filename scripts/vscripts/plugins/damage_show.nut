::ShowDamageHud <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,

		// 是否显示伤害值
		true
		// 是否显示血量
		ShowHealth = true,

		// 显示血量是否使用百分比
		HealthByPercentage = true,

		// 是否显示 Tank 血量
		ShowTankHealth = true
	},

	ConfigVar = {},

	TopHudPlane <- {}
};

function Notifications::OnHurt::ShowDamage_PlayerHurt(victim, attacker, params)
{
	if(!::ShowDamageHud.ConfigVar.Enable)
		return;
	
	if(victim == null || attacker == null || !victim.IsPlayer() || !attacker.IsPlayer())
		return;
	
	local text = "";
	if(::ShowDamageHud.ConfigVar.ShowDamage)
	{
		// 显示伤害
		text += "－" + params["dmg_health"];
	}
	
	if(::ShowDamageHud.ConfigVar.ShowHealth)
	{
		if(text != "")
			text += " ";
		
		// 显示血量
		if(::ShowDamageHud.ConfigVar.HealthByPercentage)
		{
			// 百分比
			text += "(" + (params["health"] / victim.GetMaxHealth() * 100) + "％)";
		}
		else
		{
			// 直接显示
			text += "(" + params["health"] + "/" + victim.GetMaxHealth() + ")";
		}
	}
	
	if(text != "")
	{
		// 在 DebugOverlay 层绘制文本
		g_ModeScript.DebugDrawText(victim.GetEyePosition() + ::ShowDamageHud.ConfigVar.ShowOffset, text, true, 1);
	}
	
}

function Notifications::OnTankSpawned::ShowDamage_SetupHealthBar(player, params)
{
	if(!::ShowDamageHud.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayer())
		return;
	
	if(::ShowDamageHud.ConfigVar.ShowTankHealth)
	{
		::ShowDamageHud.TopHudPlane[player.GetIndex()] <-
		{
			slot = HUD_MID_BOX,
			flags = HUD_FLAG_ALIGN_CENTER,
			name = "tank_health",
			staticstring = player.GetName() + ": ",
			datafunc = @() (::ShowDamageHud.ConfigVar.HealthByPercentage ? (player.GetHealth() / player.GetMaxHealth() * 100) + "％" : player.GetHealth() + "/" + player.GetMaxHealth())
		};
		
		g_ModeScript.HUDSetLayout(::ShowDamageHud.TopHudPlane);
	}
}

function Notifications::OnTankKilled::ShowDamage_RemoveHealthBar(victim, attacker, params)
{
	if(victim == null || !victim.IsPlayer())
		return;
	
	if(player.GetIndex() in ::ShowDamageHud.TopHudPlane)
	{
		delete ::ShowDamageHud.TopHudPlane[player.GetIndex()];
		g_ModeScript.HUDSetLayout(::ShowDamageHud.TopHudPlane);
	}
}

function Notifications::OnInfectedHurt::ShowDamage_InfectedHurt(victim, attacker, params)
{
	if(!::ShowDamageHud.ConfigVar.Enable)
		return;
	
	local text = "";
	if(::ShowDamageHud.ConfigVar.ShowDamage)
	{
		// 显示伤害
		text += "－" + params["amount"];
	}
	
	if(::ShowDamageHud.ConfigVar.ShowHealth)
	{
		if(text != "")
			text += " ";
		
		// 显示血量
		if(::ShowDamageHud.ConfigVar.HealthByPercentage)
		{
			// 百分比
			text += "(" + (victim.GetHealth() / victim.GetMaxHealth() * 100) + "％)";
		}
		else
		{
			// 直接显示
			text += "(" + victim.GetHealth() + "/" + victim.GetMaxHealth() + ")";
		}
	}
	
	if(text != "")
	{
		// 在 DebugOverlay 层绘制文本
		g_ModeScript.DebugDrawText(victim.GetEyePosition() + ::ShowDamageHud.ConfigVar.ShowOffset, text, true, 1);
	}
}


::ShowDamageHud.PLUGIN_NAME <- PLUGIN_NAME;
::ShowDamageHud.ConfigVar = ::ShowDamageHud.ConfigVarDef;

function Notifications::OnRoundStart::ShowDamageHud_LoadConfig()
{
	RestoreTable(::ShowDamageHud.PLUGIN_NAME, ::ShowDamageHud.ConfigVar);
	if(::ShowDamageHud.ConfigVar == null || ::ShowDamageHud.ConfigVar.len() <= 0)
		::ShowDamageHud.ConfigVar = FileIO.GetConfigOfFile(::ShowDamageHud.PLUGIN_NAME, ::ShowDamageHud.ConfigVarDef);

	// printl("[plugins] " + ::ShowDamageHud.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::ShowDamageHud_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::ShowDamageHud.PLUGIN_NAME, ::ShowDamageHud.ConfigVar);

	// printl("[plugins] " + ::ShowDamageHud.PLUGIN_NAME + " saving...");
}
