::JockeyUnsilent <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
	},
	
	ConfigVar = {},
	
	SOUNDS = [ "player/jockey/voice/idle/jockey_spotprey_01.wav", "player/jockey/voice/idle/jockey_lurk04.wav" ],
	
	function Timer_JockeyUnsilent(player)
	{
		player.PlaySound(Utils.GetRandValueFromArray(::JockeyUnsilent.SOUNDS));
	},
};

function Notifications::OnSpawn::JockeyUnsilent(player, params)
{
	if(!::JockeyUnsilent.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsValid() || player.GetType() != Z_JOCKEY)
		return;
	
	Timers.AddTimerByName("jockeyunsilent_" + player.GetIndex(), 0.1, false, ::JockeyUnsilent.Timer_JockeyUnsilent, player);
}

::JockeyUnsilent.PLUGIN_NAME <- PLUGIN_NAME;
::JockeyUnsilent.ConfigVar = ::JockeyUnsilent.ConfigVarDef;

function Notifications::OnRoundStart::JockeyUnsilent_LoadConfig()
{
	RestoreTable(::JockeyUnsilent.PLUGIN_NAME, ::JockeyUnsilent.ConfigVar);
	if(::JockeyUnsilent.ConfigVar == null || ::JockeyUnsilent.ConfigVar.len() <= 0)
		::JockeyUnsilent.ConfigVar = FileIO.GetConfigOfFile(::JockeyUnsilent.PLUGIN_NAME, ::JockeyUnsilent.ConfigVarDef);

	// printl("[plugins] " + ::JockeyUnsilent.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::JockeyUnsilent_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::JockeyUnsilent.PLUGIN_NAME, ::JockeyUnsilent.ConfigVar);

	// printl("[plugins] " + ::JockeyUnsilent.PLUGIN_NAME + " saving...");
}
