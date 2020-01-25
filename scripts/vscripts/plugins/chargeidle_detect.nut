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
	
	function Timer_ApplyDamageWithCharge(params)
	{
		local attacker = params["attacker"];
		local player = params["player"];
		local bot = params["bot"];
		
		if(!attacker.IsPlayerEntityValid())
			return;
		
		if(player.IsSurvivor() && player.IsAlive())
			player.Damage(::ChargeIdleDetect.ConfigVar.Damage, DMG_BLAST, attacker);
		if(bot.IsSurvivor() && bot.IsAlive())
			bot.Damage(::ChargeIdleDetect.ConfigVar.Damage, DMG_BLAST, attacker);
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
::ChargeIdleDetect.ConfigVar = ::ChargeIdleDetect.ConfigVarDef;

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
