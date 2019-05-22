::SafeRoomDoor <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 16,
		
		// 创建的门消失的时间
		KillDelay = 8.0,
		
		// 创建门的延迟
		CreateDelay = 3.0,
	},
	
	ConfigVar = {},
	
	StartSafeDoor = null,
	ReplaceSafeDoor = null,
	IsDoorCreated = false,
	IsRoundStarting = true,
	
	function DegToRad(angles)
	{
		return angles * (180.0 / 3.14159265);
	},
	
	function CreateSafeDoor(angles)
	{
		if(::SafeRoomDoor.StartSafeDoor == null || ::SafeRoomDoor.IsDoorCreated ||
			!::SafeRoomDoor.StartSafeDoor.IsEntityValid())
			return null;
		
		local entity = Utils.CreateEntity("prop_physics",
			::SafeRoomDoor.StartSafeDoor.GetLocation(),
			::SafeRoomDoor.StartSafeDoor.GetAngles() + QAngle(-5, 5, 0),
			{model = ::SafeRoomDoor.StartSafeDoor.GetModel(), spawnflags = 4});
		
		if(entity == null)
			return null;
		
		entity.SetVelocity(Vector(cos(::SafeRoomDoor.DegToRad(angles.y)) * 100,
			sin(::SafeRoomDoor.DegToRad(angles.y)) * 100,
			sin(::SafeRoomDoor.DegToRad(angles.x)) * 15).Scale(5.0));
		
		entity.KillDelayed(::SafeRoomDoor.ConfigVar.KillDelay);
		::SafeRoomDoor.StartSafeDoor.Kill();
		::SafeRoomDoor.ReplaceSafeDoor = entity;
		::SafeRoomDoor.IsDoorCreated = true;
	},
	
	function FindSafeRoomDoor(player)
	{
		local entity = null;
		
		if(player != null && player.IsEntityValid())
		{
			entity = Objects.OfClassnameNearest("prop_door_rotating_checkpoint", player.GetLocation(),
				Convars.GetFloat("player_use_radius") + 50.0);
		}
		else
		{
			foreach(ent in Objects.OfClassname("prop_door_rotating_checkpoint"))
			{
				if(g_MapScript.GetCurrentFlowDistanceForPlayer(ent) < 100.0)
				{
					entity = ent;
					break;
				}
			}
		}
		
		::SafeRoomDoor.StartSafeDoor = entity;
		return entity;
	}
};

function Notifications::OnRoundBegin::SafeRoomDoor_OnRoundStarting(params)
{
	::SafeRoomDoor.IsRoundStarting = true;
}

function Notifications::FirstSurvLeftStartArea::SafeRoomDoor_OnRoundStarted(player, params)
{
	::SafeRoomDoor.IsRoundStarting = false;
}

function Notifications::OnDoorUnlocked::SafeRoomDoor_OnGateUnlock(player, checkpoint, params)
{
	if(!::SafeRoomDoor.ConfigVar.Enable || !checkpoint || !::SafeRoomDoor.IsRoundStarting)
		return;
	
	if(::SafeRoomDoor.StartSafeDoor == null)
		::SafeRoomDoor.FindSafeRoomDoor(player);
}

function Notifications::OnDoorOpened::SafeRoomDoor_OnGateOpening(player, checkpoint, params)
{
	if(!::SafeRoomDoor.ConfigVar.Enable || !checkpoint || !::SafeRoomDoor.IsRoundStarting)
		return;
	
	if(player == null || !player.IsSurvivor() || player.GetFlowPercent() > 10.0)
		return;
	
	if(::SafeRoomDoor.StartSafeDoor == null)
		::SafeRoomDoor.FindSafeRoomDoor(player);
	
	// ::SafeRoomDoor.CreateSafeDoor(player.GetEyeAngles());
	Timers.AddTimerByName("timer_createsaferoomdoor", ::SafeRoomDoor.ConfigVar.CreateDelay, false,
		::SafeRoomDoor.CreateSafeDoor, player.GetEyeAngles());
}

::SafeRoomDoor.PLUGIN_NAME <- PLUGIN_NAME;
::SafeRoomDoor.ConfigVar = ::SafeRoomDoor.ConfigVarDef;

function Notifications::OnRoundStart::SafeRoomDoor_LoadConfig()
{
	RestoreTable(::SafeRoomDoor.PLUGIN_NAME, ::SafeRoomDoor.ConfigVar);
	if(::SafeRoomDoor.ConfigVar == null || ::SafeRoomDoor.ConfigVar.len() <= 0)
		::SafeRoomDoor.ConfigVar = FileIO.GetConfigOfFile(::SafeRoomDoor.PLUGIN_NAME, ::SafeRoomDoor.ConfigVarDef);

	// printl("[plugins] " + ::SafeRoomDoor.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::SafeRoomDoor_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::SafeRoomDoor.PLUGIN_NAME, ::SafeRoomDoor.ConfigVar);

	// printl("[plugins] " + ::SafeRoomDoor.PLUGIN_NAME + " saving...");
}
