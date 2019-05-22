::SpecialSpawnner <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = false,
		
		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = false,
		
		// 难度上限 [0 ~ 100]，大于就进入安全时间
		MaxIntensity = 75,
		
		// 难度下限 [0 ~ 100]，小于就进入袭击时间
		MinIntensity = 25,
		
		// 刷特一波感最小间隔(秒)
		MinInterval = 15.0,
		
		// 刷特一波感最大间隔(秒)
		MaxInterval = 30.0,
		
		// 开局启动延迟
		StartDelay = 30.0,
		
		// 是否必须离开安全室才启动
		StartWithLeftSafeRoom = true,
		
		// 每有一名幸存者倒地获得多少秒的宽限时间
		GracePeriodOfIncapped = 7,
		
		// 每有一名幸存者被控获得多少秒的宽限时间
		GracePeriodOfGrabbed = 5,
		
		// 刷特感权重
		SpecialWeight =
		[
			{name = "smoker", classId = Z_SMOKER, weight = 100},
			{name = "boomer", classId = Z_BOOMER, weight = 100},
			{name = "hunter", classId = Z_HUNTER, weight = 100},
			{name = "spitter", classId = Z_SPITTER, weight = 100},
			{name = "jockey", classId = Z_JOCKEY, weight = 100},
			{name = "charger", classId = Z_CHARGER, weight = 100},
		],
	},
	
	ConfigVar = {},
	
	SpawnQueue = {},
	MaxSpecialCount = 4,
	CurrentSpecialCount = 0,
	
	function CreateSpawnQueue()
	{
		local totalWeight = 0;
		foreach(item in ::SpecialSpawnner.ConfigVar.SpecialWeight)
			totalWeight += item.weight;
		
		::SpecialSpawnner.GetMaxSpecialCount();
		for(local i = ::SpecialSpawnner.SpawnQueue.len(); i < ::SpecialSpawnner.MaxSpecialCount; ++i)
		{
			local plane = ::SpecialSpawnner.GetRandomPlane(i);
			if(plane != null)
				::SpecialSpawnner.SpawnQueue.append(plane);
		}
		
		printl("[SS] SpawnQueue update (" + ::SpecialSpawnner.SpawnQueue.len() + "/" + ::SpecialSpawnner.MaxSpecialCount + ").");
	},
	
	function ExecuteSpawnQueue()
	{
		if(::SpecialSpawnner.SpawnQueue.len() <= 0)
			return;
		
		::SpecialSpawnner.GetCurrentSpecialCount();
		local needCount = ::SpecialSpawnner.MaxSpecialCount - ::SpecialSpawnner.CurrentSpecialCount;
		if(needCount <= 0)
			return;
		
		for(local i = 0; i < needCount; ++i)
		{
			if(::SpecialSpawnner.SpawnQueue.len() <= 0)
				break;
			
			local plane = ::SpecialSpawnner.SpawnQueue.top();
			::SpecialSpawnner.SpawnQueue.remove(0);
			if(plane == null)
				continue;
			
			Utils.SpawnZombie(plane.classId);
		}
		
		::SpecialSpawnner.GetCurrentSpecialCount();
		printl("[SS] SpawnQueue execute (" + ::SpecialSpawnner.CurrentSpecialCount + "/" + ::SpecialSpawnner.MaxSpecialCount + ").");
	},
	
	function GetRandomPlane(someNumber)
	{
		srand(Time() + someNumber);
		local num = Utils.GetRandNumber(1, totalWeight);
		foreach(item in ::SpecialSpawnner.ConfigVar.SpecialWeight)
		{
			num -= item.weight;
			if(num <= 0)
				return item;
		}
		
		return null;
	},
	
	function GetMaxSpecialCount()
	{
		if("cm_MaxSpecials" in SessionOptions)
			::SpecialSpawnner.MaxSpecialCount = SessionOptions.cm_MaxSpecials;
		else if("MaxSpecials" in SessionOptions)
			::SpecialSpawnner.MaxSpecialCount = SessionOptions.MaxSpecials;
		else
			::SpecialSpawnner.MaxSpecialCount = floor(Convars.GetFloat("survival_max_specials"));
		
		return ::SpecialSpawnner.MaxSpecialCount;
	},
	
	function GetCurrentSpecialCount()
	{
		::SpecialSpawnner.CurrentSpecialCount = 0;
		foreach(player in Players.Infected())
		{
			if(player.IsDead() || player.IsGhost())
				continue;
			
			::SpecialSpawnner.CurrentSpecialCount += 1;
		}
	},
};

::SpecialSpawnner.PLUGIN_NAME <- PLUGIN_NAME;
::SpecialSpawnner.ConfigVar = ::SpecialSpawnner.ConfigVarDef;

function Notifications::OnRoundStart::SpecialSpawnner_LoadConfig()
{
	RestoreTable(::SpecialSpawnner.PLUGIN_NAME, ::SpecialSpawnner.ConfigVar);
	if(::SpecialSpawnner.ConfigVar == null || ::SpecialSpawnner.ConfigVar.len() <= 0)
		::SpecialSpawnner.ConfigVar = FileIO.GetConfigOfFile(::SpecialSpawnner.PLUGIN_NAME, ::SpecialSpawnner.ConfigVarDef);

	// printl("[plugins] " + ::SpecialSpawnner.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::SpecialSpawnner_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::SpecialSpawnner.PLUGIN_NAME, ::SpecialSpawnner.ConfigVar);

	// printl("[plugins] " + ::SpecialSpawnner.PLUGIN_NAME + " saving...");
}
