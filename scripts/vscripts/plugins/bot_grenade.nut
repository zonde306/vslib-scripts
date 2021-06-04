::BotGrenade <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,

		// 机器人对克扔雷.0=禁用.1=火瓶.2=土雷.4=胆汁
		ThrowTank = 5,

		// 是否开启倒地丢雷.0=禁用.1=火瓶.2=土雷.4=胆汁
		IncapThrow = 7,

		// 是否开启机器人尸潮丢雷.0=禁用.1=火瓶.2=土雷.4=胆汁
		PanicThrow = 6,

		// 是否开启机器人被粘上胆汁丢雷.0=禁用.1=火瓶.2=土雷.4=胆汁
		VomitThrow = 2,

		// 是否开启机器人惊吓witch丢雷.0=禁用.1=火瓶.2=土雷.4=胆汁
		HarasserThrow = 5,
		
		// 普感数量达到多少时尝试投掷胆汁或土制
		AutoThrowWithCommon = 25,
		
		// 附近普感数量达到多少时投掷胆汁或土制
		AutoThrowWithNear = 10,
		
		// 附近普感距离
		NearInfectedRadius = 300,
	},

	ConfigVar = {},

	PipeBomb_BeepDelta = 0.0,
	PipeBomb_BeepMin = 0.0,
	
	// 创建火焰
	function CreateFlame(pos, player = null)
	{
		// local entity = Utils.SpawnWeapon("weapon_gascan", 1, 1, pos, QAngle(0, 0, 0), {physdamagescale = 0.0});
		local entity = Utils.SpawnEntity("prop_physics", "vslib_gascan_flame", pos, QAngle(0, 0, 0),
			{physdamagescale = 0.0, model = "models/props_junk/gascan001a.mdl"});
		
		if(entity == null || !entity.IsEntityValid())
			return false;
		
		entity.SetNetPropInt("m_takedamage", 2);
		
		if(player != null && player.IsPlayerEntityValid())
		{
			entity.Damage(32, DMG_BURN, player);
			entity.Input("Break", "", 0, player);
		}
		else
		{
			entity.Damage(32, DMG_BURN);
			entity.Break();
		}
		
		return true;
	},
	
	// 创建爆炸
	function CreateExplode(pos, player = null)
	{
		// local entity = Utils.SpawnWeapon("weapon_propanetank", 1, 1, pos, QAngle(0, 0, 0), {physdamagescale = 0.0});
		local entity = Utils.SpawnEntity("prop_physics", "vslib_propanetank_explode", pos, QAngle(0, 0, 0),
			{physdamagescale = 0.0, model = "models/props_junk/propanecanister001a.mdl"});
		
		if(entity == null || !entity.IsEntityValid())
			return false;
		
		entity.SetNetPropInt("m_takedamage", 2);
		
		if(player != null && player.IsPlayerEntityValid())
		{
			entity.Damage(32, DMG_BURN, player);
			entity.Input("Break", "", 0, player);
		}
		else
		{
			entity.Damage(32, DMG_BURN);
			entity.Break();
		}
		
		return true;
	},
	
	// 创建烟花
	function CreateFirework(pos, player = null)
	{
		// local entity = Utils.SpawnWeapon("weapon_fireworkcrate", 1, 1, pos, QAngle(0, 0, 0), {physdamagescale = 0.0});
		local entity = Utils.SpawnEntity("prop_physics", "vslib_fireworkcrate_explode", pos, QAngle(0, 0, 0),
			{physdamagescale = 0.0, model = "models/props_junk/explosive_box001.mdl"});
		
		if(entity == null || !entity.IsEntityValid())
			return false;
		
		entity.SetNetPropInt("m_takedamage", 2);
		
		if(player != null && player.IsPlayerEntityValid())
		{
			entity.Damage(32, DMG_BURN, player);
			entity.Input("Break", "", 0, player);
		}
		else
		{
			entity.Damage(32, DMG_BURN);
			entity.Break();
		}
		
		return true;
	},
	
	// 创建氧气瓶爆炸
	function CreateDelayExplode(pos, player = null)
	{
		// local entity = Utils.SpawnWeapon("weapon_oxygentank", 1, 1, pos, QAngle(0, 0, 0), {physdamagescale = 0.0});
		local entity = Utils.SpawnEntity("prop_physics", "vslib_oxygentank_explode", pos, QAngle(0, 0, 0),
			{physdamagescale = 0.0, model = "models/props_equipment/oxygentank01.mdl"});
		
		if(entity == null || !entity.IsEntityValid())
			return false;
		
		entity.SetNetPropInt("m_takedamage", 2);
		
		if(player != null && player.IsPlayerEntityValid())
		{
			entity.Damage(32, DMG_BURN, player);
			entity.Input("Break", "", 0, player);
		}
		else
		{
			entity.Damage(32, DMG_BURN);
			entity.Break();
		}
		
		return true;
	},
	
	function CreateVomitjarEffect(pos, radius = 100, index = 0)
	{
		local particle = Utils.SpawnEntity("info_particle_system", "vslib_vomitjar_particle_" + index, pos,
			QAngle(0, 0, 0), {start_active = true, effect_name = "vomit_jar"});
		local chase = Utils.SpawnEntity("info_goal_infected_chase", "vslib_vomitjar_chase_" + index, pos);
		if(chase != null && chase.IsEntityValid())
		{
			chase.Input("Enable");
			chase.Input("Kill", "", Convars.GetFloat("vomitjar_duration_infected_pz"));
		}
		
		if(particle != null && particle.IsEntityValid())
		{
			particle.Input("Start");
			particle.Input("Kill", "", Convars.GetFloat("vomitjar_duration_infected_bot"));
		}
		
		foreach(player in Objects.OfClassnameWithin("player", pos, radius))
		{
			if(player.GetTeam() != INFECTED || player.IsDead() || !player.CanTraceToLocation(pos))
				continue;
			
			player.Vomit();
		}
		
		if(particle == null || chase == null || !particle.IsEntityValid() || !chase.IsEntityValid())
			return false;
		
		return true;
	},
	
	function GetRandomAngles()
	{
		return QAngle(RandomFloat(-180.0, 180.0), RandomFloat(-180.0, 180.0), RandomFloat(-180.0, 180.0));
	},
	
	function ThinkMolotov_OnEntityThink()
	{
		if(this.ent == null || !this.ent.IsEntityValid())
			return;
		
		if(this.ent.GetDistanceToGround() <= 25.0)
		{
			::BotGrenade.CreateFlame(this.ent.GetLocation(), this.ent.GetNetPropEntity("m_hThrower"));
			this.ent.AddThinkFunction(null);
			this.ent.Kill();
			
			printl("a molotov explode");
			return;
		}
		
		this.ent.SetAngles(::BotGrenade.GetRandomAngles());
		this.ent.SetNextThinkTime(Time() + 0.1);
	},
	
	function ThinkPipeBomb_OnEntityThink()
	{
		if(this.ent == null || !this.ent.IsEntityValid())
			return;
		
		local time = Time();
		if(this.ent.GetNetPropFloat("m_flNextAttack") <= time)
		{
			::BotGrenade.CreateExplode(this.ent.GetLocation(), this.ent.GetNetPropEntity("m_hThrower"));
			this.ent.AddThinkFunction(null);
			this.ent.Kill();
			
			// FireGameEvent("hegrenade_detonate", {userid = this.ent.GetNetPropEntity("m_hThrower").GetUserID()});
			
			printl("a pipe_bomb explode");
			return;
		}
		
		if(this.ent.GetNetPropFloat("m_flDamage") <= time)
		{
			this.ent.EmitSound("weapons/hegrenade/beep.wav");
			local beepTime = this.ent.GetNetPropFloat("m_DmgRadius") - ::BotGrenade.PipeBomb_BeepDelta;
			if(beepTime < ::BotGrenade.PipeBomb_BeepMin)
				beepTime = ::BotGrenade.PipeBomb_BeepMin;
			
			this.ent.SetNetPropFloat("m_DmgRadius", beepTime);
			this.ent.SetNetPropFloat("m_flDamage", time + beepTime);
		}
		
		// this.ent.SetAngles(::BotGrenade.GetRandomAngles());
		this.ent.SetNextThinkTime(time + 0.1);
	},
	
	function ThinkVomitjar_OnEntityThink()
	{
		if(this.ent == null || !this.ent.IsEntityValid())
			return;
		
		if(this.ent.GetDistanceToGround() <= 25.0)
		{
			::BotGrenade.CreateVomitjarEffect(this.ent.GetLocation(), 125, this.ent.GetIndex());
			this.ent.AddThinkFunction(null);
			this.ent.Kill();
			
			printl("a vomitjar explode");
			return;
		}
		
		this.ent.SetAngles(::BotGrenade.GetRandomAngles());
		this.ent.SetNextThinkTime(Time() + 0.1);
	},
	
	function ThinkGrenade_OnEntityThink()
	{
		if(this.ent == null || !this.ent.IsEntityValid())
			return;
		
		// 落地爆炸
		if(this.ent.GetDistanceToGround() <= 25.0)
		{
			::BotGrenade.CreateExplode(this.ent.GetLocation(), this.ent.GetNetPropEntity("m_hThrower"));
			this.ent.AddThinkFunction(null);
			this.ent.Kill();
			
			printl("a grenade explode");
			return;
		}
		
		this.ent.SetAngles(::BotGrenade.GetRandomAngles());
		this.ent.SetNextThinkTime(Time() + 0.1);
	},
	
	function ThinkGrenade_OnEntityTouch()
	{
		local entity = Utils.GetEntityOrPlayer(this.caller);
		if(entity == null || !entity.IsEntityValid())
			return;
		
		// 碰到玩家就爆炸
		::BotGrenade.CreateExplode(entity.GetLocation(), entity.GetNetPropEntity("m_hThrower"));
		entity.DisconnectOutput("OnPlayerTouch", "vslib_grenade_touch");
		entity.Kill();
		
		return;
	},
	
	function CreateGrenade(player, velocity = 300.0)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead())
			return null;
		
		local entity = Utils.SpawnEntity("grenade_launcher_projectile", "vslib_grenade_" + player.GetIndex(),
			player.GetEyePosition(), player.GetEyeAngles());
		
		if(entity == null || !entity.IsEntityValid())
			return null;
		
		entity.SetGravity(0.4);
		// entity.SetFriction(1.0);
		// entity.SetMoveType(MOVETYPE_VPHYSICS);
		entity.SetNetPropEntity("m_hOwnerEntity", player);
		entity.SetNetPropEntity("m_hThrower", player);
		entity.SetNetPropInt("m_bIsLive", 1);
		entity.SetNetPropInt("m_iTeamNum", player.GetTeam());
		// entity.SetNetPropFloat("m_flDamage", 15);
		// entity.SetNetPropFloat("m_DmgRadius", 300);
		entity.SetNetPropFloat("m_flElasticity", 0.0);
		
		entity.SetModel("models/w_models/weapons/w_HE_grenade.mdl");
		// entity.AttachParticle("RPG_Parent", 16.0);
		// entity.AttachParticle("flare_burning", 16.0);
		entity.SetVelocity(player.GetEyeAngles().Forward().Scale(velocity));
		entity.AddThinkFunction(::BotGrenade.ThinkGrenade_OnEntityThink);
		entity.ConnectOutput("OnPlayerTouch", ::BotGrenade.ThinkGrenade_OnEntityTouch, "vslib_grenade_touch");
		entity.SetNextThinkTime(Time() + 0.1);
		
		printl("a grenade created by " + player.GetName());
	},
	
	function CreateMolotov(player, velocity = 300.0)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead())
			return null;
		
		local entity = Utils.SpawnEntity("molotov_projectile", "vslib_molotov_" + player.GetIndex(),
			player.GetEyePosition(), player.GetEyeAngles());
		
		if(entity == null || !entity.IsEntityValid())
			return null;
		
		entity.SetGravity(0.75);
		// entity.SetFriction(1.0);
		// entity.SetMoveType(MOVETYPE_VPHYSICS);
		entity.SetNetPropEntity("m_hOwnerEntity", player);
		entity.SetNetPropEntity("m_hThrower", player);
		entity.SetNetPropInt("m_bIsLive", 1);
		entity.SetNetPropInt("m_iTeamNum", player.GetTeam());
		// entity.SetNetPropFloat("m_flDamage", 15);
		// entity.SetNetPropFloat("m_DmgRadius", 300);
		entity.SetNetPropFloat("m_flElasticity", 0.0);
		
		entity.SetModel("models/w_models/weapons/w_eq_molotov.mdl");
		entity.SetVelocity(player.GetEyeAngles().Forward().Scale(velocity));
		entity.AddThinkFunction(::BotGrenade.ThinkMolotov_OnEntityThink);
		entity.SetNextThinkTime(Time() + 0.1);
		
		// FireGameEvent("molotov_thrown", {userid = player.GetUserID()});
		
		player.SetNetPropInt("m_checkpointMolotovsUsed", player.GetNetPropInt("m_checkpointMolotovsUsed") + 1);
		printl("a molotov created by " + player.GetName());
	},
	
	function CreatePipeBomb(player, velocity = 300.0)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead())
			return null;
		
		local entity = Utils.SpawnEntity("pipe_bomb_projectile", "vslib_pipebomb_" + player.GetIndex(),
			player.GetEyePosition(), player.GetEyeAngles());
		
		if(entity == null || !entity.IsEntityValid())
			return null;
		
		entity.SetGravity(0.75);
		// entity.SetFriction(1.0);
		// entity.SetMoveType(MOVETYPE_VPHYSICS);
		entity.SetNetPropEntity("m_hOwnerEntity", player);
		entity.SetNetPropEntity("m_hThrower", player);
		entity.SetNetPropInt("m_bIsLive", 1);
		entity.SetNetPropFloat("m_flNextAttack", Time() + Convars.GetFloat("pipe_bomb_timer_duration"));
		entity.SetNetPropInt("m_iTeamNum", player.GetTeam());
		entity.SetNetPropFloat("m_flDamage", Time() + Convars.GetFloat("pipe_bomb_initial_beep_interval"));
		entity.SetNetPropFloat("m_DmgRadius", Convars.GetFloat("pipe_bomb_initial_beep_interval"));
		entity.SetNetPropFloat("m_flElasticity", 0.0);
		
		::BotGrenade.PipeBomb_BeepDelta = Convars.GetFloat("pipe_bomb_beep_interval_delta");
		::BotGrenade.PipeBomb_BeepMin = Convars.GetFloat("pipe_bomb_beep_min_interval");
		
		local chase = Utils.SpawnEntity("info_goal_infected_chase", "vslib_pipebomb_chase_" + entity.GetIndex(),
			entity.GetLocation(), entity.GetAngles());
		if(chase != null && chase.IsEntityValid())
		{
			entity.AttachOther(chase, true);
			chase.Input("Enable");
		}
		
		entity.SetModel("models/w_models/weapons/w_eq_pipebomb.mdl");
		entity.AttachParticle("weapon_pipebomb_blinking_light", Convars.GetFloat("pipe_bomb_timer_duration"));
		entity.AttachParticle("weapon_pipebomb_fuse", Convars.GetFloat("pipe_bomb_timer_duration"));
		entity.SetVelocity(player.GetEyeAngles().Forward().Scale(velocity));
		entity.AddThinkFunction(::BotGrenade.ThinkPipeBomb_OnEntityThink);
		entity.SetNextThinkTime(Time() + 0.1);
		
		player.SetNetPropInt("m_checkpointPipebombsUsed", player.GetNetPropInt("m_checkpointPipebombsUsed") + 1);
		printl("a pipe_bomb created by " + player.GetName());
	},
	
	function CreateVomitjar(player, velocity = 300.0)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead())
			return null;
		
		local entity = Utils.SpawnEntity("vomitjar_projectile", "vslib_vomitjar_" + player.GetIndex(),
			player.GetEyePosition(), player.GetEyeAngles());
		
		if(entity == null || !entity.IsEntityValid())
			return null;
		
		entity.SetGravity(0.4);
		// entity.SetFriction(1.0);
		// entity.SetMoveType(MOVETYPE_VPHYSICS);
		entity.SetNetPropEntity("m_hOwnerEntity", player);
		entity.SetNetPropEntity("m_hThrower", player);
		entity.SetNetPropInt("m_bIsLive", 1);
		entity.SetNetPropInt("m_iTeamNum", player.GetTeam());
		// entity.SetNetPropFloat("m_flNextAttack", Time() + 16.0);
		// entity.SetNetPropFloat("m_flDamage", 15);
		// entity.SetNetPropFloat("m_DmgRadius", 300);
		
		entity.SetModel("models/w_models/weapons/w_eq_bile_flask.mdl");
		entity.SetVelocity(player.GetEyeAngles().Forward().Scale(velocity));
		entity.AddThinkFunction(::BotGrenade.ThinkVomitjar_OnEntityThink);
		entity.SetNextThinkTime(Time() + 0.1);
		
		player.SetNetPropInt("m_checkpointBoomerBilesUsed", player.GetNetPropInt("m_checkpointBoomerBilesUsed") + 1);
		printl("a vomitjar created by " + player.GetName());
	},
	
	function GetGrenadeThrowSound(player, grenade)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead() || player.GetTeam() != SURVIVORS)
			return "";
		
		local character = player.GetSurvivorCharacter();
		switch(character)
		{
			case 0:
				switch(grenade)
				{
					case 1:
						return "scenes/gambler/grenade03.vcd";
					case 2:
						return "scenes/gambler/grenade01.vcd";
					case 4:
						return "scenes/gambler/boomerjar08.vcd";
				}
				break;
			case 1:
				switch(grenade)
				{
					case 1:
						return "scenes/producer/grenade03.vcd";
					case 2:
						return "scenes/producer/grenade01.vcd";
					case 4:
						return "scenes/producer/boomerjar08.vcd";
				}
				break;
			case 2:
				switch(grenade)
				{
					case 1:
						return "scenes/coach/grenade03.vcd";
					case 2:
						return "scenes/coach/grenade02.vcd";
					case 4:
						return "scenes/coach/boomerjar09.vcd";
				}
				break;
			case 3:
				switch(grenade)
				{
					case 1:
						return "scenes/mechanic/grenade03.vcd";
					case 2:
						return "scenes/mechanic/grenade05.vcd";
					case 4:
						return "scenes/mechanic/boomerjar09.vcd";
				}
				break;
			case 4:
				return "scenes/namvet/grenade02.vcd";
			case 5:
				return "scenes/teengirl/grenade02.vcd";
			case 6:
				return "scenes/biker/grenade02.vcd";
			case 7:
				return "scenes/manager/grenade02.vcd";
		}
		
		return "";
	},
	
	function TryThrowGrenade(player, flags, remove = false)
	{
		if(player == null || !player.IsPlayerEntityValid() || player.IsDead())
			return false;
		
		local inv = player.GetHeldItems();
		if(!("slot2" in inv) || inv["slot2"] == null || !inv["slot2"].IsEntityValid())
			return false;
		
		local classname = inv["slot2"].GetClassname();
		if(classname == "weapon_molotov" && !(flags & 1) ||
			classname == "weapon_pipe_bomb" && !(flags & 2) ||
			classname == "weapon_vomitjar" && !(flags & 4))
			return false;
		
		/*
		local grenade = 0;
		switch(classname)
		{
			case "weapon_molotov":
				::BotGrenade.CreateMolotov(player, Convars.GetFloat("player_throwforce"));
				if(remove)
					inv["slot2"].Kill();
				
				grenade = 1;
				break;
			case "weapon_pipe_bomb":
				::BotGrenade.CreatePipeBomb(player, Convars.GetFloat("player_throwforce"));
				if(remove)
					inv["slot2"].Kill();
				
				grenade = 2;
				break;
			case "weapon_vomitjar":
				::BotGrenade.CreateVomitjar(player, Convars.GetFloat("player_throwforce"));
				if(remove)
					inv["slot2"].Kill();
				
				grenade = 4;
				break;
			default:
				return false;
		}
		
		local snd = ::BotGrenade.GetGrenadeThrowSound(player, grenade);
		if(snd != "")
		{
			local entity = Utils.SpawnEntity("instanced_scripted_scene", "vslib_grenade_scene_" + grenade,
				Vector(0, 0, 0), QAngle(0, 0, 0), {SceneFile = snd});
			if(entity == null || !entity.IsEntityValid())
				return true;
			
			entity.SetNetPropEntity("m_hOwner", player);
			entity.Input("Start");
			entity.Input("Kill", "", 9);
		}
		*/
		
		if(player.GetActiveWeapon() != inv["slot2"])
		{
			player.SwitchWeapon(classname);
			printl("bot " + player.GetName() + " switch to " + classname);
		}
		
		player.ForceButton(BUTTON_ATTACK);
		Timers.AddTimerByName("botgrenade_" + player.GetIndex(), 1.0, false, ::BotGrenade.Timer_StopFire, player, 0, { "action" : "reset" });
		printl("bot " + player.GetName() + " throwing " + classname);
		return true;
	},
	
	function Timer_StopFire(player)
	{
		if(player == null || !player.IsSurvivor())
			return;
		
		player.UnforceButton(BUTTON_ATTACK);
	},
	
	function GetNumMobs()
	{
		local counter = 0;
		foreach(infected in Zombies.CommonInfected())
			if(infected.GetNetPropBool("m_mobRush") && !infected.GetNetPropBool("m_bIsBurning"))
				counter += 1;
		
		return counter;
	},
	
	function GetNearNumMobs(origin)
	{
		local counter = 0;
		foreach(infected in Objects.OfClassnameWithin("infected", origin, ::BotGrenade.ConfigVar.NearInfectedRadius))
			if(infected.GetNetPropBool("m_mobRush") && !infected.GetNetPropBool("m_bIsBurning"))
				counter += 1;
		
		return counter;
	},
	
	function TimerThrow_OnPlayerThink(params)
	{
		if(!::BotGrenade.ConfigVar.Enable)
			return;
		
		if(::BotGrenade.ConfigVar.ThrowTank != 0 && Utils.IsTankPresent())
		{
			foreach(player in Players.AliveSurvivorBots())
			{
				if(player.IsIncapacitated() /*&& ::BotGrenade.ConfigVar.IncapThrow == 0*/ || player.IsHangingFromLedge())
					continue;
				
				local aiming = player.GetLookingEntity();
				if(aiming == null || !aiming.IsPlayer() || !aiming.IsPlayerEntityValid() || aiming.GetType() != Z_TANK || aiming.IsOnFire())
					continue;
				
				if(::BotGrenade.TryThrowGrenade(player, ::BotGrenade.ConfigVar.ThrowTank, true))
					break;
				
				printl("bots " + player.GetName() + " throw grenade to tank");
			}
		}
		
		/*
		if(::BotGrenade.ConfigVar.IncapThrow != 0)
		{
			foreach(player in Players.IncapacitatedSurvivors())
			{
				if(!player.IsPressingZoom())
					continue;
				
				::BotGrenade.TryThrowGrenade(player, ::BotGrenade.ConfigVar.IncapThrow, true);
				printl("player " + player.GetName() + " throw grenade of incap");
			}
		}
		*/
		
		local numMobs = ::BotGrenade.GetNumMobs();
		local withMobThrow = (::BotGrenade.ConfigVar.AutoThrowWithCommon > 0 && ::BotGrenade.ConfigVar.AutoThrowWithCommon <= numMobs);
		if(withMobThrow || (::BotGrenade.ConfigVar.AutoThrowWithNear > 0 && ::BotGrenade.ConfigVar.AutoThrowWithNear <= numMobs))
		{
			foreach(player in Players.AliveSurvivorBots())
			{
				if(player.IsIncapacitated() /*&& ::BotGrenade.ConfigVar.IncapThrow == 0*/ || player.IsHangingFromLedge())
					continue;
				
				if(withMobThrow && ::BotGrenade.TryThrowGrenade(player, 6, true))
				{
					printl("bots " + player.GetName() + " throw grenade with " + numMobs + " mobs");
					break;
				}
				
				local nearMobs = ::BotGrenade.GetNearNumMobs(player.GetLocation());
				if(::BotGrenade.ConfigVar.AutoThrowWithNear > 0 && ::BotGrenade.ConfigVar.AutoThrowWithNear <= nearMobs && ::BotGrenade.TryThrowGrenade(player, 6, true))
				{
					printl("bots " + player.GetName() + " throw grenade with near " + nearMobs + " mobs");
					break;
				}
			}
		}
	},
	
	function TimerThrow_OnPaincEvent(params)
	{
		if(::BotGrenade.ConfigVar.PanicThrow == 0)
			return;
		
		foreach(player in Players.AliveSurvivorBots())
		{
			if(::BotGrenade.TryThrowGrenade(player, ::BotGrenade.ConfigVar.PanicThrow, true))
				break;
		}
	},
	
	function TimerThrow_OnVomitAttached(params)
	{
		if(::BotGrenade.ConfigVar.VomitThrow == 0)
			return;
		
		foreach(player in Players.AliveSurvivorBots())
		{
			if(::BotGrenade.TryThrowGrenade(player, ::BotGrenade.ConfigVar.VomitThrow, true))
				break;
		}
	},
	
	function TimerThrow_OnWitchFrightened(params)
	{
		if(::BotGrenade.ConfigVar.HarasserThrow == 0)
			return;
		
		foreach(player in Players.AliveSurvivorBots())
		{
			if(player.IsIncapacitated() /*&& ::BotGrenade.ConfigVar.IncapThrow == 0*/ || player.IsHangingFromLedge())
				continue;
			
			local aiming = player.GetLookingEntity();
			try
			{
				if(aiming == null || !aiming.IsValid() || aiming.GetType() != Z_WITCH ||
					aiming.GetIndex() != params)
					continue;
			}
			catch(err)
			{
				printl("TimerThrow_OnWitchFrightened error " + err);
				continue;
			}
			
			if(::BotGrenade.TryThrowGrenade(player, ::BotGrenade.ConfigVar.HarasserThrow, true))
				break;
		}
	}
};

function Notifications::OnRoundBegin::BotGrenadeUse(params)
{
	Timers.AddTimerByName("timer_botthrow", 2.0, true, ::BotGrenade.TimerThrow_OnPlayerThink);
}

function Notifications::FirstSurvLeftStartArea::BotGrenadeUse(player, params)
{
	Timers.AddTimerByName("timer_botthrow", 2.0, true, ::BotGrenade.TimerThrow_OnPlayerThink);
}

function Notifications::OnPanicEvent::BotGrenadeThrow(player, params)
{
	Timers.AddTimerByName("timer_botthrow_paincevent", 9.0, false, ::BotGrenade.TimerThrow_OnPaincEvent);
	printl("bots throw grenade by painc event");
}

function Notifications::OnPlayerVomited::BotGrenadeThrow(victim, attacker, params)
{
	if(victim == null || !victim.IsPlayerEntityValid() || victim.GetTeam() != SURVIVORS)
		return;
	
	Timers.AddTimerByName("timer_botthrow_vomit", 5.0, false, ::BotGrenade.TimerThrow_OnVomitAttached);
	printl("bots throw grenade by vomit event");
}

function Notifications::OnWitchStartled::BotGrenadeThrow(witch, player, params)
{
	if(player == null || !player.IsPlayerEntityValid() || player.GetTeam() != SURVIVORS)
		return;
	
	Timers.AddTimerByName("timer_botthrow_witch", 3.0, false, ::BotGrenade.TimerThrow_OnWitchFrightened,
		witch.GetIndex());
	
	printl("bots throw grenade by witch");
}

function Notifications::OnWeaponFire::BotGrenade_StopFire(player, classname, params)
{
	if(!::BotGrenade.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsSurvivor())
		return;
	
	if("weaponid" in params && (params["weaponid"] == 13 || params["weaponid"] == 14 || params["weaponid"] == 25))
		player.UnforceButton(BUTTON_ATTACK);
}

function Notifications::OnMolotovThrown::BotGrenade_StopFire(player, params)
{
	if(!::BotGrenade.ConfigVar.Enable)
		return;
	
	if(player == null || !player.IsSurvivor())
		return;
	
	player.UnforceButton(BUTTON_ATTACK);
}

function CommandTriggersEx::throwgrenade(player, arg, fullText)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	local type = GetArgument(1);
	if(type == null || type == "")
	{
		::BotGrenade.TryThrowGrenade(player, 7, false);
		return;
	}
	
	if(type == "1" || type == "molotov" || type == "fire")
		::BotGrenade.CreateMolotov(player, Convars.GetFloat("player_throwforce"));
	else if(type == "2" || type == "pipebomb" || type == "pipe")
		::BotGrenade.CreatePipeBomb(player, Convars.GetFloat("player_throwforce"));
	else if(type == "3" || type == "vomitjar" || type == "bile")
		::BotGrenade.CreateVomitjar(player, Convars.GetFloat("player_throwforce"));
	else if(type == "4" || type == "grenade")
		::BotGrenade.CreateGrenade(player, Convars.GetFloat("player_throwforce"));
	else
		player.PrintToChat("invalid params. only molotov, pipebomb, vomitjar, grenade");
}

function CommandTriggersEx::botthrow(player, arg, fullText)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	local survivor = GetArgument(1);
	local target = Utils.GetPlayerFromName(survivor);
	
	if(survivor != null)
	{
		if(survivor == "all")
		{
			foreach(bots in Players.AliveSurvivorBots())
				::BotGrenade.TryThrowGrenade(bots, 7, true);
		}
		else if(survivor == "!picker")
		{
			target = player.GetLookingEntity();
			if(target == null || !target.IsSurvivor() || !target.IsAlive())
				return;
			
			::BotGrenade.TryThrowGrenade(target, 7, true);
		}
		else
		{
			if(target == null)
				return;
			
			::BotGrenade.TryThrowGrenade(target, 7, true);
		}
	}
	else
	{
		::BotGrenade.TryThrowGrenade(player, 7, true);
	}
}


::BotGrenade.PLUGIN_NAME <- PLUGIN_NAME;
::BotGrenade.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::BotGrenade.ConfigVarDef);

function Notifications::OnRoundStart::BotGrenade_LoadConfig()
{
	RestoreTable(::BotGrenade.PLUGIN_NAME, ::BotGrenade.ConfigVar);
	if(::BotGrenade.ConfigVar == null || ::BotGrenade.ConfigVar.len() <= 0)
		::BotGrenade.ConfigVar = FileIO.GetConfigOfFile(::BotGrenade.PLUGIN_NAME, ::BotGrenade.ConfigVarDef);

	// printl("[plugins] " + ::BotGrenade.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::BotGrenade_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::BotGrenade.PLUGIN_NAME, ::BotGrenade.ConfigVar);

	// printl("[plugins] " + ::BotGrenade.PLUGIN_NAME + " saving...");
}
