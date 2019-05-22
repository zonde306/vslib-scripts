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
		
		// 倒汽油是否必须到指定位置才能倒，否则捡起来就立刻开始倒
		PourMode = true
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
	
	function FindPourProgress()
	{
		local entity = ::VSLib.Entity("game_scavenge_progress_display");
		if(entity == null || !entity.IsEntityValid())
			return null;
		
		::BotScavenge.CurrentProgress = entity;
		return entity;
	},
	
	function FindPourPoint()
	{
		local entity = ::VSLib.Entity("point_prop_use_target");
		if(entity == null || !entity.IsEntityValid())
			return null;
		
		::BotScavenge.CurrentPourPoint = entity;
		// ::BotScavenge.CurrentPourName = entity.GetNetPropString("m_iName");
		::BotScavenge.CurrentPourName = entity.GetNetPropString("m_sGasNozzleName");
		::BotScavenge.HasNeedGascan = (::BotScavenge.CurrentPourName.find("gascan") != null);
		return entity;
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
		
		if(::BotScavenge.CurrentPourPoint == null && ::BotScavenge.FindPourPoint())
			return;
		
		if(::BotScavenge.CurrentGascan == null && ::BotScavenge.FindGascan() == null)
			return;
		
		if(!::BotScavenge.HasScavengeActive())
			return false;
		
		local holder = ::BotScavenge.CurrentGascan.GetOwnerEntity();
		if(holder != null && holder.IsSurvivor() && !player.HasVisibleThreats())
		{
			// 已经有人捡起了汽油，可以前往倒油了
			if(::BotScavenge.ConfigVar.PourMode)
			{
				// 假装在倒油
				if(holder.GetDistanceToOther(::BotScavenge.CurrentPourPoint) <= ::BotScavenge.ConfigVar.PourDistance)
					Timers.AddTimerOne("bot_pour_gascan_" + holder.GetIndex(), ::BotScavenge.ConfigVar.PourDuration);
				
				holder.BotMoveToOther(::BotScavenge.CurrentPourPoint);
			}
			else
			{
				// 远程倒油
				Timers.AddTimerOne("bot_pour_gascan_" + holder.GetIndex(), ::BotScavenge.ConfigVar.PourDuration);
			}
		}
		else
		{
			// 捡汽油
			local picker = null;
			foreach(player in Players.SurvivorBots())
			{
				if(player.HasVisibleThreats())
					continue;
				
				picker = player;
			}
			
			if(picker == null)
				return;
			
			if(picker.GetDistanceToOther(::BotScavenge.CurrentGascan) <= ::BotScavenge.ConfigVar.PickupDistance)
			{
				::BotScavenge.CurrentGascan.Use(picker);
				picker.BotReset();
			}
			else
				picker.BotMoveToOther(::BotScavenge.CurrentGascan);
		}
	},
	
	function Timer_PourGascan(player)
	{
		if(player == null || !player.IsSurvivor() || player.IsDead())
			return;
		
		if(player.HasVisibleThreats())
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
		::BotScavenge.CurrentGascan.Kill();
		::BotScavenge.CurrentGascan = null;
		::BotScavenge.PourGascanTotal += 1;
		
		// TODO: 检查数量并触发救援
		if("GasCanPoured" in g_MapScript)
			g_MapScript.GasCanPoured();
		if("GasCanPoured" in g_ModeScript)
			g_ModeScript.GasCanPoured();
		
		if(::BotScavenge.CurrentProgress != null && ::BotScavenge.CurrentProgress.IsEntityValid())
		{
			if(::BotScavenge.PourGascanTotal >= ::BotScavenge.CurrentProgress.GetNetPropInt("m_nTotalScavengeItems"))
				Utils.TriggerRescue();
		}
	}
};

::BotScavenge.PLUGIN_NAME <- PLUGIN_NAME;
::BotScavenge.ConfigVar = ::BotScavenge.ConfigVarDef;

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
