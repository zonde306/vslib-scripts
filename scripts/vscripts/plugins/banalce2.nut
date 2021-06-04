::DifficultyBanalce <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = false,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = false,

		// 难度上限[0 ~ 100](超过就禁止刷特感)
		MaxIntensity = 75,

		// 难度下限[0 ~ 100](小于时强制刷特感)
		MinIntensity = 25,

		// 开始难度检查的延迟
		StartDelay = 30.0,
		
		
	},

	ConfigVar = {},
	
	// 难度信息
	PlayerTick = {},
	PlayerIntensity = {},
	PlayerTotalIntensity = {},
	
	// 统计信息
	HaveTank = 0,
	StopTick = 0,
	AdustTick = 0,
	AllTotalTick = 0,
	SurvivorCount = 0,
	CurrentAverage = 0,
	AllTotalIntensity = 0,
	
	function Timer_UpdatePlayerInfo(params)
	{
		
	},
	
	function Timer_BalanceThink(params)
	{
		
	},
	
	function Timer_StartBalanceSystem(params)
	{
		
	},
	
	
}

function Notifications::OnRoundBegin::Balance_RoundStart(params)
{
	if(!::DifficultyBanalce.ConfigVar.Enable)
		return;
	
}

function Notifications::FirstSurvLeftStartArea::Balance_RoundStart(player, params)
{
	if(!::DifficultyBanalce.ConfigVar.Enable)
		return;
	
}

function EasyLogic::OnScriptStart::Balance_UpdateSetting()
{
	if(!::DifficultyBanalce.ConfigVar.Enable)
		return;
	
}

function Notifications::OnSpawn::Balance_UpdatePlayerInfo(player, params)
{
	if(!::DifficultyBanalce.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayerEntityValid())
		return;
	
	
}

function Notifications::OnDeath::Balance_UpdatePlayerInfo(victim, attacker, params)
{
	if(!::DifficultyBanalce.ConfigVar.Enable)
		return;
	
	
}

function Notifications::OnWitchStartled::Balance_WitchAnger(victim, attacker, params)
{
	if(!::DifficultyBanalce.ConfigVar.Enable)
		return;
	
}

function Notifications::OnWitchKilled::Balance_WitchDeath(victim, attacker, params)
{
	if(!::DifficultyBanalce.ConfigVar.Enable)
		return;
	
}

// 因为有未知 bug 会导致特感血量不正确(全部都是100血)，所以必须开启
function Notifications::OnSpawn::Balance_UpdateHealth(player, params)
{
	
}

function EasyLogic::OnTakeDamage::Balance_CommonBlockRevive(dmgTable)
{
	
}

function CommandTriggersEx::balance(player, args, text)
{
	
}

::DifficultyBanalce.PLUGIN_NAME <- PLUGIN_NAME;
::DifficultyBanalce.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::DifficultyBanalce.ConfigVarDef);

function Notifications::OnRoundStart::DifficultyBanalce_LoadConfig()
{
	RestoreTable(::DifficultyBanalce.PLUGIN_NAME, ::DifficultyBanalce.ConfigVar);
	if(::DifficultyBanalce.ConfigVar == null || ::DifficultyBanalce.ConfigVar.len() <= 0)
		::DifficultyBanalce.ConfigVar = FileIO.GetConfigOfFile(::DifficultyBanalce.PLUGIN_NAME, ::DifficultyBanalce.ConfigVarDef);

	// printl("[plugins] " + ::DifficultyBanalce.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::DifficultyBanalce_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::DifficultyBanalce.PLUGIN_NAME, ::DifficultyBanalce.ConfigVar);

	// printl("[plugins] " + ::DifficultyBanalce.PLUGIN_NAME + " saving...");
}
