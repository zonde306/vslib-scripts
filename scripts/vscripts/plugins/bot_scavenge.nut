::BotScavenge <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
		
		// 机器人倒油最大距离
		PourDistance = 250,
		
		// 机器人倒油时间
		PourDuration = 3.0,
		
		// 机器人寻找汽油范围
		SearchDistance = 3000,
		
		// 机器人捡起汽油范围
		PickupDistance = 200,
		
		// 机器人寻找灌油口范围
		PourScanRadius = 800,
	},
	
	ConfigVar = {},
	
	// 当前需要倒的汽油
	CurrentGascan = null,
	
	// 当前需要前往的倾倒点
	CurrentPourPoint = null,
	
	// 需要倾倒的物体的名字
	CurrentPourName = null,
	
	// 进度条
	CurrentProgress = null,
	
	HasNeedGascan = true,
	PourGascanTotal = 0,
	
	function ForcePourGas(player, target = null)
	{
		if(player == null || !player.IsSurvivor())
			return false;
		
		local inv = player.GetHeldItems();
		if(!("slot5" in inv) || inv["slot5"] == null || !inv["slot5"].IsEntityValid())
			return false;
		
		if(target == null)
			target = ::BotScavenge.FindPourPoint(inv["slot5"].GetTargetname(), player.GetLocation());
		
		if(target == null)
			return false;
		
		local distance = Utils.CalculateDistance(player.GetLocation(), target.GetLocation());
		if(distance <= ::BotScavenge.ConfigVar.PourDistance)
		{
			Timers.AddTimerByName("bot_pour_gascan_" + player.GetIndex(), ::BotScavenge.ConfigVar.PourDuration, false, ::BotScavenge.Timer_PourGascan,
				{ "player" : player, "target" : target }, { "action" : "once" });
		}
		
		player.BotReset();
		player.BotMoveToOther(target);
	}
	
	function FindPourPoint(name, origin)
	{
		foreach(entity in Objects.OfClassnameWithin("point_prop_use_target", origin, ::BotScavenge.ConfigVar.PourScanRadius))
		{
			if(entity.GetNetPropString("m_sGasNozzleName") != name)
				continue;
			
			return entity;
		}
		
		return null;
	}
	
	function FindPourProgress()
	{
		foreach(entity in Objects.OfClassname("game_scavenge_progress_display"))
		{
			if(!entity.GetNetPropBool("m_bActive"))
				continue;
			
			return entity;
		}
		
		return null;
	},
	
	function FindGascan(origin)
	{
		if(::BotScavenge.CurrentPourName == null)
			return null;
		
		local entity = Objects.OfNameNearest(::BotScavenge.CurrentPourName, origin, ::BotScavenge.ConfigVar.SearchDistance);
		if(entity == null || entity.GetClassname() == "weapon_scavenge_item_spawn")
		{
			if(::BotScavenge.HasNeedGascan)
				entity = Objects.OfClassnameNearest("weapon_gascan", origin, ::BotScavenge.ConfigVar.SearchDistance);
			else
				entity = Objects.OfClassnameNearest("weapon_cola_bottles", origin, ::BotScavenge.ConfigVar.SearchDistance);
		}
		
		if(entity == null)
			return null;
		
		::BotScavenge.CurrentGascan = entity;
		return entity;
	},
	
	function HasScavengeActive()
	{
		if(::BotScavenge.CurrentProgress == null && ::BotScavenge.CurrentPourPoint != null)
			return true;
		
		return ::BotScavenge.CurrentProgress.GetNetPropBool("m_bActive");
	},
	
	function Timer_OnPlayerThink(params)
	{
		if(!::BotScavenge.ConfigVar.Enable)
			return;
		
		
	},
	
	function Timer_PourGascan(player)
	{
		if(player == null || !player.IsSurvivor() || player.IsDead())
			return;
		
		if(player.HasVisibleThreats() || player.IsInCombat())
		{
			player.BotReset();
			return;
		}
		
		local inv = player.GetHeldItems();
		if(!("slot5" in inv) || inv["slot5"] == null || inv["slot5"] != ::BotScavenge.CurrentGascan)
			return;
		
		local entity = ::VSLib.Entity("info_director");
		if(entity == null || !entity.IsEntityValid())
			return;
		
		entity.Input("IncrementTeamScore", "2");
		
		// TODO: 检查数量并触发救援
		if("GasCanPoured" in g_MapScript)
			g_MapScript.GasCanPoured();
		if("GasCanPoured" in g_ModeScript)
			g_ModeScript.GasCanPoured();
		foreach(rule in Objects.OfClassname("terror_gamerules"))
			rule.SetNetPropInt("terror_gamerules_data.m_iScavengeTeamScore", rule.GetNetPropInt("terror_gamerules_data.m_iScavengeTeamScore"));
		foreach(counter in Objects.OfClassname("math_counter"))
			counter.Input("Add", "1", 0, player);
		
		if(::BotScavenge.CurrentProgress != null && ::BotScavenge.CurrentProgress.IsEntityValid())
		{
			if(::BotScavenge.PourGascanTotal >= ::BotScavenge.CurrentProgress.GetNetPropInt("m_nTotalScavengeItems"))
				Utils.TriggerRescue();
		}
	}
};

::BotScavenge.PLUGIN_NAME <- PLUGIN_NAME;
::BotScavenge.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::BotScavenge.ConfigVarDef);

function Notifications::OnRoundStart::BotScavenge_LoadConfig()
{
	RestoreTable(::BotScavenge.PLUGIN_NAME, ::BotScavenge.ConfigVar);
	if(::BotScavenge.ConfigVar == null || ::BotScavenge.ConfigVar.len() <= 0)
		::BotScavenge.ConfigVar = FileIO.GetConfigOfFile(::BotScavenge.PLUGIN_NAME, ::BotScavenge.ConfigVarDef);

	// printl("[plugins] " + ::BotScavenge.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::BotScavenge_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::BotScavenge.PLUGIN_NAME, ::BotScavenge.ConfigVar);

	// printl("[plugins] " + ::BotScavenge.PLUGIN_NAME + " saving...");
}
