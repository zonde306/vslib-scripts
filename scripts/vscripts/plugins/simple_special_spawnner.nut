::SimpleSpecialSpawnner <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = false,
		
		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = false,
		
		// 出门刷特延迟
		FirstSpawnDelay = 16,
		
		// 刷特间隔
		SpawnInterval = 9,
		
		// 特感上限
		MaxSpawnCount = 4,
		
		// 刷特数量
		SpawnCount = 1,
		
		// 刷特几率
		SmokerChance = 50,
		BoomerChance = 200,
		HunterChance = 150,
		SpitterChance = 175,
		JockeyChance = 125,
		ChargerChance = 75,
		
		// 刷特上限
		SmokerLimit = 1,
		BoomerLimit = 1,
		HunterLimit = 1,
		SpitterLimit = 1,
		JockeyLimit = 1,
		ChargerLimit = 1,
	},
	
	ConfigVar = {},
	
	QueuedToSpawn = 0,
	
	UncapValueList = {
		cm_DominatorLimit = null,
		cm_MaxSpecials = null,
		MaxSpecials = null,
		SmokerLimit = null,
		BoomerLimit = null,
		HunterLimit = null,
		SpitterLimit = null,
		JockeyLimit = null,
		ChargerLimit = null,
		WitchLimit = null,
		cm_WitchLimit = null,
		TankLimit = null,
		cm_TankLimit = null,
	},
	
	function OnRoundStart()
	{
		Timers.AddTimerByName(
			"sss_activing", ::SimpleSpecialSpawnner.ConfigVar.FirstSpawnDelay, true,
			::SimpleSpecialSpawnner.Timer_ActiveSpawnner, null, 0,
			{ "action" : "once" }
		);
		printl("round start");
	},
	
	function OnRoundEnd()
	{
		Timers.RemoveTimerByName("sss_activing");
		Timers.RemoveTimerByName("sss_spawnning");
	},
	
	function Timer_ActiveSpawnner(params)
	{
		::SimpleSpecialSpawnner.QueueSpawnner();
		printl("spawnner active");
		return ::SimpleSpecialSpawnner.ConfigVar.SpawnInterval;
	},
	
	function QueueSpawnner()
	{
		if(Players.Infected().len() >= ::SimpleSpecialSpawnner.ConfigVar.MaxSpawnCount)
			return;
		
		::SimpleSpecialSpawnner.QueuedToSpawn = ::SimpleSpecialSpawnner.ConfigVar.SpawnCount;
		
		Timers.AddTimerByName(
			"sss_spawnning", 0.1, true,
			::SimpleSpecialSpawnner.Timer_SpawnQueue, null, 0,
			{ "action" : "once" }
		);
	},
	
	function Timer_SpawnQueue(params)
	{
		if(!::SimpleSpecialSpawnner.ConfigVar.Enable)
			return false;
		
		if(::SimpleSpecialSpawnner.QueuedToSpawn <= 0)
			return false;
		
		::SimpleSpecialSpawnner.QueuedToSpawn -= 1;
		
		local specialClass = ::SimpleSpecialSpawnner.GetRandomSpecialClass();
		if(specialClass != null)
			::SimpleSpecialSpawnner.SpawnZombie(specialClass);
	},
	
	function GetRandomSpecialClass()
	{
		local chances = [
			0,
			::SimpleSpecialSpawnner.ConfigVar.SmokerChance,
			::SimpleSpecialSpawnner.ConfigVar.BoomerChance,
			::SimpleSpecialSpawnner.ConfigVar.HunterChance,
			::SimpleSpecialSpawnner.ConfigVar.SpitterChance,
			::SimpleSpecialSpawnner.ConfigVar.JockeyChance,
			::SimpleSpecialSpawnner.ConfigVar.ChargerChance,
			0,
			0,
		];
		
		foreach(zombie in Players.Infected())
		{
			local type = zombie.GetType();
			if(type < Z_SMOKER || type > Z_CHARGER)
				continue;
			
			chances[type] -= ::SimpleSpecialSpawnner.ClampChance(type);
			if(chances[type] < 0)
				chances[type] = 0;
		}
		
		local value = RandomInt(1, chances.reduce(@(p, n) p + n));
		for(local i = 0; i < 9; ++i)
		{
			value -= chances[i];
			if(value <= 0)
				return i;
		}
		
		return null;
	},
	
	function ClampChance(specialClass)
	{
		switch(specialClass)
		{
			case Z_SMOKER:
				return ::SimpleSpecialSpawnner.ConfigVar.SmokerChance / ::SimpleSpecialSpawnner.ConfigVar.SmokerLimit;
			case Z_BOOMER:
				return ::SimpleSpecialSpawnner.ConfigVar.BoomerChance / ::SimpleSpecialSpawnner.ConfigVar.BoomerLimit;
			case Z_HUNTER:
				return ::SimpleSpecialSpawnner.ConfigVar.HunterChance / ::SimpleSpecialSpawnner.ConfigVar.HunterLimit;
			case Z_SPITTER:
				return ::SimpleSpecialSpawnner.ConfigVar.SpitterChance / ::SimpleSpecialSpawnner.ConfigVar.SpitterLimit;
			case Z_JOCKEY:
				return ::SimpleSpecialSpawnner.ConfigVar.JockeyChance / ::SimpleSpecialSpawnner.ConfigVar.JockeyLimit;
			case Z_CHARGER:
				return ::SimpleSpecialSpawnner.ConfigVar.ChargerChance / ::SimpleSpecialSpawnner.ConfigVar.ChargerLimit;
		}
		
		return 0;
	},
	
	function SpawnZombie(specialClass)
	{
		foreach(key, value in ::SimpleSpecialSpawnner.UncapValueList)
		{
			if(key in SessionOptions && SessionOptions[key] != null)
				::SimpleSpecialSpawnner.UncapValueList[key] = SessionOptions[key];
			else
				SessionOptions[key] <- 32;
		}
		
		Utils.SpawnZombie(specialClass);
		
		foreach(key, value in ::SimpleSpecialSpawnner.UncapValueList)
		{
			if(value != null)
				SessionOptions[key] = value;
			else
				delete SessionOptions[key];
		}
	},
};

function Notifications::FirstSurvLeftStartArea::SimpleSpecialSpawnner_StartSpawnner(player, params)
{
	::SimpleSpecialSpawnner.OnRoundStart();
}

function Notifications::OnSurvivorsLeftStartArea::SimpleSpecialSpawnner_StartSpawnner()
{
	::SimpleSpecialSpawnner.OnRoundStart();
}

function Notifications::OnSurvivalStart::SimpleSpecialSpawnner_StartSpawnner()
{
	::SimpleSpecialSpawnner.OnRoundStart();
}

function Notifications::OnVersusStart::SimpleSpecialSpawnner_StartSpawnner()
{
	::SimpleSpecialSpawnner.OnRoundStart();
}

function Notifications::OnScavengeStart::SimpleSpecialSpawnner_StartSpawnner(round, firsthalf, params)
{
	::SimpleSpecialSpawnner.OnRoundStart();
}

function Notifications::OnHoldoutStart::SimpleSpecialSpawnner_StartSpawnner(params)
{
	::SimpleSpecialSpawnner.OnRoundStart();
}

function Notifications::OnRoundEnd::SimpleSpecialSpawnner_StopSpawnner(winner, reason, message, time, params)
{
	::SimpleSpecialSpawnner.OnRoundEnd();
}

function Notifications::OnMapEnd::SimpleSpecialSpawnner_StopSpawnner()
{
	::SimpleSpecialSpawnner.OnRoundEnd();
}

function Notifications::OnSurvivorsDead::SimpleSpecialSpawnner_StopSpawnner()
{
	::SimpleSpecialSpawnner.OnRoundEnd();
}

function Notifications::OnRoundStartPreEntity::SimpleSpecialSpawnner_StopSpawnner()
{
	::SimpleSpecialSpawnner.OnRoundEnd();
}

function Notifications::OnRoundStart::SimpleSpecialSpawnner_StopSpawnner()
{
	::SimpleSpecialSpawnner.OnRoundEnd();
}

::SimpleSpecialSpawnner.PLUGIN_NAME <- PLUGIN_NAME;
::SimpleSpecialSpawnner.ConfigVar = ::SimpleSpecialSpawnner.ConfigVarDef;

function Notifications::OnRoundStart::SimpleSpecialSpawnner_LoadConfig()
{
	RestoreTable(::SimpleSpecialSpawnner.PLUGIN_NAME, ::SimpleSpecialSpawnner.ConfigVar);
	if(::SimpleSpecialSpawnner.ConfigVar == null || ::SimpleSpecialSpawnner.ConfigVar.len() <= 0)
		::SimpleSpecialSpawnner.ConfigVar = FileIO.GetConfigOfFile(::SimpleSpecialSpawnner.PLUGIN_NAME, ::SimpleSpecialSpawnner.ConfigVarDef);
	
	// printl("[plugins] " + ::SimpleSpecialSpawnner.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::SimpleSpecialSpawnner_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::SimpleSpecialSpawnner.PLUGIN_NAME, ::SimpleSpecialSpawnner.ConfigVar);

	// printl("[plugins] " + ::SimpleSpecialSpawnner.PLUGIN_NAME + " saving...");
}
