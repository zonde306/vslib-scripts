::RandomModel <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
	},
	
	ConfigVar = {},
	
	MODELS = [
		[ "models/infected/limbs/exploded_boomette.mdl" ],	// 防止崩溃
		[ "models/infected/smoker.mdl", "models/infected/smoker_l4d1.mdl" ],	// 舌头
		[ "models/infected/boomer.mdl", "models/infected/boomette.mdl", "models/infected/boomer_l4d1.mdl" ],	// 胖子
		[ "models/infected/hunter.mdl", "models/infected/hunter_l4d1.mdl" ],	// 猎人
		[ ],	// 口水
		[ ],	// 猴子
		[ ],	// 牛
		[ "models/infected/witch.mdl", "models/infected/witch_bride.mdl" ],	// 萌妹
		[ "models/infected/hulk.mdl", "models/infected/hulk_dlc3.mdl", "models/infected/hulk_l4d1.mdl" ],	// 克
		[ ],	// 生还
		[ ],
		[ ],	// 新娘
	],
	
	function PrecacheModel()
	{
		foreach(models in ::RandomModel.MODELS)
			foreach(model in models)
				Utils.PrecacheModel(model);
	},
};

// 立即加载模型
::RandomModel.PrecacheModel();

function Notifications::OnSpawn::SetRandomModel(player, params)
{
	if(!::RandomModel.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsValid())
		return;
	
	local type = player.GetType();
	switch(type)
	{
		case Z_SMOKER:
		case Z_BOOMER:
		case Z_HUNTER:
		case Z_TANK:
		{
			player.SetModel(Utils.GetRandValueFromArray(::RandomModel.MODELS[type]));
			break;
		}
	}
}

function Notifications::OnWitchSpawned::SetRandomModel(witch, params)
{
	if(!::RandomModel.ConfigVar.Enable)
		return;
	
	if(witch == null || !witch.IsValid())
		return;
	
	witch.SetModel(Utils.GetRandValueFromArray(::RandomModel.MODELS[Z_WITCH]));
}


::RandomModel.PLUGIN_NAME <- PLUGIN_NAME;
::RandomModel.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::RandomModel.ConfigVarDef);

function Notifications::OnRoundStart::RandomModel_LoadConfig()
{
	RestoreTable(::RandomModel.PLUGIN_NAME, ::RandomModel.ConfigVar);
	if(::RandomModel.ConfigVar == null || ::RandomModel.ConfigVar.len() <= 0)
		::RandomModel.ConfigVar = FileIO.GetConfigOfFile(::RandomModel.PLUGIN_NAME, ::RandomModel.ConfigVarDef);

	// printl("[plugins] " + ::RandomModel.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::RandomModel_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::RandomModel.PLUGIN_NAME, ::RandomModel.ConfigVar);

	// printl("[plugins] " + ::RandomModel.PLUGIN_NAME + " saving...");
}
