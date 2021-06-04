::GnomeHeal <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,

		// 每次治疗多少生命值
		HealAmount = 1,

		// 治疗增加的是什么.1=长期生命值.2=临时生命值.3=护甲.4=动态调整
		HealMode = 2,

		// 捡起后开始治疗的延迟(秒)
		StartDelay = 1,

		// 治疗间隔(秒)
		HealInterval = 0.5,

		// 思考间隔，不能小于治疗间隔
		ThinkInterval = 0.5
	},

	ConfigVar = {},

	function GivePlayerHealth(player, amount)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead() || amount == 0)
			return false;
		
		local armor = player.GetNetPropInt("m_ArmorValue");
		local health = player.GetRawHealth();
		local buffer = player.GetHealthBuffer();
		local maxHealth = player.GetMaxHealth();
		
		switch(::GnomeHeal.ConfigVar.HealMode)
		{
			case 1:
			{
				health += amount;
				break;
			}
			case 2:
			{
				buffer += amount;
				break;
			}
			case 3:
			{
				armor += amount;
				break;
			}
			case 4:
			{
				buffer += amount;
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
		
		// 验证是否超过了上限
		if(health + buffer > maxHealth)
		{
			buffer = maxHealth - health;
			if(buffer < 0.0)
			{
				health = maxHealth;
				buffer = 0;
			}
		}
		
		// signed byte 上限为 127
		if(armor > 127)
			armor = 127;
		
		player.SetRawHealth(health);
		player.SetHealthBuffer(buffer);
		player.SetNetPropInt("m_ArmorValue", armor);
	},
	
	function TimerHeal_OnPlayerThink(params)
	{
		if(!::GnomeHeal.ConfigVar.Enable)
			return;
		
		local time = Time();
		foreach(player in Players.AliveSurvivors())
		{
			local weapon = player.GetActiveWeapon();
			if(weapon == null || !weapon.IsEntityValid())
				continue;
			
			local classname = weapon.GetClassname();
			if(classname != "weapon_cola_bottles" && classname != "weapon_gnome")
				continue;
			
			if(weapon.GetNetPropFloat("m_flTimeWeaponIdle") > time)
				continue;
			
			weapon.SetNetPropFloat("m_flTimeWeaponIdle", time + ::GnomeHeal.ConfigVar.HealInterval);
			::GnomeHeal.GivePlayerHealth(player, ::GnomeHeal.ConfigVar.HealAmount);
		}
	},
	
	function TimerStart_OnPlayerPickup(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.GetTeam() != SURVIVORS || player.IsDead())
			return;
		
		local weapon = player.GetActiveWeapon();
		if(weapon == null || !weapon.IsEntityValid())
			return;
		
		local classname = weapon.GetClassname();
		if(classname != "weapon_cola_bottles" && classname != "weapon_gnome")
			return;
		
		weapon.SetNetPropFloat("m_flTimeWeaponIdle", Time() + ::GnomeHeal.ConfigVar.StartDelay);
	}
};

function Notifications::OnRoundBegin::HealGnomeActtive(params)
{
	Timers.AddTimerByName("timer_healgnome", ::GnomeHeal.ConfigVar.ThinkInterval, true,
		::GnomeHeal.TimerHeal_OnPlayerThink);
}

function Notifications::FirstSurvLeftStartArea::HealGnomeActtive(player, params)
{
	Timers.AddTimerByName("timer_healgnome", ::GnomeHeal.ConfigVar.ThinkInterval, true,
		::GnomeHeal.TimerHeal_OnPlayerThink);
	
	Convars.SetValue("pain_pills_health_threshold", "100");
}

function Notifications::OnItemPickup::HealGnomeStart(player, weapon, params)
{
	if(weapon != "weapon_gnome" && weapon != "weapon_cola_bottles")
		return;
	
	if(player == null || !player.IsPlayerEntityValid() || player.GetTeam() != SURVIVORS || player.IsDead())
		return;
	
	Timers.AddTimerByName("timer_gnomeheal_" + player.GetIndex(), 0.1, false,
		::GnomeHeal.TimerStart_OnPlayerPickup, player);
}


::GnomeHeal.PLUGIN_NAME <- PLUGIN_NAME;
::GnomeHeal.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::GnomeHeal.ConfigVarDef);

function Notifications::OnRoundStart::GnomeHeal_LoadConfig()
{
	RestoreTable(::GnomeHeal.PLUGIN_NAME, ::GnomeHeal.ConfigVar);
	if(::GnomeHeal.ConfigVar == null || ::GnomeHeal.ConfigVar.len() <= 0)
		::GnomeHeal.ConfigVar = FileIO.GetConfigOfFile(::GnomeHeal.PLUGIN_NAME, ::GnomeHeal.ConfigVarDef);

	// printl("[plugins] " + ::GnomeHeal.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::GnomeHeal_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::GnomeHeal.PLUGIN_NAME, ::GnomeHeal.ConfigVar);

	// printl("[plugins] " + ::GnomeHeal.PLUGIN_NAME + " saving...");
}
