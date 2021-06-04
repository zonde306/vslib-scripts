::TrapSystem <-
{
	ConfigVarDef =
	{
		// 是否开启插件
		Enable = true,

		// 开启插件的模式.0=禁用.1=合作.2=写实.4=生存.8=对抗.16=清道夫
		EnableMode = 31,

		// 可以用于安装陷阱的东西.1=油桶.2=煤气罐.4=氧气瓶.8=烟花盒
		AllowObject = 15,

		// 安装陷阱需要多少秒
		SetupDuration = 3,

		// 陷阱安装后启动需要多少秒(防止一安装完就爆炸)
		SetupDelay = 3,

		// 安装好的陷阱是否允许被破坏(直接攻击)
		AllowDestroy = false,

		// 触发陷阱的范围
		TriggerRadius = 100,

		// 会触发陷阱的物体.1=生还者.2=特感.4=普感.8=Witch.16=Tank
		TriggerVictim = 30
	},

	ConfigVar = {},

	TrapOwner = {},
	TrapObject = {},
	SetupStatus = {},
	SetupTimer = {},
	StartTimer = {},
	
	// 设置进度条
	function SetProgressBarTime(player, time = 0.0)
	{
		if(player == null || !player.IsPlayerEntityValid())
			return;
		
		player.SetNetPropFloat("m_flProgressBarStartTime", Time());
		player.SetNetPropFloat("m_flProgressBarDuration", time);
	},
	
	function TrapThink_FindVictim()
	{
		if(this.ent == null || !this.ent.IsEntityValid())
			return;
		
		local index = this.ent.GetIndex();
		if(index in ::TrapSystem.StartTimer && ::TrapSystem.StartTimer[index] > Time())
		{
			this.ent.SetNextThinkTime(Time() + 0.1);
			return;
		}
		
		if(index in ::TrapSystem.StartTimer)
		{
			delete ::TrapSystem.StartTimer[index];
			printl("trap " + this.ent.GetClassname() + " active");
		}
		
		local position = this.ent.GetLocation();
		foreach(enemy in Objects.AroundRadius(position, ::TrapSystem.ConfigVar.TriggerRadius))
		{
			local type = enemy.GetType();
			if(Utils.CalculateDistance(enemy.GetLocation(), position) > ::TrapSystem.ConfigVar.TriggerRadius || type == null)
				continue;
			
			if((type == Z_SURVIVOR && (::TrapSystem.ConfigVar.TriggerVictim & 1)) ||
				((type == Z_COMMON || type == Z_MOB) && (::TrapSystem.ConfigVar.TriggerVictim & 2)) ||
				(type >= Z_SMOKER && type <= Z_CHARGER && (::TrapSystem.ConfigVar.TriggerVictim & 4)) ||
				((type == Z_WITCH || type == Z_WITCH_BRIDE) && (::TrapSystem.ConfigVar.TriggerVictim & 8)) ||
				(type == Z_TANK && (::TrapSystem.ConfigVar.TriggerVictim & 16)))
			{
				this.ent.SetNetPropInt("m_takedamage", 2);
				local owner = this.ent.GetOwnerEntity();
				local index = this.ent.GetIndex();
				
				if(index in ::TrapSystem.TrapOwner)
				{
					owner = ::TrapSystem.TrapOwner[index];
					if(owner != null && owner.IsPlayerEntityValid() && owner.GetIndex() in ::TrapSystem.TrapObject)
						delete ::TrapSystem.TrapObject[owner.GetIndex()];
					
					delete ::TrapSystem.TrapOwner[index];
				}
				
				this.ent.Damage(32, DMG_BURN, owner);
				this.ent.Input("Break", "", 0, owner);
				this.ent.AddThinkFunction(null);
				printl("trap " + this.ent.GetClassname() + " trigged.");
				
				return;
			}
		}
		
		this.ent.SetNextThinkTime(Time() + 0.1);
	},
	
	function StopSetupTrap(player)
	{
		if(player == null || !player.IsPlayerEntityValid())
			return false;
		
		local index = player.GetIndex();
		if(index in ::TrapSystem.SetupStatus)
		{
			delete ::TrapSystem.SetupStatus[index];
			::TrapSystem.SetProgressBarTime(player);
		}
		
		if(index in ::TrapSystem.SetupTimer)
			delete ::TrapSystem.SetupTimer[index];
		
		if(index in ::TrapSystem.TrapObject)
		{
			if(::TrapSystem.TrapObject[index] != null && ::TrapSystem.TrapObject[index].IsEntityValid() &&
				::TrapSystem.TrapObject[index].GetIndex() in ::TrapSystem.TrapOwner)
				delete ::TrapSystem.TrapOwner[::TrapSystem.TrapObject[index].GetIndex()];
			
			delete ::TrapSystem.TrapObject[index];
		}
		
		return true;
	}
	
	function SetupTrap(entity, owner)
	{
		if(entity == null || !entity.IsEntityValid())
			return false;
		
		local classname = entity.GetClassname();
		if(classname != "weapon_gascan" && classname != "weapon_propanetank" &&
			classname != "weapon_oxygentank" && classname != "weapon_fireworkcrate")
			return false;
		
		local index = entity.GetIndex();
		entity = Utils.ConvertEntity(entity, "prop_physics",
			{physdamagescale = 0.0, model = entity.GetModel(), spawnflags = 1548});
		if(entity == null || !entity.IsEntityValid())
		{
			printl("create a trap fail");
			return false;
		}
		
		entity.SetLocation(entity.GetLocationBelow());
		entity.SetMoveType(MOVETYPE_NONE);
		entity.SetRenderMode(RENDER_TRANSCOLOR);
		entity.SetRenderEffects(RENDERFX_PULSE_SLOW);
		entity.SetColor(::TrapSystem.ConfigVar.SetupColor & 0xFF, (::TrapSystem.ConfigVar.SetupColor & 0xFF00) >> 8,
			(::TrapSystem.ConfigVar.SetupColor & 0xFF0000) >> 16, (::TrapSystem.ConfigVar.SetupColor & 0xFF000000) >> 24);
		
		entity.Input("DisableCollision");		// 禁止碰撞
		entity.Input("DisableShadow");			// 禁用阴影
		entity.Input("DisableMotion");			// 禁止触摸
		entity.Input("DisableFloating");		// 禁止在水里浮起来
		entity.Input("DisablePuntSound");		// 禁止被攻击时发出声音
		// entity.SetNetPropInt("m_Collision.m_nSolidType", 0);
		// entity.SetNetPropInt("m_Collision.m_usSolidFlags", 4);
		entity.SetKeyValue("solid", 0);
		entity.SetNetPropInt("m_Glow.m_iGlowType", 0);
		entity.SetNetPropInt("m_Glow.m_nGlowRange", 0);
		entity.SetNetPropInt("m_Glow.m_glowColorOverride", 0);
		entity.SetNetPropInt("m_takedamage", (::TrapSystem.ConfigVar.AllowDestroy ? 2 : 0));
		::TrapSystem.StartTimer[entity.GetIndex()] <- Time() + ::TrapSystem.ConfigVar.SetupDelay;
		entity.AddThinkFunction(::TrapSystem.TrapThink_FindVictim);
		
		if(owner != null && owner.IsPlayerEntityValid())
		{
			::TrapSystem.TrapObject[owner.GetIndex()] <- entity;
			::TrapSystem.TrapOwner[entity.GetIndex()] <- owner;
			entity.SetLocation(owner.GetLocation());
			
			printl("player " + owner.GetName() + " setup trap");
		}
	},
	
	function Timer_OnPlayerThink(params)
	{
		if(!::TrapSystem.ConfigVar.Enable)
			return;
		
		local time = Time();
		foreach(player in Players.AliveSurvivors())
		{
			if(!player.IsPressingZoom() || player.IsIncapacitated() || player.IsHangingFromLedge() ||
				player.GetCurrentAttacker() != null || player.IsPressingUse() || player.GetMoveType() == MOVETYPE_LADDER)
			{
				::TrapSystem.StopSetupTrap(player);
				continue;
			}
			
			local index = player.GetIndex();
			local weapon = (index in ::TrapSystem.TrapObject ? ::TrapSystem.TrapObject[index] : player.GetActiveWeapon());
			local classname = (weapon != null && weapon.IsEntityValid() ? weapon.GetClassname() : "");
			if(classname == "" || !((classname == "weapon_gascan" && (::TrapSystem.ConfigVar.AllowObject & 1)) ||
				(classname == "weapon_propanetank" && (::TrapSystem.ConfigVar.AllowObject & 2)) ||
				(classname == "weapon_oxygentank" && (::TrapSystem.ConfigVar.AllowObject & 4)) ||
				(classname == "weapon_fireworkcrate" && (::TrapSystem.ConfigVar.AllowObject & 8))) ||
				weapon.GetNetPropInt("m_nSkin") != 0)
			{
				::TrapSystem.StopSetupTrap(player);
				continue;
			}
			
			if(!(index in ::TrapSystem.SetupStatus) || ::TrapSystem.SetupStatus[index] <= 0)
			{
				::TrapSystem.SetupStatus[index] <- 1;
				::TrapSystem.SetupTimer[index] <- time + ::TrapSystem.ConfigVar.SetupDuration;
				::TrapSystem.SetProgressBarTime(player, ::TrapSystem.ConfigVar.SetupDuration);
				
				printl("player " + player.GetName() + " start setup trap");
			}
			else if(::TrapSystem.SetupStatus[index] == 1 && ::TrapSystem.SetupTimer[index] <= time)
			{
				delete ::TrapSystem.SetupTimer[index];
				::TrapSystem.SetupStatus[index] <- 2;
				::TrapSystem.TrapObject[index] <- weapon;
				::TrapSystem.TrapOwner[weapon.GetIndex()] <- player;
				::TrapSystem.SetProgressBarTime(player);
				player.Drop(classname);
				
				printl("player " + player.GetName() + " drop trap");
			}
			else if(::TrapSystem.SetupStatus[index] == 2)
			{
				delete ::TrapSystem.SetupStatus[index];
				delete ::TrapSystem.TrapObject[index];
				delete ::TrapSystem.TrapOwner[weapon.GetIndex()];
				::TrapSystem.SetupTrap(weapon, player);
				::TrapSystem.SetProgressBarTime(player);
				
				printl("player " + player.GetName() + " finish setup trap");
			}
		}
	}
}

function Notifications::OnRoundBegin::Trap_StartTimer(params)
{
	Timers.AddTimerByName("timer_trapsetup", 0.1, true, ::TrapSystem.Timer_OnPlayerThink);
}

function Notifications::FirstSurvLeftStartArea::Trap_StartTimer(player, params)
{
	Timers.AddTimerByName("timer_trapsetup", 0.1, true, ::TrapSystem.Timer_OnPlayerThink);
}

/*
function Notifications::CanPickupObject::Trap_BlockPickup(entity, classname)
{
	if(entity == null || !entity.IsEntityValid())
		return true;
	
	local index = entity.GetIndex();
	if(index in ::TrapSystem.TrapOwner)
	{
		if(::TrapSystem.TrapOwner[index] == null || !::TrapSystem.TrapOwner[index].IsPlayerEntityValid())
		{
			delete ::TrapSystem.TrapOwner[index];
			return true;
		}
		
		return false;
	}
	
	return true;
}
*/


::TrapSystem.PLUGIN_NAME <- PLUGIN_NAME;
::TrapSystem.ConfigVar = FileIO.GetConfigOfFile(PLUGIN_NAME, ::TrapSystem.ConfigVarDef);

function Notifications::OnRoundStart::TrapSystem_LoadConfig()
{
	RestoreTable(::TrapSystem.PLUGIN_NAME, ::TrapSystem.ConfigVar);
	if(::TrapSystem.ConfigVar == null || ::TrapSystem.ConfigVar.len() <= 0)
		::TrapSystem.ConfigVar = FileIO.GetConfigOfFile(::TrapSystem.PLUGIN_NAME, ::TrapSystem.ConfigVarDef);

	// printl("[plugins] " + ::TrapSystem.PLUGIN_NAME + " loading...");
}

function EasyLogic::OnShutdown::TrapSystem_SaveConfig(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::TrapSystem.PLUGIN_NAME, ::TrapSystem.ConfigVar);

	// printl("[plugins] " + ::TrapSystem.PLUGIN_NAME + " saving...");
}
