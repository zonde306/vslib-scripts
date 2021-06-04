::TankDoorOpener <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 16,

		// 是否开启禁止玩门
		AllowAntiDoorSpam = true,

		// 连续 开/关 同一扇门超过多少次视为玩门
		DoorSpamCount = 5,

		// 被检测到玩门后禁止按 E 多少秒
		DoorSpamDuration = 9.0,

		// 在多少秒之内连续开关门进行计数
		DoorSpamInterval = 1.0
	},

	ConfigVar = {},

	function IsNeedHelp(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead() || !player.IsSurvivor())
			return false;
		
		if(player.IsIncapacitated() || player.IsHangingFromLedge() || player.IsHangingFromTongue() ||
			player.IsBeingJockeyed() || player.IsPounceVictim() || player.IsTongueVictim() ||
			player.IsCarryVictim() || player.IsPummelVictim())
			return true;
		
		return false;
	},
	
	function Timer_TankAimgingCheck(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead() || player.GetType() != Z_TANK)
			return false;
		
		local entity = player.GetLookingEntity(TRACE_MASK_PLAYER_SOLID);
		if(entity == null || !entity.IsEntityValid() || entity.GetClassname() != "prop_door_rotating" ||
			Utils.CalculateDistance(entity.GetLocation(), player.GetLocation()) > Convars.GetFloat("player_use_radius"))
			return true;
		
		// 如果门可以被破坏救破坏门，不行就开门
		// entity.Input("Unlock");
		// entity.Input("SetBreakable");
		entity.Input("Open", "", 0.1, player);
		entity.Damage(3000, DMG_BLAST, player);
		return true;
	},
	
	DoorPlayCounter = {},
	
	function Timer_StopDoorSpam(player)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead() || player.GetType() != Z_SURVIVOR)
			return false;
		
		local index = player.GetIndex();
		if(index in ::TankDoorOpener.DoorPlayCounter)
			delete ::TankDoorOpener.DoorPlayCounter[index];
		
		return false;
	},
	
	function Timer_BlockDoorSpam(player)
	{
		if(player == null || !player.IsPlayerEntityValid())
			return false;
		
		player.EnableButton(BUTTON_USE);
		::TankDoorOpener.Timer_StopDoorSpam(player);
		Timers.RemoveTimerByName("timer_anti_door_spam_" + player.GetIndex());
		
		printl("player " + player.GetName() + " Stop DoorBlocking.");
		return false;
	},
	
	/*
	function OnOutput_DoorOpen()
	{
		
	},
	
	function OnOutput_DoorClose()
	{
		
	},
	
	CurrentDoor = {},
	
	function Timer_CheckDoorSpam(params)
	{
		if(!::TankDoorOpener.ConfigVar.AllowAntiDoorSpam)
			return;
		
		foreach(player in Players.AliveSurvivors())
		{
			if(player.IsBot() || !player.IsPressingUse() || ::TankDoorOpener.IsNeedHelp(player))
				continue;
			
			local entity = player.GetLookingEntity(TRACE_MASK_PLAYER_SOLID);
			if(entity == null || !entity.IsEntityValid())
				continue;
			
			local classname = entity.GetClassname();
			if(classname != "prop_door_rotating" && classname != "prop_door_rotating_checkpoint")
				continue;
			
			if(Utils.CalculateDistance(entity.GetLocation(), player.GetLocation()) > Convars.GetFloat("player_use_radius"))
				continue;
			
			entity.ConnectOutput("OnOpen", ::TankDoorOpener.OnOutput_DoorOpen);
			entity.ConnectOutput("OnClose", ::TankDoorOpener.OnOutput_DoorClose);
		}
	}
	*/
}

function Notifications::OnTankSpawned::TankOpenDoor_HookThink(player, params)
{
	if(!::TankDoorOpener.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayerEntityValid())
		return;
	
	Timers.AddTimerByName("tank_door_opener_" + player.GetIndex(), 0.1, true,
		::TankDoorOpener.Timer_TankAimgingCheck, player);
}

function Notifications::OnTankFrustrated::TankOpenDoor_HookThink(player, params)
{
	if(!::TankDoorOpener.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsPlayerEntityValid())
		return;
	
	Timers.AddTimerByName("tank_door_opener_" + player.GetIndex(), 0.1, true,
		::TankDoorOpener.Timer_TankAimgingCheck, player);
}

function Notifications::OnTankKilled::TankOpenDoor_UnhookThink(player, attacker, params)
{
	if(player == null || !player.IsPlayerEntityValid())
		return;
	
	Timers.RemoveTimerByName("tank_door_opener_" + player.GetIndex());
}

function Notifications::OnDoorOpened::TankOpenDoor_DoorSpamCounter(player, checkpoint, params)
{
	if(!::TankDoorOpener.ConfigVar.AllowAntiDoorSpam)
		return;
	
	if(player == null || !player.IsPlayerEntityValid() || !params["closed"])
		return;
	
	/*
	local entity = player.GetLookingEntity(TRACE_MASK_PLAYER_SOLID);
	if(entity == null || !entity.IsEntityValid())
		continue;
	
	local classname = entity.GetClassname();
	if(classname != "prop_door_rotating" && classname != "prop_door_rotating_checkpoint")
		continue;
	
	if(Utils.CalculateDistance(entity.GetLocation(), player.GetLocation()) > Convars.GetFloat("player_use_radius"))
		continue;
	*/
	
	printl("player " + player.GetName() + " opened a door");
	Notifications.OnDoorMoving.TankOpenDoor_DoorSpamCounter(player, null, params);
}

function Notifications::OnDoorClosed::TankOpenDoor_DoorSpamCounter(player, checkpoint, params)
{
	if(!::TankDoorOpener.ConfigVar.AllowAntiDoorSpam)
		return;
	
	if(player == null || !player.IsPlayerEntityValid())
		return;
	
	/*
	local entity = player.GetLookingEntity(TRACE_MASK_PLAYER_SOLID);
	if(entity == null || !entity.IsEntityValid())
		continue;
	
	local classname = entity.GetClassname();
	if(classname != "prop_door_rotating" && classname != "prop_door_rotating_checkpoint")
		continue;
	
	if(Utils.CalculateDistance(entity.GetLocation(), player.GetLocation()) > Convars.GetFloat("player_use_radius"))
		continue;
	*/
	
	printl("player " + player.GetName() + " closed a door");
	Notifications.OnDoorMoving.TankOpenDoor_DoorSpamCounter(player, null, params);
}

function Notifications::OnDoorMoving::TankOpenDoor_DoorSpamCounter(player, entity, params)
{
	if(!::TankDoorOpener.ConfigVar.AllowAntiDoorSpam)
		return;
	
	if(player == null || !player.IsPlayerEntityValid()/* || entity == null || !entity.IsEntityValid()*/)
		return;
	
	/*
	local classname = entity.GetClassname();
	if(classname != "prop_door_rotating" && classname != "prop_door_rotating_checkpoint")
		continue;
	*/
	
	local index = player.GetIndex();
	if(index in ::TankDoorOpener.DoorPlayCounter)
		::TankDoorOpener.DoorPlayCounter[index] += 1;
	else
		::TankDoorOpener.DoorPlayCounter[index] <- 1;
	
	if(::TankDoorOpener.DoorPlayCounter[index] >= ::TankDoorOpener.ConfigVar.DoorSpamCount)
	{
		player.Stagger();
		player.DisableButton(BUTTON_USE);
		
		Timers.RemoveTimerByName("timer_anti_door_spam_" + index);
		Timers.AddTimerByName("timer_restore_block_door_spam_" + index, ::TankDoorOpener.ConfigVar.DoorSpamDuration, false,
			::TankDoorOpener.Timer_BlockDoorSpam, player);
		
		printl("player " + player.GetName() + " Start DoorBlocking.");
	}
	else
	{
		Timers.AddTimerByName("timer_anti_door_spam_" + index, ::TankDoorOpener.ConfigVar.DoorSpamInterval, false,
			::TankDoorOpener.Timer_StopDoorSpam, player);
	}
}


::TankDoorOpener.PLUGIN_NAME <- PLUGIN_NAME;
::TankDoorOpener.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::TankDoorOpener.ConfigVarDef);

function Notifications::OnRoundStart::TankDoorOpener_LoadConfig()
{
	RestoreTable(::TankDoorOpener.PLUGIN_NAME, ::TankDoorOpener.ConfigVar);
	if(::TankDoorOpener.ConfigVar == null || ::TankDoorOpener.ConfigVar.len() <= 0)
		::TankDoorOpener.ConfigVar = FileIO.GetConfigOfFile(::TankDoorOpener.PLUGIN_NAME, ::TankDoorOpener.ConfigVarDef);

	// printl("[plugins] " + ::TankDoorOpener.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::TankDoorOpener_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::TankDoorOpener.PLUGIN_NAME, ::TankDoorOpener.ConfigVar);

	// printl("[plugins] " + ::TankDoorOpener.PLUGIN_NAME + " saving...");
}
