::SkipIntro <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,
	},
	
	ConfigVar = {},
	
	function Timer_SkipIntro(params)
	{
		local director = ::VSLib.Entity("info_director");
		if(!director.IsValid())
			return;
		
		local done = false;
		local name = director.GetName();
		
		local function EnableControl(entity)
		{
			entity.Input("AddOutput", "OnUser1 " + name + ":ReleaseSurvivorPositions::0:-1");
			entity.Input("AddOutput", "OnUser1 " + name + ":FinishIntro::0:-1");
			entity.Input("FireUser1");
			done = true;
		}
		
		local function StopScene(entity)
		{
			entity.Input("AddOutput", "OnUser2 " + entity.GetName() + ":StartMovement::0:-1");
			entity.Input("FireUser2");
		}
		
		foreach(entity in Objects.OfClassname("point_viewcontrol_survivor"))
		{
			if(!done)
				EnableControl(entity);
			
			StopScene(entity);
		}
		
		foreach(entity in Objects.OfClassname("point_viewcontrol_multiplayer"))
		{
			if(!done)
				EnableControl(entity);
			
			StopScene(entity);
		}
		
		foreach(entity in Objects.OfClassname("point_deathfall_camera"))
		{
			entity.Kill();
		}
		
		if(done)
		{
			local fade = Utils.CreateEntity("env_fade", Vector(0,0,0), QAngle(0,0,0), {
				"spawnflags" : "1",
				"rendercolor" : "0 0 0",
				"renderamt" : "255",
				"holdtime" : "1",
				"duration" : "1",
				"duration" : "1",
			}, [
				"OnUser1 !self:Kill::2.1:-1",
			]);
			
			fade.Input("Fade");
			fade.Input("FireUser1");
		}
	},
};

function Notifications::OnInstructorNoDraw::SkipIntro()
{
	if(!::SkipIntro.ConfigVar.Enable)
		return;
	
	Timers.AddTimerByName("skip_intro", 1.0, false, ::SkipIntro.Timer_SkipIntro);
}

::SkipIntro.PLUGIN_NAME <- PLUGIN_NAME;
::SkipIntro.ConfigVar = ::SkipIntro.ConfigVarDef;

function Notifications::OnRoundStart::SkipIntro_LoadConfig()
{
	RestoreTable(::SkipIntro.PLUGIN_NAME, ::SkipIntro.ConfigVar);
	if(::SkipIntro.ConfigVar == null || ::SkipIntro.ConfigVar.len() <= 0)
		::SkipIntro.ConfigVar = FileIO.GetConfigOfFile(::SkipIntro.PLUGIN_NAME, ::SkipIntro.ConfigVarDef);

	// printl("[plugins] " + ::SkipIntro.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::SkipIntro_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::SkipIntro.PLUGIN_NAME, ::SkipIntro.ConfigVar);

	// printl("[plugins] " + ::SkipIntro.PLUGIN_NAME + " saving...");
}
