::ChargeIdleDetect <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
		
		// 伤害
		Damage = 15,
		
		// 延迟
		Delay = 0.1,
	},
	
	ConfigVar = {},
	
	function FakeDamage(attacker, victim, damage, type = 0, weapon = "")
	{
		local health = victim.GetRawHealth();
		local buffer = victim.GetHealthBuffer();
		
		if(health > damage)
		{
			// health -= damage;
			victim.SetRawHealth(health - damage);
		}
		else if(buffer > (damage - health + 1))
		{
			// buffer -= (damage - health + 1);
			victim.SetRawHealth(1);
			victim.SetHealthBuffer(damage - health + 1);
		}
		else if(!victim.IsIncapacitated() && !victim.IsLastStrike())
		{
			victim.SetNetProp("m_isIncapacitated", 1);
			victim.SetRawHealth(Convars.GetFloat("survivor_incap_health"));
			victim.SetHealthBuffer(0);
		}
		else
		{
			// 当前状态免疫所有伤害，Player::Kill 处死无效的
			victim.SetRawHealth(0);
			victim.SetHealthBuffer(0);
			victim.Kill();
		}
		
		FireGameEvent("player_hurt", {
			"userid" : victim.GetUserID(),
			"attacker" : attacker.GetUserID(),
			"dmg_health" : damage,
			"dmg_armor" : 0,
			"hitgroup" : 0,
			"type" : type,
			"health" : victim.GetRawHealth(),
			"armor" : victim.GetNetPropInt("m_ArmorValue"),
			"weapon" : weapon,
		});
	},
	
	function Timer_ApplyDamageWithCharge(params)
	{
		local attacker = params["attacker"];
		local player = params["player"];
		local bot = params["bot"];
		
		if(!attacker.IsPlayerEntityValid())
			return;
		
		if(player.IsSurvivor() && player.IsAlive())
		{
			// player.Damage(::ChargeIdleDetect.ConfigVar.Damage, DMG_BLAST, attacker);
			::ChargeIdleDetect.FakeDamage(attacker, player, ::ChargeIdleDetect.ConfigVar.Damage);
		}
		
		if(bot.IsSurvivor() && bot.IsAlive())
		{
			// bot.Damage(::ChargeIdleDetect.ConfigVar.Damage, DMG_BLAST, attacker);
			::ChargeIdleDetect.FakeDamage(attacker, bot, ::ChargeIdleDetect.ConfigVar.Damage);
		}
	}
};

function Notifications::OnBotReplacedPlayer::ChargeIdleDetect(player, bot, params)
{
	if(!::ChargeIdleDetect.ConfigVar.Enable)
		return;
	
	if(player == null || bot == null || !player.IsSurvivor() || !bot.IsSurvivor())
		return;
	
	local attacker = player.GetCurrentAttacker();
	if(attacker == null || attacker.GetType() != Z_CHARGER)
		attacker = bot.GetCurrentAttacker();
	if(attacker == null || attacker.GetType() != Z_CHARGER)
		return;
	
	Timers.AddTimerByName("timer_chargeidle_" + player.GetIndex(), ::ChargeIdleDetect.ConfigVar.Delay, false,
		::ChargeIdleDetect.Timer_ApplyDamageWithCharge, { "attacker" : attacker, "player" : player, "bot" : bot });
}

function Notifications::OnPlayerReplacedBot::ChargeIdleDetect(player, bot, params)
{
	if(!::ChargeIdleDetect.ConfigVar.Enable)
		return;
	
	if(player == null || bot == null || !player.IsSurvivor() || !bot.IsSurvivor())
		return;
	
	local attacker = player.GetCurrentAttacker();
	if(attacker == null || attacker.GetType() != Z_CHARGER)
		attacker = bot.GetCurrentAttacker();
	if(attacker == null || attacker.GetType() != Z_CHARGER)
		return;
	
	Timers.AddTimerByName("timer_chargeidle_" + player.GetIndex(), ::ChargeIdleDetect.ConfigVar.Delay, false,
		::ChargeIdleDetect.Timer_ApplyDamageWithCharge, { "attacker" : attacker, "player" : player, "bot" : bot });
}

::ChargeIdleDetect.PLUGIN_NAME <- PLUGIN_NAME;
::ChargeIdleDetect.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::ChargeIdleDetect.ConfigVarDef);

function Notifications::OnRoundStart::ChargeIdleDetect_LoadConfig()
{
	RestoreTable(::ChargeIdleDetect.PLUGIN_NAME, ::ChargeIdleDetect.ConfigVar);
	if(::ChargeIdleDetect.ConfigVar == null || ::ChargeIdleDetect.ConfigVar.len() <= 0)
		::ChargeIdleDetect.ConfigVar = FileIO.GetConfigOfFile(::ChargeIdleDetect.PLUGIN_NAME, ::ChargeIdleDetect.ConfigVarDef);

	// printl("[plugins] " + ::ChargeIdleDetect.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::ChargeIdleDetect_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::ChargeIdleDetect.PLUGIN_NAME, ::ChargeIdleDetect.ConfigVar);

	// printl("[plugins] " + ::ChargeIdleDetect.PLUGIN_NAME + " saving...");
}
