Msg("Bot AI Activated\n");
// IncludeScript("VSLib");
::g_OnBotUpdateScript <- this;

/*
Convars.SetValue( "sv_consistency", 0 );
Convars.SetValue( "sb_max_team_melee_weapons", 1 );
Convars.SetValue( "sb_melee_approach_victim", 999 );
Convars.SetValue( "sb_allow_leading", 1 );
Convars.SetValue( "sb_all_bot_game", 1 );
Convars.SetValue( "allow_all_bot_survivor_team", 1 );
Convars.SetValue( "sb_battlestation_human_hold_time", 2 );
Convars.SetValue( "sb_sidestep_for_horde", 1 );
Convars.SetValue( "sb_toughness_buffer", 30 );
//Convars.SetValue( "sb_temp_health_consider_factor", 0.75 );
Convars.SetValue( "sb_friend_immobilized_reaction_time_normal", 0.1 );
Convars.SetValue( "sb_friend_immobilized_reaction_time_hard", 0.1 );
Convars.SetValue( "sb_friend_immobilized_reaction_time_expert", 0.1 );
Convars.SetValue( "sb_friend_immobilized_reaction_time_vs", 0.1 );
Convars.SetValue( "sb_separation_range", 75 );
Convars.SetValue( "sb_separation_danger_min_range", 75 );
Convars.SetValue( "sb_separation_danger_max_range", 300 );
Convars.SetValue( "sb_escort", 1 );
Convars.SetValue( "sb_transition", 0 );
Convars.SetValue( "sb_close_checkpoint_door_interval", 0.15 );
Convars.SetValue( "sb_max_battlestation_range_from_human", 200 );
Convars.SetValue( "sb_battlestation_give_up_range_from_human", 1200 );
Convars.SetValue( "sb_threat_very_close_range", 75 );
Convars.SetValue( "sb_close_threat_range", 120 );
Convars.SetValue( "sb_threat_close_range", 120 );
Convars.SetValue( "sb_threat_medium_range", 600 );
Convars.SetValue( "sb_threat_far_range", 1200 );
Convars.SetValue( "sb_threat_very_far_range", 2200 );
Convars.SetValue( "sb_neighbor_range", 120 );
Convars.SetValue( "sb_follow_stress_factor", 100 );
Convars.SetValue( "sb_locomotion_wait_threshold", 0 );
Convars.SetValue( "sb_path_lookahead_range", 1500 );
Convars.SetValue( "sb_near_hearing_range", 2500 );
Convars.SetValue( "sb_far_hearing_range", 4000 );
Convars.SetValue( "sb_combat_saccade_speed", 2250 );
Convars.SetValue( "sv_allow_point_servercommand", 1 );

//Convars.SetValue( "sb_force_max_intensity", "Coach" );
//Convars.SetValue( "sb_force_max_intensity", "Ellis" );
//Convars.SetValue( "sb_force_max_intensity", "Rochelle" );
//Convars.SetValue( "sb_force_max_intensity", "Nick" );
//Convars.SetValue( "sb_force_max_intensity", "Bill" );
//Convars.SetValue( "sb_force_max_intensity", "Louis" );
//Convars.SetValue( "sb_force_max_intensity", "Francis" );
//Convars.SetValue( "sb_force_max_intensity", "Zoey" );

Convars.SetValue( "survivor_calm_damage_delay", 0 );
Convars.SetValue( "survivor_calm_deploy_delay", 0 );
Convars.SetValue( "survivor_calm_no_flashlight", 0 );
Convars.SetValue( "survivor_calm_recent_enemy_delay", 0 );
Convars.SetValue( "survivor_calm_weapon_delay", 0 );
Convars.SetValue( "survivor_vision_range_obscured", 1500 );
Convars.SetValue( "survivor_vision_range", 3000 );
Convars.SetValue( "sb_normal_saccade_speed", 1500 );
Convars.SetValue( "sb_pushscale", 4 );
Convars.SetValue( "sb_debug_apoproach_wait_time", 0 );
Convars.SetValue( "sb_enforce_proximity_lookat_timeout", 0 );
Convars.SetValue( "sb_enforce_proximity_range", 10000 );
//Convars.SetValue( "sb_reachable_cache_paranoia", 0 );
Convars.SetValue( "sb_use_button_range", 1000 );
Convars.SetValue( "sb_max_scavenge_separation", 1500 );
Convars.SetValue( "sb_min_attention_notice_time", 0 );
//Convars.SetValue( "sb_reachability_cache_lifetime", 0 );
Convars.SetValue( "sb_rescue_vehicle_loading_range", 300 );
//Convars.SetValue( "sb_revive_friend_distance", 500 );
Convars.SetValue( "sb_threat_exposure_stop", 2147483646 );
Convars.SetValue( "sb_threat_exposure_walk", 2147483647 );
Convars.SetValue( "sb_vomit_blind_time", 0 );
*/

::IsGascanTargetHere <- false;
::UseTarget <- null;
::playerAmount <- 0;
::BotsNeedToFind <- "weapon_gascan";
::GasTryFind <- null;
::BotTab <- {};
::BotFindingNum <- -1;
::HasMathCount <- false;
::HasTank <- false;
::MapName <- " ";

::AllInfectedAmount <- 0;

::ThisSecWorked <- false;
::ThisFrameWorked <- false;
::ServerTime <- 0;
::ClientFrame <- 0;

::ANIM_WITCH_RUN_INTENSE <-    6
::ANIM_STANDING_CRYING <-      2


//Witch Ducking
::ANIM_SITTING_CRY <-          4
::ANIM_SITTING_STARTLED <-     27
::ANIM_SITTING_AGGRO <-        29

//Witch Walking
::ANIM_WALK <-                 10
::ANIM_WANDER_WALK <-    11

//Witch Killing
::ANIM_WITCH_WANDER_ACQUIRE <- 30
::ANIM_WITCH_KILLING_BLOW <-   31
::ANIM_WITCH_KILLING_BLOW_TWO <-   32

::ANIM_WITCH_RUN_ONFIRE <-     39

class ::BotLinkedGas
{
	constructor(botIn, gascanIn)
    {
        bot = botIn;
        gascan = gascanIn;
    }
	
	bot = null;
	gascan = null;
	gascanDead = false;
}

function BotLinkedGas::GetBot()
{
	return bot;
}

function BotLinkedGas::Clear()
{
	bot = null;
	gascan = null;
}

function BotLinkedGas::GetGasCan()
{
	return gascan;
}

function BotLinkedGas::IsGasDead()
{
	return gascanDead;
}

function searchEntity( args )
{
	player <- null;

	while(player = Entities.FindByClassname(player, "player"))
	{
		if(VSLib.Player(player).IsPlayerEntityValid() && player.IsSurvivor() && IsPlayerABot(player))
		{
			item <- null;
			while (Entities.FindInSphere(item, player.GetOrigin(), 150) != null) 
			{
				item = Entities.FindInSphere(item, player.GetOrigin(), 150);
				ename <- item.GetClassname();

				if(item.GetOwnerEntity() == null)
				{
					if ( ename == "weapon_upgradepack_incendiary_spawn" || ename == "weapon_upgradepack_explosive_spawn" || ename == "weapon_upgradepack_incendiary" || ename == "weapon_upgradepack_explosive")
					{
						DoEntFire("!self", "Use", "", 0, player, item);
						return;
					}
					
					haspill <- VSLib.Player(player).HasItem("pain_pills") || VSLib.Player(player).HasItem("adrenaline");
					if (!haspill && (ename == "weapon_pain_pills_spawn" || ename == "weapon_adrenaline_spawn" || ename == "weapon_pain_pills" || ename == "weapon_adrenaline"))
					{
						DoEntFire("!self", "Use", "", 0, player, item);
						return;
					}
					
					hasgen <- VSLib.Player(player).HasItem("pipe_bomb") || VSLib.Player(player).HasItem("molotov") || VSLib.Player(player).HasItem("vomitjar");
					if (!hasgen && (ename == "weapon_pipe_bomb_spawn" || ename == "weapon_molotov_spawn" || ename == "weapon_vomitjar_spawn" || ename == "weapon_pipe_bomb" || ename == "weapon_molotov" || ename == "weapon_vomitjar"))
					{
						if(NetProps.GetPropInt(item, "m_spawnflags") >= 8)
						{
							DoEntFire("!self", "Use", "", 0, player, item);
							return;
						}
						else 
						{
							if((ename == "weapon_pipe_bomb_spawn" || ename == "weapon_pipe_bomb") && item.GetName() != "botaipipebomb" )
							{
								item.Kill();
								player.GiveItem("pipe_bomb");
							}
							else if((ename == "weapon_molotov_spawn" || ename == "weapon_molotov") && item.GetHealth() < 1000)
							{
								item.Kill();
								player.GiveItem("molotov");
							}
							else if((ename == "weapon_vomitjar_spawn" || ename == "weapon_vomitjar") && item.GetHealth() < 1000)
							{
								item.Kill();
								player.GiveItem("vomitjar");
							}

							return;
						}
					}
					
					if (!VSLib.Player(player).HasItem("first_aid_kit") && (ename == "weapon_defibrillator_spawn" || ename == "weapon_defibrillator") )
					{
						doAmmoUpgrades(player);
						DoEntFire("!self", "Use", "", 0, player, item);
						return;
					}
				}
			}
		}
	}
}
	
function searchButton( args )
{
	notBotPlayer <- null;
	while(notBotPlayer = Entities.FindByClassname(notBotPlayer, "player"))
	{
		if(VSLib.Player(notBotPlayer).IsPlayerEntityValid() && notBotPlayer.IsSurvivor() && !IsPlayerABot(notBotPlayer) && NetProps.GetPropInt(notBotPlayer, "m_iTeamNum") != 1 && !notBotPlayer.IsDead())
		{
			return;
		}
	}

	player <- null;
	while(player = Entities.FindByClassname(player, "player"))
	{
		if(VSLib.Player(player).IsPlayerEntityValid() && player.IsSurvivor() && IsPlayerABot(player))
		{
			otherPlayer <- null;
			disFarAway <- false;
			while (otherPlayer = Entities.FindByClassname(otherPlayer, "player")) 
			{
				if(VSLib.Player(otherPlayer).IsPlayerEntityValid() && otherPlayer.IsSurvivor() && IsPlayerABot(otherPlayer) && !otherPlayer.IsDead())
				{
					if(distanceof(player.GetOrigin(), otherPlayer.GetOrigin()) > 150)
						disFarAway = true;
				}
			}
		
			item <- null;
			while (Entities.FindInSphere(item, player.GetOrigin(), 150) != null) 
			{
				item = Entities.FindInSphere(item, player.GetOrigin(), 150);
				ename <- item.GetClassname();

				if ( ename == "func_button")
				{
					printl("Try Press Button  " + ename);
					DoEntFire("!self", "Use", "", 2, player, item);
					if(!disFarAway)
					{
						DoEntFire("!self", "Unlock", "", 0, null, item);
						DoEntFire("!self", "Press", "", 2, player, item);
					}
					return;
				}
				
				if ( ename == "func_door" || ename == "func_door_rotating" || ename == "prop_door_rotating" )
				{
					printl("Try Unlock Door  " + ename);
					DoEntFire("!self", "Unlock", "", 0, null, item);
					DoEntFire("!self", "Open", "", 2, null, item);
					return;
				}
			}
		}
	}
}
	
function searchButtonTimed( args )
{
	notBotPlayer <- null;
	while(notBotPlayer = Entities.FindByClassname(notBotPlayer, "player"))
	{
		if(VSLib.Player(notBotPlayer).IsPlayerEntityValid() && notBotPlayer.IsSurvivor() && !IsPlayerABot(notBotPlayer) && NetProps.GetPropInt(notBotPlayer, "m_iTeamNum") != 1 && !notBotPlayer.IsDead())
		{
			return;
		}
	}

	player <- null;
	while(player = Entities.FindByClassname(player, "player"))
	{
		if(VSLib.Player(player).IsPlayerEntityValid() && player.IsSurvivor() && IsPlayerABot(player))
		{
			item <- null;
			while (Entities.FindInSphere(item, player.GetOrigin(), 150) != null) 
			{
				item = Entities.FindInSphere(item, player.GetOrigin(), 150);
				ename <- item.GetClassname();

				if (ename == "func_button_timed")
				{
					DoEntFire("!self", "Unlock", "", 0, null, item);
					item.__KeyValueFromInt("use_time", -1);
					DoEntFire("!self", "Use", "", 0, player, item);
					DoEntFire("!self", "Use", "", 0.01, player, item);
					DoEntFire("!self", "Use", "", 0.02, player, item);
					DoEntFire("!self", "Use", "", 0.03, player, item);
					DoEntFire("!self", "Use", "", 0.04, player, item);
					DoEntFire("!self", "Use", "", 0.06, player, item);
					DoEntFire("!self", "Use", "", 0.07, player, item);
					DoEntFire("!self", "Use", "", 0.08, player, item);
					DoEntFire("!self", "Use", "", 0.09, player, item);
					return;
				}
			}
		}
	}
}

function searchBody( args )
{
	player <- null;
	searchedBody <- null;
	local distance = 1800;
	while(player = Entities.FindByClassname(player, "player"))
	{
		if(VSLib.Player(player).IsPlayerEntityValid() && player.IsSurvivor() && IsPlayerABot(player) && !player.IsDead() && !VSLib.Player(player).IsInCombat())
		{
			body <- null;
			while(body = Entities.FindByClassname(body, "player"))
			{
				if(VSLib.Player(body).IsPlayerEntityValid() && body.IsSurvivor() && body.IsDead() && body != player)
				{
					deathBody <- null;
					while(deathBody = Entities.FindByClassname(deathBody, "survivor_death_model"))
					{
						if((searchedBody == null || distanceof(player.GetOrigin(), deathBody.GetOrigin()) < distance) && NetProps.GetPropInt(deathBody, "m_nCharacterType") != NetProps.GetPropInt(body, "m_survivorCharacter"))
							continue;
							
						searchedBody = deathBody;
						distance = distanceof(player.GetOrigin(), deathBody.GetOrigin());
					}

					if(searchedBody == null)
						continue;
					
					if(VSLib.Player(player).HasItem("defibrillator"))
					{
						if (distance > 150 && distance < 1700)
						{
							printl("[Bot AI] Body far away");
							BotMove(player, searchedBody);
							continue;
						}
					
						if (distance < 150 && !VSLib.Entity(player).IsPressingAttack() && !VSLib.Entity(player).IsPressingShove() && !VSLib.Player(player).IsHealing() && !VSLib.Player(player).IsBeingHealed())
						{
							VSLib.Entity(player).SetForwardVector(faceEntityCorrect(player, searchedBody));
							VSLib.Player(body).Defib();
							VSLib.Entity(player).EmitSound("weapons/defibrillator/defibrillator_use.wav");
							local t = VSLib.Player(player).GetHeldItems();

							if (t)
							{
								foreach (killitem in t)
								{
									if ( killitem.GetClassname() == "defibrillator" || killitem.GetClassname() == "weapon_" + "defibrillator" )
										killitem.Kill();
								}
							}
							BotReset(player);
							continue;
						}
					}
					else
					{
						item <- null;
						findDef <- null
						local defDis = 800; 
						while (Entities.FindInSphere(item, player.GetOrigin(), 800) != null) {
							item = Entities.FindInSphere(item, player.GetOrigin(), 800);
							ename <- item.GetClassname();
							idistance <- distanceof(player.GetOrigin(), item.GetOrigin());
							if ((ename == "weapon_defibrillator" || ename == "weapon_defibrillator_spawn") && item.GetOwnerEntity() == null)
							{
								if(findDef == null || idistance < defDis)
								{
									findDef = item;
									defDis = idistance;
								}
							}
						}
						
						if(findDef != null)
						{
							printl("[Bot AI] Found defib");
							if (defDis > 150)
							{
								BotMove(player, findDef);
								continue;
							}
							else if(findDef.GetOwnerEntity() == null)
							{
								doAmmoUpgrades(player);
								DoEntFire("!self", "Use", "", 0, player, findDef);
								BotReset(player);
								continue;
							}
						}
					}
				}
			}
		}
	}
	
	if(searchedBody == null)
	{
		player <- null;

	while(player = Entities.FindByClassname(player, "player"))
	{
		if(VSLib.Player(player).IsPlayerEntityValid() && player.IsSurvivor() && IsPlayerABot(player))
		{
			item <- null;
			while (Entities.FindInSphere(item, player.GetOrigin(), 150) != null) 
			{
				item = Entities.FindInSphere(item, player.GetOrigin(), 150);
				ename <- item.GetClassname();
				
				if(item.GetOwnerEntity() == null)
				{
					if (ename == "first_aid_kit_spawn" || ename == "first_aid_kit" || ename == "weapon_first_aid_kit_spawn" || ename == "weapon_first_aid_kit" )
					{
						doAmmoUpgrades(player);
						DoEntFire("!self", "Use", "", 0, player, item);
						return;
					}
				}
			}
		}
	}
	}
}

function searchVomitjar( args )
{
	vomitjar <- null;
	while(vomitjar = Entities.FindByModel(vomitjar, "models/w_models/weapons/w_eq_bile_flask.mdl"))
	{
		if(vomitjar.GetHealth() > 1000 && GetDistanceToGround(vomitjar) < 10)
		{
			vomitjar.SetHealth(vomitjar.GetHealth()-1);
			if(vomitjar.GetHealth() < 12425)
			{
				local angvec = Vector( 0, 0, 0 );
			local infectedX =
			{
				classname = "info_goal_infected_chase"
				origin = vomitjar.GetOrigin()
				angles = angvec
			}
			infected <- g_ModeScript.CreateSingleSimpleEntityFromTable(infectedX);
			infected.ValidateScriptScope();
			local effectX =
			{
				classname = "info_particle_system"
				effect_name = "vomit_jar"
				start_active = "1"
				angles = angvec
				origin = vomitjar.GetOrigin()
			}
			effect <- g_ModeScript.CreateSingleSimpleEntityFromTable(effectX);
			effect.ValidateScriptScope();
			
			if(VSLib.Entity(infected).IsEntityValid() && VSLib.Entity(effect).IsEntityValid())
			{
				VSLib.Entity(vomitjar).EmitSound("weapons/ceda_jar/ceda_jar_explode.wav");
				DoEntFire("!self", "Enable", "", 0, null, infected);
				vomitjar.SetHealth(-1);
				vomitjar.Kill();
				VSLib.Entity(effect).KillDelayed(15);
				VSLib.Entity(infected).KillDelayed(15);
				printl("[Bot AI]vomitjar created.");

				infec <- null;
				while (Entities.FindByClassnameWithin(infec, "infected", infected.GetOrigin(), 110) != null) {
					infec = Entities.FindByClassnameWithin(infec, "infected", infected.GetOrigin(), 110);
					NetProps.SetPropInt(infec, "m_Glow.m_iGlowType", 3);
					//NetProps.SetPropInt(infec, "m_nGlowRange", 0 );
					NetProps.SetPropInt(infec, "m_Glow.m_glowColorOverride", -4713783);
					if ("HitWithVomit" in infec)
						infec.HitWithVomit();
					Timers.AddTimer(20, false, DisableGlow {infect = infec});
				}
			}
			}
		}
	}
}

function DisableGlow(arg)
{
	NetProps.SetPropInt(arg.infect, "m_Glow.m_iGlowType", 0);
	NetProps.SetPropInt(arg.infect, "m_Glow.m_glowColorOverride", 0);
}

::DisableGlow <- DisableGlow;

function searchMolotov( args )
{
	molotov <- null;
	while(molotov = Entities.FindByModel(molotov, "models/w_models/weapons/w_eq_molotov.mdl"))
	{
		if(molotov.GetHealth() > 1000 && GetDistanceToGround(molotov) < 10)
		{
			gascan <- VSLib.Utils.CreateEntity("weapon_gascan", molotov.GetOrigin());
			if(VSLib.Entity(gascan).IsEntityValid())
			{
				VSLib.Entity(molotov).EmitSound("weapons/molotov/molotov_detonate_3.wav");
				gascan.SetHealth(-1);
				DoEntFire("!self","Ignite","",0,null,gascan);
				molotov.SetHealth(-1);
				molotov.Kill();
			}
		}
	}
}

function GetDistanceToGround(ent_)
{
	local startPt = ent_.GetOrigin();
	local endPt = startPt + Vector(0, 0, -9999999);

	local m_trace = { start = startPt, end = endPt, ignore = ent_, mask = g_MapScript.TRACE_MASK_SHOT };
	TraceLine(m_trace);

	if (m_trace.enthit == ent_ || !m_trace.hit)
	return 0.0;

	return ::distanceof(startPt, m_trace.pos);
}
	
::GetDistanceToGround <- GetDistanceToGround;

function searchPipe( args )
{
	pipe <- null;
	while(pipe = Entities.FindByClassname(pipe, "weapon_pipe_bomb"))
	{
		if(pipe.GetName() == "botaipipebomb")
		{
			player <- null;
			while(player = Entities.FindByClassname(player, "player"))
			{
				if(VSLib.Player(player).IsPlayerEntityValid() && player.IsSurvivor() && IsPlayerABot(player) && distanceof(player.GetOrigin(), pipe.GetOrigin()) < 200)
				{
					throwVec <- faceEntity(player, pipe);
					if(throwVec != null)
						VSLib.Entity(pipe).Push(Vector(-throwVec.y * 100, throwVec.x * 300, throwVec.z * 100) + Vector(0, 200, 0));
				}
			}
			lifetime <- pipe.GetHealth();
			switch (lifetime)
			{
				case 4:
				case 8:
				case 12:
				case 16:
				case 20:
				case 23:
				case 26:
				case 29:
				case 32:
				case 35:
				case 37:
				case 39:
				case 41:
				case 43:
				case 45:
					VSLib.Entity(pipe).EmitSound("weapons/hegrenade/beep.wav");
			}

			if (lifetime > 45)
			
				VSLib.Entity(pipe).EmitSound("weapons/hegrenade/beep.wav");

			if(lifetime % 5 == 0 && lifetime != 0 && lifetime < 70)
			{
				local infectedX =
				{
					classname = "info_goal_infected_chase"
					origin = pipe.GetOrigin()
					angles = Vector( 0, 0, 0 )
				}
				infected <- g_ModeScript.CreateSingleSimpleEntityFromTable(infectedX);
				infected.ValidateScriptScope();

				DoEntFire("!self", "Enable", "", 0, null, infected);
				infected.SetOrigin(pipe.GetOrigin());
				DoEntFire("!self", "SetParent", "!activator", 0, infected, pipe);
				DoEntFire("!self", "Disable", "", 0.5, null, infected);
				DoEntFire("!self", "Kill", "", 7, null, infected);
			}

			if(lifetime >= 60)
			{
				local explosionX =
				{
					classname = "prop_physics"
					origin = pipe.GetOrigin()
					model = "models/props_equipment/oxygentank01.mdl"
				}
				
				explosion <- g_ModeScript.CreateSingleSimpleEntityFromTable(explosionX);
				explosion.ValidateScriptScope();

				if(VSLib.Entity(explosion).IsEntityValid())
				{
					DoEntFire("!self", "break", "", 0, null, explosion);
					pipe.SetHealth(-1);
					pipe.Kill();
				}
			}
			else
			{
				pipe.SetHealth(lifetime + 1);
			}
		}
	}
}

function CanSeeOtherEntity(player, otherEntity, tolerance = 50)
{
	if (!player.IsValid() || !otherEntity.IsValid())
	{
		return false;
	}
	
	local clientPos = player.GetOrigin();
	if("EyePosition" in player)
		clientPos = player.EyePosition();
	else
		clientPos += Vector(0, 62, 0);
		
	local clientToTargetVec = otherEntity.GetOrigin() - clientPos;
	local clientAimVector = Vector(0, 0, 0);
	if("EyeAngles" in player)
		clientAimVector = player.EyeAngles().Forward();
	else if("GetForwardVector" in player)
		clientAimVector = player.GetForwardVector();
	
	local angToFind = acos(::VSLib.Utils.VectorDotProduct(clientAimVector, clientToTargetVec) / (clientAimVector.Length() * clientToTargetVec.Length())) * 360 / 2 / 3.14159265;
	
	if (angToFind >= tolerance)
		return false;
	
	// Next check to make sure it's not behind a wall or something
	local m_trace = { start = clientPos, end = otherEntity.GetOrigin(), ignore = player};
	TraceLine(m_trace);

	if (!m_trace.hit || m_trace.enthit == null || m_trace.enthit == player)
		return false;

	if (m_trace.enthit.GetClassname() == "worldspawn" || !m_trace.enthit.IsValid())
		return false;
		
	if (m_trace.enthit == otherEntity)
		return true;
	
	return false;
}
::CanSeeOtherEntity <- CanSeeOtherEntity;

function CanSeeOtherEntityWithoutBarrier(player, otherEntity, tolerance = 50)
{
	if (!VSLib.Player(player).IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}
	
	local clientPos = player.EyePosition();
	local clientToTargetVec = otherEntity.GetOrigin() - clientPos;
	local clientAimVector = player.EyeAngles().Forward();
	
	local angToFind = acos(::VSLib.Utils.VectorDotProduct(clientAimVector, clientToTargetVec) / (clientAimVector.Length() * clientToTargetVec.Length())) * 360 / 2 / 3.14159265;
	
	if (angToFind >= tolerance)
		return false;
	
	// Next check to make sure it's not behind a wall or something
	local m_trace = { start = player.EyePosition(), end = otherEntity.GetOrigin(), ignore = player, mask = g_MapScript.TRACE_MASK_SHOT};
	TraceLine(m_trace);

	if (!m_trace.hit || m_trace.enthit == null || m_trace.enthit == player)
		return false;

	if (m_trace.enthit.GetClassname() == "worldspawn" || !m_trace.enthit.IsValid())
		return false;
		
	if (m_trace.enthit == otherEntity)
		return true;
	
	return false;
}

::CanSeeOtherEntityWithoutBarrier <- CanSeeOtherEntityWithoutBarrier;

function CanSeeOtherEntityWithoutLocation(player, otherEntity)
{
	if (!VSLib.Player(player).IsPlayerEntityValid())
	{
		printl("VSLib Warning: Player " + _idx + " is invalid.");
		return;
	}

	eyevec <- otherEntity.GetOrigin() + Vector(0, 60, 0);
	
	//Peyevec <- player.GetOrigin() + Vector(0, 30, 0);
	Oeyevec <- otherEntity.GetOrigin() + Vector(0, 60, 0);
	
	if("EyePosition" in otherEntity)
		Oeyevec = otherEntity.EyePosition();
	//, mask = g_MapScript.TRACE_MASK_SHOT
	local mp_trace = { start = player.EyePosition(), end = eyevec, ignore = player};
	TraceLine(mp_trace);

	local hp_trace = { start = Oeyevec, end = player.EyePosition(), ignore = otherEntity};
	TraceLine(hp_trace);

	local np_trace = { start = player.EyePosition(), end = otherEntity.GetOrigin() + Vector(0, 30, 0), ignore = player};
	TraceLine(np_trace);

	mpHit <- true;
	hpHit <- true;
	npHit <- true;

	if (!mp_trace.hit || mp_trace.enthit == null || mp_trace.enthit == player)
	{
		mpHit = false;
	}

	if (!hp_trace.hit || hp_trace.enthit == null || hp_trace.enthit == otherEntity)
	{
		hpHit = false;
	}

	if (!np_trace.hit || np_trace.enthit == null || np_trace.enthit == player)
	{
		npHit = false;
	}

	if (mpHit && mp_trace.enthit.GetClassname() == "infected")
	{
		return true;
	}

	if (npHit && np_trace.enthit.GetClassname() == "infected")
	{
		return true;
	}

	if ((mpHit && mp_trace.enthit == otherEntity) || (npHit && np_trace.enthit == otherEntity) || (hpHit && hp_trace.enthit == player))
	{
		return true;
	}

	return false;
}

::CanSeeOtherEntityWithoutLocation <- CanSeeOtherEntityWithoutLocation;

function randomBotThrowDelay(args)
{
	printl("[Bot AI] Try Create delay throwable.");
	randomBotThrow(null, 0);
}

::randomBotThrowDelay <- randomBotThrowDelay;

function randomBotThrow(ent_ = null, type = 0)
{
	player <- null;
	
	while(player = Entities.FindByClassname(player, "player"))
	{
		if(VSLib.Player(player).IsPlayerEntityValid() && player.IsSurvivor() && IsPlayerABot(player) && !player.IsDead())
		{
			hasMo <- VSLib.Player(player).HasItem("weapon_molotov");
			hasVo <- VSLib.Player(player).HasItem("weapon_vomitjar");
			hasPi <- VSLib.Player(player).HasItem("weapon_pipe_bomb");
			
			if(!hasMo && !hasVo && !hasPi)
				return;
			
			canSee <- false;
			if(ent_ != null)
				canSee = CanSeeOtherEntity(player, ent_, 75);

			idistance <- 0;
			if(canSee)
				 idistance = distanceof(player.GetOrigin(), ent_.GetOrigin());

			hasInfectCloud <- false;
			InfectCloud <- null;
			while(InfectCloud = Entities.FindByClassnameWithin(InfectCloud, "info_goal_infected_chase", player.GetOrigin(), 1600)) {
				if (InfectCloud.IsValid())
				{
					hasInfectCloud = true;
				}
			}
			
			eyeVec <- Vector(player.EyeAngles().x * 700, player.EyeAngles().y * 700, player.EyeAngles().z * 700) + Vector(0, 800, 0);
			
			if((type == 1 || type == 2)	&& (hasMo || hasVo || hasPi))
			{
				if(ent_ != null && idistance > 200 && idistance < 1300)
				{
					if(hasMo && CanSeeOtherEntityWithoutBarrier(player, ent_, 75))
					{
						hasPlayer <- false;
						Aplayer <- null;
						while(Aplayer = Entities.FindByClassnameWithin(Aplayer, "player", ent_.GetOrigin(), 250)) {
							if (Aplayer.IsValid() && Aplayer.IsSurvivor() && !Aplayer.IsDead())
							{
								hasPlayer = true;
							}
						}

						if(!hasPlayer)
						{
							if(idistance < 400)
								throwBreakble(player, "molotov", faceEntity(player, ent_), idistance * 1.2);
							else if(idistance < 800)
								throwBreakble(player, "molotov", faceEntity(player, ent_), idistance * 1.65);
							else
								throwBreakble(player, "molotov", faceEntity(player, ent_), idistance * 2);
							return true;
						}
					}
					else if(hasVo && !hasInfectCloud)
					{
						throwBreakble(player, "vomitjar", faceEntity(player, ent_) + Vector(0, 400, 0), idistance * 4);
						return true;
					}
					else if(hasPi && !type == 2 && !hasInfectCloud)
					{
						throwUnBreakble(player, faceEntity(player, ent_) + Vector(0, 400, 0));
						return true;
					}
				}
				else if(ent_ != null && hasVo && !hasInfectCloud && idistance < 600)
				{
					throwBreakble(player, "vomitjar", faceEntity(player, ent_) + Vector(0, 400, 0),  idistance * 4);
					return true;
				}
				else if(hasVo && !hasInfectCloud && idistance < 600)
				{
					throwBreakble(player, "vomitjar", eyeVec);
					return true;
				}
				else if(hasPi && !type == 2 && !hasInfectCloud && idistance < 600)
				{
					throwUnBreakble(player, eyeVec);
					return true;
				}
			}
			else if (type == 0)
			{
				infectedAmount <- 0;
				infec <- null;
				while(infec = Entities.FindByClassnameWithin(infec, "infected", player.GetOrigin(), 800)) 
				{
					if (infec.IsValid() && VSLib.Entity(infec).IsAlive())
					{
						infectedAmount++;
					}
				}
				
				if(infectedAmount > 20)
				{
					if(hasPi && !hasInfectCloud)
					{
						throwUnBreakble(player, eyeVec);
						return true;
					}
					else if(hasVo && !hasInfectCloud)
					{
						throwBreakble(player, "vomitjar", eyeVec);
						return true;
					}
				}
			}
		}
	}
}

::randomBotThrow <- randomBotThrow;

function checkToThrowGen( args )
{
	infectNum <- 0;

	ent <- null;
	while (ent = Entities.FindByClassname(ent, "infected"))
	{
		if (ent.IsValid())
		{
			infectNumII <- 0;
			infectNum++;
			infec <- null;
			while(infec = Entities.FindByClassnameWithin(infec, "infected", ent.GetOrigin(), 300)) {
				if(VSLib.Entity(infec).IsAlive())
					infectNumII++;
			}
			
			if(infectNumII > 10 && randomBotThrow(ent, 1))
				return;
		}
	}
	
	if(infectNum > 30)
		randomBotThrow(null, 0);
		
	AllInfectedAmount = infectNum;
}
	
function ThrowTank( args )
{
	entT <- null;
	gettank <- false;
	while (entT = Entities.FindByModel(entT, "models/infected/hulk.mdl"))
	{
		gettank = true;
		if (entT.IsValid())
		{
			player <- null;
			hasPlayer <- false;
			canAttackTank <- 0;
			
			while(player = Entities.FindByClassnameWithin(player, "player", entT.GetOrigin(), 1800)) {
				if (player.IsValid() && player.IsSurvivor() && !player.IsDead())
				{
					if(distanceof(player.GetOrigin(), entT.GetOrigin()) < 250)
						hasPlayer = true;
					if(!player.IsIncapacitated() && !player.IsHangingFromLedge() && player.GetHealth() > 15)
						canAttackTank++;
				}
			}
			
			se <- false;
			if(!hasPlayer && !VSLib.Entity(entT).IsOnFire())
			{
				if((canAttackTank <= 2 && entT.GetHealth() > 500) || (canAttackTank <= 3 && entT.GetHealth() > 1000) || (canAttackTank <= 4 && entT.GetHealth() > 1500))
				{
					se = randomBotThrow(entT, 2);
				}
			}
			if(se)
			{
				return;
			}
		}
	}
	
	HasTank = gettank;
}

/*
function client_command(player, command, delay = 0.01)
{
	local ent = Entities.FindByClassname(null, "point_clientcommand");
	if (!ent) {
		ent = g_ModeScript.CreateSingleSimpleEntityFromTable({classname = "point_clientcommand", targetname = "bot_ai_clientcommand"});
		printl("created point_clientcommand");
	}
	DoEntFire("!self", "Command", command, delay, player, ent);
}

::client_command <- client_command;

function server_command(player, command, delay = 0.01)
{
	local ent = Entities.FindByClassname(null, "point_servercommand");
	if (!ent) {
		ent = g_ModeScript.CreateSingleSimpleEntityFromTable({classname = "point_servercommand", targetname = "bot_ai_servercommand"});
		printl("created point_servercommand");
	}
	DoEntFire("!self", "Command", command, delay, player, ent);
}

::server_command <- server_command;
*/

function AvoidDanger( args )
{
	player <- null;
	while(player = Entities.FindByClassname(player, "player"))
	{
		if(VSLib.Player(player).IsPlayerEntityValid() && player.IsSurvivor() && IsPlayerABot(player) && !player.IsDead() && !player.IsIncapacitated() && VSLib.Player(player).IsOnGround())
		{
			ent_ <- null;
			while (Entities.FindInSphere(ent_, player.GetOrigin(), 400) != null) 
			{
				ent_ = Entities.FindInSphere(ent_, player.GetOrigin(), 400);
				ename <- ent_.GetClassname();
				if(ename == "env_entity_igniter" || ename == "entityflame" || ename == "insect_swarm" || (ename == "weapon_pipe_bomb" && ent_.GetName == "botaipipebomb" && distanceof(ent_.GetOrigin(), player.GetOrigin()) < 250))
				{
					throwVec <- faceEntity(ent_, player);
					if(throwVec != null)
						VSLib.Entity(player).Push(Vector(-throwVec.y * 75, 0, throwVec.z * 75));
				}
				
				if(ename == "spitter_projectile" || ename == "tank_rock")
				{
					throwVec <- faceEntity(ent_, player);
					throwVec2 <- faceEntityCorrect(ent_, player);
					if(throwVec != null)
					{
						VSLib.Entity(player).Push(Vector(-throwVec.y * 225, 0, throwVec.z * 225));
						if(throwVec2 != null)
							VSLib.Entity(ent_).Push(Vector(throwVec2.y * 15, -throwVec2.x * 15, -throwVec2.z * 15));
						continue;
					}
				}
			}
			
			
			entT <- null;
			while (entT = Entities.FindByModel(entT, "models/infected/hulk.mdl"))
			{
				if (entT.IsValid() && VSLib.Entity(entT).IsAlive() && distanceof(player.GetOrigin(), entT.GetOrigin()) < 500)
				{
					throwVec <- null;
					
					if(CanSeeOtherEntity(player, entT, 75))
						throwVec = faceEntityCorrect(entT, player);
					if(throwVec != null)
					{
						//player.SetVelocity(Vector(-throwVec.y * 150, 0, throwVec.z * 150));
						VSLib.Entity(player).Push(Vector(-throwVec.y * 200, 0, throwVec.z * 200));
					}
				}
			}
			
			entW <- null;
			while (entW = Entities.FindByModel(entW, "models/infected/witch.mdl"))
			{
				if (entW != null && entW.IsValid() && VSLib.Entity(entW).IsAlive() && distanceof(player.GetOrigin(), entW.GetOrigin()) < 1000)
				{
					WitchState <- NetProps.GetPropInt(entW, "m_nSequence");
				
					if(WitchState != ANIM_SITTING_CRY && WitchState != ANIM_SITTING_STARTLED && WitchState != ANIM_SITTING_AGGRO && WitchState != ANIM_WALK && WitchState != ANIM_WANDER_WALK)
					{
						if(WitchState == ANIM_WITCH_WANDER_ACQUIRE || WitchState == ANIM_WITCH_KILLING_BLOW || WitchState == ANIM_WITCH_KILLING_BLOW_TWO)
						{
								throwVec <- null;
					
								if(CanSeeOtherEntityWithoutLocation(player, entW))
								{
									throwVec = faceEntityCorrect(player, entW);
								}

								if(throwVec != null)
								{
									NetProps.SetPropFloat(player, "m_flLaggedMovementValue", 2.25);
									player.SetFriction(2.25);
									VSLib.Entity(player).SetForwardVector(throwVec);
									if(!player.IsIncapacitated())
										player.ApplyAbsVelocityImpulse(Vector(-throwVec.y * 200, 0, throwVec.z * 200));
								}
						}
						
						if(!CanSeeOtherEntity(entW, player, 35))
						{
							throwVec <- null;
					
							if(CanSeeOtherEntity(player, entW, 75))
							{
								throwVec = faceEntityCorrect(player, entW);
							}

							if(throwVec != null)
							{
								if(!player.IsIncapacitated())
									player.ApplyAbsVelocityImpulse(Vector(-throwVec.y * 200, 0, throwVec.z * 200));
							}
						}
					}
					else
					{
						playerS <- null;
						hasPlayer <- true;
						while (playerS = Entities.FindByClassnameWithin(playerS, "player", player.GetOrigin(), 500))
						{
							if(VSLib.Player(playerS).IsPlayerEntityValid() && playerS.IsSurvivor() && !IsPlayerABot(playerS) && !playerS.IsDead() && !playerS.IsHangingFromLedge() && !playerS.IsIncapacitated())
							{
								hasPlayer = true;
							}
						}
						
						if(hasPlayer && distanceof(player.GetOrigin(), entW.GetOrigin()) < 300)
						{
							throwVec <- null;
					
							if(CanSeeOtherEntity(player, entW, 75))
								throwVec = faceEntityCorrect(player, entW);
							if(throwVec != null)
							{
								VSLib.Entity(player).Push(Vector(throwVec.y * 100, 0, -throwVec.z * 100));
							}
						}
					}
				}
			}
		}
	}
}

function distanceof(vec1, vec2)
{
	if(!vec1 || !vec2)
		return 9000;
		
	return sqrt((vec1.x - vec2.x)*(vec1.x - vec2.x) + (vec1.y - vec2.y)*(vec1.y - vec2.y) + (vec1.z - vec2.z)*(vec1.z - vec2.z));
}

::distanceof <- distanceof;

function transItem( args )
{
	player <- null;
	while(player = Entities.FindByClassname(player, "player"))
	{
		if(VSLib.Player(player).IsPlayerEntityValid() && player.IsSurvivor() && IsPlayerABot(player) && !player.IsDead() && !VSLib.Player(player).IsInCombat() && !VSLib.Entity(player).IsPressingAttack() && !VSLib.Entity(player).IsPressingShove() && !VSLib.Player(player).IsHealing() && !VSLib.Player(player).IsBeingHealed())
		{
			survivor <- null;
			while(survivor = Entities.FindByClassnameWithin(survivor, "player", player.GetOrigin(), 150))
			{
				if(VSLib.Player(survivor).IsPlayerEntityValid() && survivor.IsSurvivor() && !IsPlayerABot(survivor) && !survivor.IsDead())
				{
					P_Owner <- NetProps.GetPropInt(player, "m_reviveOwner");
					P_Target <- NetProps.GetPropInt(player, "m_reviveTarget");
					S_Owner <- NetProps.GetPropInt(survivor, "m_reviveOwner");
					S_Target <- NetProps.GetPropInt(survivor, "m_reviveTarget");
					
					hasbag <- VSLib.Player(survivor).HasItem("first_aid_kit") || VSLib.Player(survivor).HasItem("defibrillator");
					haspill <- VSLib.Player(survivor).HasItem("pain_pills") || VSLib.Player(survivor).HasItem("adrenaline");
					hasgen <- VSLib.Player(survivor).HasItem("molotov") || VSLib.Player(survivor).HasItem("pipe_bomb") || VSLib.Player(survivor).HasItem("vomitjar");

					if(getPlayerTotalHealth(player) > 25 && VSLib.Player(player).HasItem("first_aid_kit") && !hasbag && P_Owner == -1 && P_Target == -1 && S_Owner == -1 && S_Target == -1)
					{
						removeItem(player, "first_aid_kit");
						survivor.GiveItem("first_aid_kit");
						NetProps.SetPropInt(player, "m_reviveOwner", -1);
						NetProps.SetPropInt(player, "m_reviveTarget", -1);
						NetProps.SetPropInt(survivor, "m_reviveOwner", -1);
						NetProps.SetPropInt(survivor, "m_reviveTarget", -1);
						return;
					}
					else if(VSLib.Player(player).HasItem("defibrillator") && !hasbag && P_Owner == -1 && P_Target == -1 && S_Owner == -1 && S_Target == -1)
					{
						removeItem(player, "defibrillator");
						survivor.GiveItem("defibrillator");
						NetProps.SetPropInt(player, "m_reviveOwner", -1);
						NetProps.SetPropInt(player, "m_reviveTarget", -1);
						NetProps.SetPropInt(survivor, "m_reviveOwner", -1);
						NetProps.SetPropInt(survivor, "m_reviveTarget", -1);
						return;
					}
					
					if(getPlayerTotalHealth(player) > 25 && VSLib.Player(player).HasItem("pain_pills") && !haspill)
					{
						removeItem(player, "pain_pills");
						survivor.GiveItem("pain_pills");
						BotReset(player);
						return;
					}
					else if(getPlayerTotalHealth(player) > 25 && VSLib.Player(player).HasItem("adrenaline") && !haspill)
					{
						removeItem(player, "adrenaline");
						survivor.GiveItem("adrenaline");
						BotReset(player);
						return;
					}
					
					if(VSLib.Player(player).HasItem("molotov") && !hasgen)
					{
						removeItem(player, "molotov");
						survivor.GiveItem("molotov");
						BotReset(player);
						return;
					}
					else if(VSLib.Player(player).HasItem("pipe_bomb") && !hasgen)
					{
						removeItem(player, "pipe_bomb");
						survivor.GiveItem("pipe_bomb");
						BotReset(player);
						return;
					}
					else if(VSLib.Player(player).HasItem("vomitjar") && !hasgen)
					{
						removeItem(player, "vomitjar");
						survivor.GiveItem("vomitjar");
						BotReset(player);
						return;
					}
				}
			}
		}
	}
}

function transKit( args )
{
	player <- null;
	while(player = Entities.FindByClassname(player, "player"))
	{
		if(VSLib.Player(player).IsPlayerEntityValid() && player.IsSurvivor() && IsPlayerABot(player) && !player.IsDead() && !VSLib.Player(player).IsLastStrike())
		{
			survivor <- null;
			while(survivor = Entities.FindByClassnameWithin(survivor, "player", player.GetOrigin(), 150))
			{
				if(VSLib.Player(survivor).IsPlayerEntityValid() && survivor.IsSurvivor() && !survivor.IsDead() && VSLib.Player(survivor).IsLastStrike() && survivor != player)
				{
					P_Owner <- NetProps.GetPropInt(player, "m_reviveOwner");
					P_Target <- NetProps.GetPropInt(player, "m_reviveTarget");
					S_Owner <- NetProps.GetPropInt(survivor, "m_reviveOwner");
					S_Target <- NetProps.GetPropInt(survivor, "m_reviveTarget");
					if(VSLib.Player(player).HasItem("first_aid_kit") && !VSLib.Player(survivor).HasItem("first_aid_kit") && P_Owner == -1 && P_Target == -1 && S_Owner == -1 && S_Target == -1)
					{
						removeItem(player, "first_aid_kit");
						survivor.GiveItem("first_aid_kit");
						BotReset(player);
						NetProps.SetPropInt(player, "m_reviveOwner", -1);
						NetProps.SetPropInt(player, "m_reviveTarget", -1);
						NetProps.SetPropInt(survivor, "m_reviveOwner", -1);
						NetProps.SetPropInt(survivor, "m_reviveTarget", -1);
					}
				}
			}
		}
	}
}

function getPlayerTotalHealth(player)
{
	return player.GetHealth() + VSLib.Player(player).GetHealthBuffer();
}

::getPlayerTotalHealth <- getPlayerTotalHealth;

function hitInfected( args )
{
	player <- null;
	
	while(player = Entities.FindByClassname(player, "player"))
	{
		if(VSLib.Player(player).IsPlayerEntityValid() && player.IsSurvivor() && IsPlayerABot(player) && !player.IsDead())
		{
			smoker <- null
			local dist = null;
			local entS = null;
			while (smoker = Entities.FindByModel(smoker, "models/infected/smoker.mdl"))
			{
				if (smoker.IsValid() && VSLib.Entity(smoker).IsAlive() && !smoker.IsDead())
				{
					if ( !dist || distanceof(player.GetOrigin(), smoker.GetOrigin()) < dist )
					{
						dist = distanceof(player.GetOrigin(), smoker.GetOrigin());
						entS = smoker;
					}
				}
			}
			
			if (entS != null && (CanSeeOtherEntityWithoutLocation(player, entS) || distanceof(player.GetOrigin(), entS.GetOrigin()) < 75))
			{
				if(UseTarget != null && !VSLib.Player(player).IsInCombat())
				{
					BotReset(player);
					VSLib.Player(player).DropPickup();
				}
				VSLib.Entity(player).SetTarget(entS);
				VSLib.Entity(player).SetForwardVector(faceEntityCorrect(player, entS));
				BotAttack(player, entS);
				continue;
			}

			ent <- null;
			local t = {};
			local i = -1;
			bom <- findClosestSP(player, "models/infected/boomer.mdl");
			bome <- findClosestSP(player, "models/infected/boomette.mdl");
			hunter <- findClosestSP(player, "models/infected/hunter.mdl");
			spitter <- findClosestSP(player, "models/infected/spitter.mdl");
			charger <- findClosestSP(player, "models/infected/charger.mdl");
			jockey <- findClosestSP(player, "models/infected/jockey.mdl");
			
			if(bom != null && distanceof(player.GetOrigin(), bom.GetOrigin()) > 300 )
				t[++i] <- bom;
			if(bome != null && distanceof(player.GetOrigin(), bome.GetOrigin()) > 300 )
				t[++i] <- bome;
			if(hunter != null)
				t[++i] <- hunter;
			if(spitter != null)
				t[++i] <- spitter;
			if(charger != null)
				t[++i] <- charger;
			if(jockey != null)
				t[++i] <- jockey;
			
			ent = findClosestEntity(player, t);

			if (ent != null && (CanSeeOtherEntityWithoutLocation(player, ent) || distanceof(player.GetOrigin(), ent.GetOrigin()) < 75))
			{
				if(UseTarget != null && !VSLib.Player(player).IsInCombat())
				{
					BotReset(player);
					VSLib.Player(player).DropPickup();
				}
				VSLib.Entity(player).SetTarget(ent);
				VSLib.Entity(player).SetForwardVector(faceEntityCorrect(player, ent));
				BotAttack(player, ent);
				continue;
			}
				
			witch <- null
			local distan = null;
			local entW = null;
			while (witch = Entities.FindByModel(witch, "models/infected/witch.mdl"))
			{
				if (witch.IsValid() && VSLib.Entity(witch).IsAlive())
				{
					if ( !distan || distanceof(player.GetOrigin(), witch.GetOrigin()) < distan )
					{
						distan = distanceof(player.GetOrigin(), witch.GetOrigin());
						entW = witch;
					}
				}
			}
			
			if (entW != null && entW.IsValid() && CanSeeOtherEntityWithoutLocation(player, entW))
			{
				WitchState <- NetProps.GetPropInt(entW, "m_nSequence");
				
				if(WitchState != ANIM_SITTING_CRY && WitchState != ANIM_SITTING_STARTLED && WitchState != ANIM_SITTING_AGGRO && WitchState != ANIM_WALK && WitchState != ANIM_WANDER_WALK)
				{
					VSLib.Entity(player).SetTarget(entW);
					VecSee <- faceEntityCorrect(player, entW);
					if(VecSee != null)
						VSLib.Entity(player).SetForwardVector(VecSee);
					BotAttack(player, entW);
					continue;
				}
			}

			com <- null
			local disttt = null;
			local entt = null;
			while (com = Entities.FindByClassnameWithin(com, "infected", player.GetOrigin(), 400))
			{
				if (com.IsValid() && VSLib.Entity(com).IsAlive())
				{
					if ( !disttt || distanceof(player.GetOrigin(), com.GetOrigin()) < disttt )
					{
						disttt = distanceof(player.GetOrigin(), com.GetOrigin());
						entt = com;
					}
				}
			}

			if (UseTarget != null && entt != null && !VSLib.Player(player).IsInCombat() && (CanSeeOtherEntityWithoutLocation(player, entt) && distanceof(player.GetOrigin(), entt.GetOrigin()) < 250))
			{
				BotReset(player);
				VSLib.Player(player).DropPickup();
				VSLib.Entity(player).SetTarget(entt);
				VSLib.Entity(player).SetForwardVector(faceEntityCorrect(player, entt));
				BotAttack(player, entt);
				continue;
			}

			if (entt != null && ((CanSeeOtherEntityWithoutLocation(player, entt) && distanceof(player.GetOrigin(), entt.GetOrigin()) > 200) || distanceof(player.GetOrigin(), entt.GetOrigin()) < 75))
			{
				VSLib.Entity(player).SetTarget(entt);
				VSLib.Entity(player).SetForwardVector(faceEntityCorrect(player, entt));
				BotAttack(player, entt);
				continue;
			}
		}
	}
}

/*
function getIsMelee(player)
{
	weaponN <- player.GetActiveWeapon();
	
	if(weaponN == null || !weaponN.IsValid())
		return false;
		
	wname <- weaponN.GetClassname();
	
	if(wname == "weapon_chainsaw" || wname == "weapon_melee")
		return true;
	return false;
}
::getIsMelee <- getIsMelee;
*/

function findClosestSP(player, model)
{
	local dist = null;
	local ent = null;
	while (smoker = Entities.FindByModel(smoker, model))
	{
		if (smoker.IsValid() && VSLib.Entity(smoker).IsAlive() && !smoker.IsDead())
		{
			if ( !dist || distanceof(player.GetOrigin(), smoker.GetOrigin()) < dist )
			{
				dist = distanceof(player.GetOrigin(), smoker.GetOrigin());
				ent = smoker;
			}
		}
	}
	return ent;
}
::findClosestSP <- findClosestSP;
function findClosestEntity(player, table)
{
	local dist = null;
	local ent = null;
	
	foreach( entity in table )
	{
		if (entity.IsValid())
		{
			if ( !dist || distanceof(player.GetOrigin(), entity.GetOrigin()) < dist )
			{
				dist = distanceof(player.GetOrigin(), entity.GetOrigin());
				ent = entity;
			}
		}
	}
	
	return ent;
}
::findClosestEntity <- findClosestEntity;

function BotAttack(boto, otherEntity)
{
	return CommandABot( { cmd = 0, target = otherEntity, bot = boto } );
}

::BotAttack <- BotAttack;

function BotReset(boto)
{
	return CommandABot( { cmd = 3, bot = boto } );
}

::BotReset <- BotReset;

function BotRetreatFrom(boto, otherEntity)
{
	return CommandABot( { cmd = 2, target = otherEntity, bot = boto } );
}

::BotRetreatFrom <- BotRetreatFrom;

function BotMove(boto, otherEntity, attacker = null)
{
	victimID <- NetProps.GetPropInt(boto, "m_target");
	victim <- GetPlayerFromUserID(victimID);
	
	if(attacker != null)
	{
		CommandABot( { cmd = 1, target = attacker, bot = boto, pos = otherEntity.GetOrigin()} );
		VSLib.Entity(boto).SetTarget(attacker);
	}
	else if(victim != null)
	{
		CommandABot( { cmd = 1, target = victim, bot = boto, pos = otherEntity.GetOrigin()} );
		VSLib.Entity(boto).SetTarget(victim);
	}
	else
		CommandABot( { cmd = 1, bot = boto, pos = otherEntity.GetOrigin()} );
}

::BotMove <- BotMove;

function getPlayerBaseName(player)
{
	local name = NetProps.GetPropInt(player, "m_survivorCharacter");

	if (VSLib.Utils.GetSurvivorSet() == 1 && name == 0)
		return "Bill";
	else if (VSLib.Utils.GetSurvivorSet() == 1 && name == 1)
		return "Zoey";
	else if (VSLib.Utils.GetSurvivorSet() == 1 && name == 2)
		return "Francis";
	else if (VSLib.Utils.GetSurvivorSet() == 1 && name == 3)
		return "Louis";
	else if (VSLib.Utils.GetSurvivorSet() == 2 && name == 0)
		return "Nick";
	else if (VSLib.Utils.GetSurvivorSet() == 2 && name == 1)
		return "Rochelle";
	else if (VSLib.Utils.GetSurvivorSet() == 2 && name == 2)
		return "Coach";
	else if (VSLib.Utils.GetSurvivorSet() == 2 && name == 3)
		return "Ellis";
		
	return "NULL";
}
::getPlayerBaseName <- getPlayerBaseName;

function doUpgrades(args)
{
	bot <- null;
	player <- null;
	playerB <- null;
	
	hasUpgradeAmmo <- false;
	notBot <- false;
	i <- 0
		while(player = Entities.FindByClassname(player, "player"))
		{
			if(VSLib.Player(player).IsPlayerEntityValid() && player.IsSurvivor() && !player.IsDead())
			{
				hasUpgrade <- VSLib.Player(player).GetPrimaryUpgrades() == 1 || VSLib.Player(player).GetPrimaryUpgrades() == 2;
				if(hasUpgrade)
					++i;
					
				if(!IsPlayerABot(player))
					notBot = true;
					
				if(VSLib.Player(player).HasItem("upgradepack_incendiary") || VSLib.Player(player).HasItem("upgradepack_explosive"))
					hasUpgradeAmmo = true;
			}
		}
		
		if(hasUpgradeAmmo && i < 2)
		{
			while(bot = Entities.FindByClassname(bot, "player"))
			{
				if(VSLib.Player(bot).IsPlayerEntityValid() && bot.IsSurvivor() && IsPlayerABot(bot) && !bot.IsDead() && !VSLib.Player(bot).IsInCombat() && (VSLib.Player(bot).HasItem("upgradepack_incendiary") || VSLib.Player(bot).HasItem("upgradepack_explosive")))
				{
					while(playerB = Entities.FindByClassname(playerB, "player"))
					{
						if(VSLib.Player(playerB).IsPlayerEntityValid() && playerB.IsSurvivor() && !playerB.IsDead())
						{
							if(notBot)
							{
								if(!IsPlayerABot(playerB) && distanceof(bot.GetOrigin(), playerB.GetOrigin()) > 150)
								{
									BotMove(bot, playerB);
									return;
								}
								else if(!IsPlayerABot(playerB))
								{
									doAmmoUpgrades(bot);
									BotReset(bot);
									return;
								}
							}
							else
							{
								doAmmoUpgrades(bot);
								return;
							}
						}
					}
				}
			}
		}
}

function doAmmoUpgrades(p)
{
	if( VSLib.Player(p).HasItem("upgradepack_explosive"))
	{
		VSLib.Utils.SpawnUpgrade(1, 4, p.GetOrigin());
			
		local t = VSLib.Player(p).GetHeldItems();
	
		if (t)
		{
			foreach (killitem in t)
			{
				if ( killitem.GetClassname() == "upgradepack_explosive" || killitem.GetClassname() == "weapon_" + "upgradepack_explosive" )
					killitem.Kill();
			}
		}
	}

	if(VSLib.Player(p).HasItem("upgradepack_incendiary"))
	{
		VSLib.Utils.SpawnUpgrade(0, 4, p.GetOrigin());
			
		local t = VSLib.Player(p).GetHeldItems();
	
		if (t)
		{
			foreach (killitem in t)
			{
				if ( killitem.GetClassname() == "upgradepack_incendiary" || killitem.GetClassname() == "weapon_" + "upgradepack_incendiary" )
					killitem.Kill();
			}
		}
	}
}

::doAmmoUpgrades <- doAmmoUpgrades;

// I can't find a way to make bot throw grenade :(, can just simulate it 

function throwBreakble(player, name, throwVec = null, speed = 700)
{
	throwable <- null;
	
	if(!VSLib.Player(player).IsPlayerEntityValid() || VSLib.Player(player).IsInEndingSafeRoom() || VSLib.Player(player).IsNearStartingArea())
		return;
	
	qAn <- QAngle(player.EyeAngles().z, player.EyeAngles().y, 0);
	eyevec <- VSLib.Utils.VectorFromQAngle(qAn);
	posi <- Vector(player.EyePosition().x + eyevec.x * 70, player.EyePosition().y + eyevec.y * 70, player.EyePosition().z + eyevec.z * 70);

	if(name == "vomitjar" && VSLib.Player(player).HasItem("vomitjar"))
	{
		throwable <- VSLib.Utils.CreateEntity("weapon_vomitjar", posi);

		VSLib.Entity(throwable).SetModel("models/w_models/weapons/w_eq_bile_flask.mdl");
		if(VSLib.Entity(throwable).IsEntityValid())
		{
			throwable.SetHealth(12450);
			removeItem(player, "vomitjar");
			bomerUsed <- NetProps.GetPropInt(player, "m_checkpointBoomerBilesUsed");
			NetProps.SetPropInt(player, "m_checkpointBoomerBilesUsed", bomerUsed + 1);
		}
	}
	else if(VSLib.Player(player).HasItem("molotov"))
	{
		throwable <- VSLib.Utils.CreateEntity("weapon_molotov", posi);
		
		if(VSLib.Entity(throwable).IsEntityValid())
		{
			VSLib.Entity(throwable).SetModel("models/w_models/weapons/w_eq_molotov.mdl");
			throwable.SetHealth(12450);
			removeItem(player, "molotov");
			molotovUsed <- NetProps.GetPropInt(player, "m_checkpointMolotovsUsed");
			NetProps.SetPropInt(player, "m_checkpointMolotovsUsed", molotovUsed + 1);
		}
	}

	if(VSLib.Entity(throwable).IsEntityValid())
	{
		throwable.SetAngles(player.EyeAngles());
		VSLib.Entity(throwable).SetName("botaibreakablebomb");
		if(throwVec == null)
		{
			VSLib.Entity(throwable).Push(Vector(eyevec.x * speed, eyevec.y * speed, eyevec.z * speed));
		}
		else
		{
			VSLib.Entity(throwable).Push(Vector(-throwVec.y * speed, throwVec.x * speed, throwVec.z * speed));
		}
	}
}

::throwBreakble <- throwBreakble;

function removeItem(p, itemname)
{
	local t = VSLib.Player(p).GetHeldItems();
	
	if (t)
	{
		foreach (killitem in t)
		{
			if ( killitem.GetClassname() == itemname || killitem.GetClassname() == "weapon_" + itemname )
				killitem.Kill();
		}
	}
}
::removeItem <- removeItem;

function throwUnBreakble(player, throwVec = null)
{
	if(!VSLib.Player(player).HasItem("pipe_bomb") || VSLib.Player(player).IsInEndingSafeRoom() || VSLib.Player(player).IsNearStartingArea())
		return;
		
	qAn <- QAngle(player.EyeAngles().x, player.EyeAngles().y, 0);
	eyevec <- VSLib.Utils.VectorFromQAngle(qAn);
	posi <- Vector(player.EyePosition().x + eyevec.x * 70, player.EyePosition().y + eyevec.y * 70, player.EyePosition().z + eyevec.z * 70);
	
	throwable <- VSLib.Utils.CreateEntity("weapon_pipe_bomb", posi);
	
	if(VSLib.Entity(throwable).IsEntityValid())
	{
		//VSLib.Entity(throwable).SetModel("models/w_models/weapons/w_eq_pipebomb.mdl");
		VSLib.Entity(throwable).AttachParticle("weapon_pipebomb_blinking_light", 10);
		VSLib.Entity(throwable).AttachParticle("weapon_pipebomb_fuse", 10);
		VSLib.Entity(throwable).SetName("botaipipebomb");
		throwable.SetAngles(player.EyeAngles());
		speed <- 800
		
		if(throwVec == null)
			VSLib.Entity(throwable).Push(Vector(eyevec.x * speed, eyevec.y * speed, eyevec.z * speed));
		else
			VSLib.Entity(throwable).Push(Vector(-throwVec.y * speed, throwVec.x * speed, throwVec.z * speed));

		removeItem(player, "pipe_bomb");
		pipeUsed <- NetProps.GetPropInt(player, "m_checkpointPipebombsUsed");
		NetProps.SetPropInt(player, "m_checkpointPipebombsUsed", pipeUsed + 1);
		printl("[Bot AI] Pipe Created");
	}
}
::throwUnBreakble <- throwUnBreakble;

/**
 * Changes pitch and yaw so that the entity calling the function is facing the entity provided as an argument.
 * Copy from Minecraft.
 */
function faceEntity(ent_self, ent_b)
{
	if(ent_self != null && ent_self.IsValid() && ent_b != null)
	{
		d0 <- ent_b.GetOrigin().x - ent_self.GetOrigin().x;
		d2 <- ent_b.GetOrigin().y - ent_self.GetOrigin().y;
		d1 <- 0;
		
		if("EyePosition" in ent_self)
			d1 = ent_b.GetOrigin().z - ent_self.EyePosition().z + 50;
		else
			d1 = ent_b.GetOrigin().z - ent_self.GetOrigin().z;

		d3 <- sqrt(d0 * d0 + d2 * d2);
		f <- atan2(d2, d0) * (180 / PI) - 90;
		f1 <- -atan2(d1, d3) * (180 / PI);
		rotationPitch <- updateRotation(0, f1, 90);
		rotationYaw <- updateRotation(0, f);
	
		qAn <- QAngle(rotationPitch, rotationYaw, 0);
		return ::VSLib.Utils.VectorFromQAngle(qAn);
	}
	else if(ent_self != null && ent_self.IsValid() && "EyeAngles" in ent_self)
		return ::VSLib.Utils.VectorFromQAngle(ent_self.EyeAngles());
	else 
		return null;
}
::faceEntity <- faceEntity;

function faceEntityCorrect(ent_self, ent_b, height = 62)
{
	if(ent_self != null && VSLib.Entity(ent_self).IsAlive() && ent_b != null)
	{
		d0 <- ent_b.GetOrigin().x - ent_self.GetOrigin().x;
		d2 <- ent_b.GetOrigin().y - ent_self.GetOrigin().y;
		d1 <- 0;
		if("EyePosition" in ent_b && "EyePosition" in ent_self )
			d1 = ent_b.EyePosition().z - ent_self.EyePosition().z;
		else if("EyePosition" in ent_self )
			d1 = ent_b.GetOrigin().z + height - ent_self.EyePosition().z;
		else if("EyePosition" in ent_b )
			d1 = ent_b.EyePosition().z - ent_self.GetOrigin().z + height ;
		else
			d1 = ent_b.GetOrigin().z + height - ent_self.EyePosition().z;

		d3 <- sqrt(d0 * d0 + d2 * d2);
		f <- atan2(d2, d0) * (180 / PI);
		f1 <- -atan2(d1, d3) * (180 / PI);
		rotationPitch <- updateRotation(0, f1, 90);
		rotationYaw <- updateRotation(0, f);
	
		qAn <- QAngle(rotationPitch, rotationYaw, 0);
		
		return ::VSLib.Utils.VectorFromQAngle(qAn);
	}
	else if(ent_self != null && ent_self.IsValid() && "EyeAngles" in ent_self)
		return ::VSLib.Utils.VectorFromQAngle(ent_self.EyeAngles());
	else 
		return null;
}
::faceEntityCorrect <- faceEntityCorrect;

/**
 * Arguments: current rotation, intended rotation, max increment.
 */
function updateRotation(angle, targetAngle, maxin = 360)
{
	value <- targetAngle - angle % 360;

	if (value >= 180)
	{
		value -= 360;
	}

	if (value < -180)
	{
		value += 360;
	}
	
	if (value > maxin)
	{
		value = maxin;
	}

	if (value < -maxin)
	{
		value = -maxin;
	}
	
	value <- angle + value;
	
	return value;
}
	
::updateRotation <- updateRotation;

function resetAllBots(args)
{
	playerSet <- null;
		
	while(playerSet = Entities.FindByClassname(playerSet, "player"))
	{
		if(VSLib.Player(playerSet).IsPlayerEntityValid() && playerSet.IsSurvivor() && IsPlayerABot(playerSet))
		{
			BotReset(playerSet);
			NetProps.SetPropFloat(playerSet, "m_flLaggedMovementValue", 1.25);
			playerSet.SetFriction(1.25);
			printl("[Bot AI] Reset " + getPlayerBaseName(playerSet));
		}
	}

	Target <- null;
		
	while(Target = Entities.FindByClassname(Target, "point_prop_use_target"))
	{
		IsGascanTargetHere = true;
	}
	
	while(Target = Entities.FindByClassname(Target, "math_counter"))
	{
		HasMathCount = true;
	}
	
	MapName = SessionState.MapName.tolower();
}
::resetAllBots <- resetAllBots;

function adjustBotsUpdateRate(args)
{
	playerSet <- null;
	while(playerSet = Entities.FindByClassname(playerSet, "player"))
	{
		if(VSLib.Player(playerSet).IsPlayerEntityValid() && playerSet.IsSurvivor() && IsPlayerABot(playerSet))
		{
			distan <- 1500;
			OtherPlayer <- null;
			
			while(OtherPlayer = Entities.FindByClassname(OtherPlayer, "player"))
			{
				if(VSLib.Player(OtherPlayer).IsPlayerEntityValid() && OtherPlayer.IsSurvivor() && !IsPlayerABot(OtherPlayer))
				{
					if(distanceof(playerSet.GetOrigin(), OtherPlayer.GetOrigin()) < distan)
						distan = distanceof(playerSet.GetOrigin(), OtherPlayer.GetOrigin());
				}
			}
			
			if(distan > 600)
			{
				NetProps.SetPropFloat(playerSet, "m_flLaggedMovementValue", 1.75);
				playerSet.SetFriction(1.7);
			}
			else if(distan < 200)
			{
				NetProps.SetPropFloat(playerSet, "m_flLaggedMovementValue", 1.25);
				playerSet.SetFriction(1.25);
			}
		}
	}
}
::adjustBotsUpdateRate <- adjustBotsUpdateRate;

function locateUseTarget(args)
{
	if(!IsGascanTargetHere || UseTarget != null)
		return;
	
	notBotPlayerBoolean <- true;
	notBotPlayer <- null;
	while(notBotPlayer = Entities.FindByClassname(notBotPlayer, "player"))
	{
		if(VSLib.Player(notBotPlayer).IsPlayerEntityValid() && notBotPlayer.IsSurvivor() && !IsPlayerABot(notBotPlayer) && NetProps.GetPropInt(notBotPlayer, "m_iTeamNum") != 1 && !notBotPlayer.IsDead())
		{
			notBotPlayerBoolean = false;
			if(VSLib.Entity(notBotPlayer).IsPressingUse() || VSLib.Player(notBotPlayer).HasItem(BotsNeedToFind))
			{
				target <- null;
				while (target = Entities.FindByClassnameWithin(target, "point_prop_use_target", notBotPlayer.GetOrigin(), 150)) 
				{
					if(NetProps.GetPropInt(target, "m_spawnflags") == 1)
					{
						UseTarget = target;
						printl("[Bot AI] Located target at " + UseTarget.GetOrigin());
					}
				}
			}
		}
	}
	
	if(!notBotPlayerBoolean)
		return;
		
	playerSet <- null;
		
	while(playerSet = Entities.FindByClassname(playerSet, "player"))
	{
		if(VSLib.Player(playerSet).IsPlayerEntityValid() && playerSet.IsSurvivor() && IsPlayerABot(playerSet))
		{
			target <- null;
			while (target = Entities.FindByClassnameWithin(target, "point_prop_use_target", playerSet.GetOrigin(), 300)) 
			{
				if(NetProps.GetPropInt(target, "m_spawnflags") == 1)
				{
					UseTarget = target;
					printl("[Bot AI]Located target at " + UseTarget.GetOrigin());
					return;
				}
			}
		}
	}
}
::locateUseTarget <- locateUseTarget;

function countPlayer(args)
{
	if(UseTarget == null)
		return;
		
	playerCount <- 0;
	player <- null;
	while(player = Entities.FindByClassname(player, "player"))
	{
		if(VSLib.Player(player).IsPlayerEntityValid() && player.IsSurvivor() && NetProps.GetPropInt(player, "m_iTeamNum") != 1 && !player.IsDead())
		{
			playerCount++;
		}
	}
	
	playerAmount = playerCount;
}
::countPlayer <- countPlayer;

function tryTakeGasCan(args)
{
	if(UseTarget == null || HasTank)
		return;

	playerPickGas <- 0;
	gas <- null;
	hasGasCan <- false;
	while (gas = Entities.FindByClassname(gas, BotsNeedToFind))
	{
		hasGasCan = true;
	}
	
	display <- null;
	while(display = Entities.FindByClassname(display, "terror_gamerules"))
	{
		if(display.IsValid() && NetProps.GetPropInt(display, "terror_gamerules_data.m_iScavengeTeamScore") >= NetProps.GetPropInt(display, "terror_gamerules_data.m_nScavengeItemsGoal"))
			return;
	}
	
	if(!hasGasCan)
	{
		return;
	}
	
	playerSet <- null;
	while(playerSet = Entities.FindByClassname(playerSet, "player"))
	{
		if(VSLib.Player(playerSet).IsPlayerEntityValid() && playerSet.IsSurvivor() && !playerSet.IsDead())
		{
			if(!IsPlayerABot(playerSet))
			{
				playerPickGas++;
				continue;
			}
		}
	}
	
	botSet <- null;
	while(botSet = Entities.FindByClassname(botSet, "player"))
	{
		if(VSLib.Player(botSet).IsPlayerEntityValid() && botSet.IsSurvivor() && !botSet.IsDead())
		{
			if(IsPlayerABot(botSet))
			{
				if(playerPickGas > 1)
					BotTryTraceGascan(botSet, 200);
				else
					BotTryTraceGascan(botSet);
			
				if(VSLib.Player(botSet).HasItem(BotsNeedToFind))
					BotGoToUseTarget(botSet);
				playerPickGas++;
			}
		}
	}
}
::tryTakeGasCan <- tryTakeGasCan;

function BotUseGasCan(bot, gascan)
{
	if(!VSLib.Player(bot).IsInCombat() && VSLib.Player(bot).HasItem(BotsNeedToFind))
	{
		DoEntFire("!self", "Use", "", 0, bot, gascan);
	}
}
::BotUseGasCan <- BotUseGasCan;

function BotTakeGasCan(bot, gascan)
{
	if(!VSLib.Player(bot).IsInCombat() && !VSLib.Player(bot).HasItem(BotsNeedToFind))
	{
		DoEntFire("!self", "Use", "", 0, bot, gascan);
	}
}
::BotTakeGasCan <- BotTakeGasCan;

function BotGoToUseTarget(bot)
{
	if(!VSLib.Player(bot).IsInCombat() && UseTarget != null && !HasTank)
	{
		BotMove(bot, UseTarget);
	}
}
::BotGoToUseTarget <- BotGoToUseTarget;

function BotTryTraceGascan(bot, maxdistance = 4000)
{
	if(!VSLib.Player(bot).IsInCombat() && !VSLib.Entity(bot).IsPressingAttack() && !VSLib.Entity(bot).IsPressingUse() && !VSLib.Entity(bot).IsPressingShove() && !VSLib.Player(bot).HasItem(BotsNeedToFind) && UseTarget != null)
	{
		foreach(botclass in BotTab)
		{
			if(botclass != null && botclass.GetBot() == bot)
			{
				if(botclass.GetGasCan() != null && botclass.GetGasCan().IsValid() && botclass.GetGasCan().GetOwnerEntity() == null)
				{
					BotMove(bot, botclass.GetGasCan());
				
					if(distanceof(bot.GetOrigin(), botclass.GetGasCan().GetOrigin()) < 100)
					{
						BotTakeGasCan(bot, botclass.GetGasCan());
						BotGoToUseTarget(bot);
					}
					
					return;
				}
				else
				{
					botclass.Clear();
					return;
				}
			}
		}
		
		cloest <- null;
		distance <- 5000;
		while (GasTryFind = Entities.FindByClassnameWithin(GasTryFind, BotsNeedToFind, bot.GetOrigin(), maxdistance)) 
		{
			if(GasTryFind.GetOwnerEntity() == null && distanceof(bot.GetOrigin(), GasTryFind.GetOrigin()) < distance)
			{
				distance = distanceof(bot.GetOrigin(), GasTryFind.GetOrigin());
				cloest = GasTryFind;
			}
		}
		
		if(cloest != null)
		{
			//if(!HasMathCount && MapName != "c1m4_atrium" && MapName != "c6m3_port")
			//{
				if(distanceof(cloest.GetOrigin(), UseTarget.GetOrigin()) < 200)
					return;
			//}
			printl("[Bot AI] Found gas can " + cloest);
			BotTab[++BotFindingNum] <- BotLinkedGas(bot, cloest);
				
			BotMove(bot, cloest);
				
			if(distanceof(bot.GetOrigin(), cloest.GetOrigin()) < 100)
			{
				BotTakeGasCan(bot, cloest);
				BotGoToUseTarget(playerSet);
			}
				
			return;
		}
	}
}
::BotTryTraceGascan <- BotTryTraceGascan;

function BotFillGasCan(args)
{
	if(UseTarget == null)
		return;

	player <- null;
	while(player = Entities.FindByClassname(player, "player"))
	{
		if(VSLib.Player(player).IsPlayerEntityValid() && player.IsSurvivor() && NetProps.GetPropInt(player, "m_iTeamNum") != 1 && !player.IsDead())
		{
			if(!IsPlayerABot(player) && VSLib.Entity(player).IsPressingUse() && distanceof(player.GetOrigin(), UseTarget.GetOrigin()) < 100)
			{
				return;
			}
		}
	}
	
	bot <- null;
	while(bot = Entities.FindByClassname(bot, "player"))
	{
		if(VSLib.Player(bot).IsPlayerEntityValid() && bot.IsSurvivor()&& !bot.IsDead())
		{
			if(IsPlayerABot(bot) && VSLib.Player(bot).HasItem(BotsNeedToFind) && distanceof(bot.GetOrigin(), UseTarget.GetOrigin()) < 200)
			{
				if(HasMathCount)
				{
					local score = 0;
					display <- null;
					while(display = Entities.FindByClassname(display, "terror_gamerules"))
					{
						if(display.IsValid())
						{
							score = NetProps.GetPropInt(display, "terror_gamerules_data.m_iScavengeTeamScore") + 1;
							NetProps.SetPropInt(display, "terror_gamerules_data.m_iScavengeTeamScore", score);
						}
					}

					counter <- null;
					while(counter = Entities.FindByClassname(counter, "math_counter"))
					{
						if(counter.IsValid())
						{
							DoEntFire("!self", "Add", "1", 0, null, counter);
						}
					}
				
					removeItem(bot, BotsNeedToFind);
					foreach(botclass in BotTab)
					{
						if(botclass != null && botclass.GetBot() == bot)
						{
							botclass.Clear();
						}
					}
					
					//if((MapName == "c1m4_atrium" && score == 13) || (MapName == "c6m3_port" && score == 16))
					//{
						//VSLib.Utils.TriggerRescue();
					//}
				}
				else
				{
					VSLib.Player(bot).DropPickup();
					foreach(botclass in BotTab)
					{
						if(botclass != null && botclass.GetBot() == bot)
						{
							botclass.Clear();
						}
					}
				}
				BotReset(bot);
				return;
			}
		}
	}
}

function updateBotFireState( args )
{
	player <- null;
	Shot <- false;
	HasWitch <- false;
	HasPlayer <- false;
	
	while(player = Entities.FindByClassname(player, "player"))
	{
		OtherPlayer <- null;
		while(OtherPlayer = Entities.FindByClassname(OtherPlayer, "player"))
		{
			if(VSLib.Player(OtherPlayer).IsPlayerEntityValid() && OtherPlayer.IsSurvivor() && OtherPlayer.IsIncapacitated() && distanceof(OtherPlayer.GetOrigin(), player.GetOrigin()) < 100)
			{
				HasPlayer = true;
			}
		}
		
		Witch <- null;
		while(Witch = Entities.FindByClassname(Witch, "witch"))
		{
			if(Witch.IsValid() && VSLib.Entity(Witch).IsAlive() && CanSeeOtherEntity(player, Witch, 20))
			{
				WitchState <- NetProps.GetPropInt(Witch, "m_nSequence");
				if(WitchState != ANIM_SITTING_CRY && WitchState != ANIM_SITTING_STARTLED && WitchState != ANIM_SITTING_AGGRO && WitchState != ANIM_WALK && WitchState != ANIM_WANDER_WALK)
				{
					
				}
				else
					HasWitch = true;
			}
		}
		
		if(VSLib.Player(player).IsPlayerEntityValid() && player.IsSurvivor() && IsPlayerABot(player) && !player.IsDead())
		{
			if (!player.IsValid())
			{
				continue;
			}
	
			if (!("EyeAngles" in player))
			{
				continue;
			}
	
			local startPt = player.EyePosition();
			local endPt = startPt + player.EyeAngles().Forward().Scale(999999);
	
			local m_trace = { start = startPt, end = endPt, ignore = player, mask = g_MapScript.TRACE_MASK_SHOT };
			TraceLine(m_trace);
	
			if (!m_trace.hit || m_trace.enthit == null || m_trace.enthit == player)
				continue;
	
			if (m_trace.enthit.GetClassname() == "worldspawn" || !m_trace.enthit.IsValid())
				continue;

			if((((AllInfectedAmount > 20 || UseTarget != null) && m_trace.enthit.GetClassname() == "infected") || (m_trace.enthit.GetClassname() == "player" && m_trace.enthit.GetZombieType() != 9 && m_trace.enthit.GetZombieType() != 7)) && VSLib.Entity(m_trace.enthit).IsAlive())
				Shot = true;
				
			if(m_trace.enthit.GetClassname() == "player" && m_trace.enthit.IsSurvivor() && m_trace.enthit.IsIncapacitated())
				HasPlayer = true;
				
			if(VSLib.Entity(m_trace.enthit).IsAlive() && m_trace.enthit.GetClassname() == "witch")
			{
				WitchState <- NetProps.GetPropInt(m_trace.enthit, "m_nSequence");
				if(WitchState != ANIM_SITTING_CRY && WitchState != ANIM_SITTING_STARTLED && WitchState != ANIM_SITTING_AGGRO && WitchState != ANIM_WALK && WitchState != ANIM_WANDER_WALK)
					Shot = true;
				else
					HasWitch = true;
			}
		}
	}
	
	if(Shot && !HasWitch && !HasPlayer)
		Convars.SetValue( "sb_open_fire", 1 );
	else
		Convars.SetValue( "sb_open_fire", 0 );
}

function savePlayerFromSmoker( args )
{
	smoker <- null;
	local victimList = {};
	local i = -1;
	
	while(smoker = Entities.FindByClassname(smoker, "player"))
	{
		if(VSLib.Player(smoker).IsPlayerEntityValid() && smoker.GetZombieType() == 1 && !smoker.IsDead())
		{
			if(NetProps.GetPropInt(smoker, "m_tongueVictim") != -1)
			{
				local player = GetPlayerFromUserID(NetProps.GetPropInt(smoker, "m_tongueVictim"));
				if(player != null && player.IsValid() && player.IsSurvivor() && !player.IsDead())
				victimList[++i] <- player;
			}
		}
	}
	
	foreach(victim in victimList)
	{
		if(victim != null && victim.IsValid() && victim.IsSurvivor() && !victim.IsDead())
		{
			local dis = 1200;
			local OtherPlayer = null;
			local botCloest = null;
			while(OtherPlayer = Entities.FindByClassname(OtherPlayer, "player"))
			{
				if(VSLib.Player(OtherPlayer).IsPlayerEntityValid() && OtherPlayer.IsSurvivor() && IsPlayerABot(OtherPlayer) && !OtherPlayer.IsDead() && !OtherPlayer.IsIncapacitated())
				{
					if(botCloest == null || distanceof(OtherPlayer.GetOrigin(), victim.GetOrigin()) < dis)
					{
						botCloest = OtherPlayer;
						dis = distanceof(OtherPlayer.GetOrigin(), victim.GetOrigin());
					}
				}
			}
			
			if(botCloest != null)
			{
				throwVec <- null;
						
				if(CanSeeOtherEntityWithoutLocation(botCloest, victim))
				{
					throwVec = faceEntityCorrect(botCloest, victim);
				}

				if(throwVec != null)
				{
					NetProps.SetPropFloat(botCloest, "m_flLaggedMovementValue", 2.25);
					botCloest.SetFriction(2.25);
					VSLib.Entity(botCloest).SetForwardVector(throwVec);
					if(!botCloest.IsIncapacitated())
						botCloest.ApplyAbsVelocityImpulse(Vector(-throwVec.y * 200, 0, throwVec.z * 200));
				}
			}
		}
	}
}

function InterceptChat_OnBotUpdate(message, speaker)
{
	if(!::AdminSystem.IsPrivileged(VSLib.Player(speaker)))
		return;
	
	local index = message.find("!morebot");

	if(index != null && index == 10)
	{
		num <- RandomInt(4, 7);
		if(NetProps.GetPropInt(speaker, "m_iTeamNum") == 1)
		{
			if(VSLib.Utils.GetSurvivorSet() == 1)
			{
				player <- null;
				while(player = Entities.FindByClassname(player, "player"))
				{
					if(VSLib.Player(player).IsPlayerEntityValid() && player.IsSurvivor() && !player.IsDead() && NetProps.GetPropInt(player, "m_survivorCharacter") == 1)
					{
						NetProps.SetPropInt(player, "m_survivorCharacter", 0);
					}
				}
			}

			player <- null;
			while(player = Entities.FindByClassname(player, "player"))
			{
				if(VSLib.Player(player).IsPlayerEntityValid() && player.IsSurvivor() && !player.IsDead() && NetProps.GetPropInt(speaker, "m_iTeamNum") != 1)
				{
					printl("[Bot AI] Try Spawn Bot At " + player.GetOrigin());
					VSLib.Utils.SpawnSurvivor(5, player.GetOrigin(), QAngle( 0, 0, 0 ), 9);
					return;
				}
			}
		}
		else
		{
			if(VSLib.Utils.GetSurvivorSet() == 1)
			{
				player <- null;
				while(player = Entities.FindByClassname(player, "player"))
				{
					if(VSLib.Player(player).IsPlayerEntityValid() && player.IsSurvivor() && !player.IsDead() && NetProps.GetPropInt(player, "m_survivorCharacter") == 1)
					{
						NetProps.SetPropInt(player, "m_survivorCharacter", 0);
					}
				}
			}
			printl("[Bot AI] Try Spawn Bot At " + speaker.GetOrigin());
			VSLib.Utils.SpawnSurvivor(5, speaker.GetOrigin(), QAngle( 0, 0, 0 ), 9);
		}
	}
}

// function OnGameEvent_player_hurt(event)
function Notifications::OnHurt::OnBotUpdate(vic, ack, event)
{
	local player = GetPlayerFromUserID(event.userid);
	if(IsPlayerABot(player) && UseTarget != null && !VSLib.Player(player).IsInCombat())
	{
		local attacker = GetPlayerFromUserID(event.attacker);
		if("GetClassname" in attacker && (attacker.GetClassname() == "infected" || (attacker.GetClassname() == "player" && attacker.GetZombieType() != 9)))
		{
			BotReset(player);
			VSLib.Player(player).DropPickup();
			VSLib.Entity(player).SetTarget(attacker);
			BotAttack(player, attacker);
		}
	}
}

// function OnGameEvent_player_shoved(event)
function Notifications::OnPlayerShoved::OnBotUpdate(vic, ack, event)
{
	local p = GetPlayerFromUserID(event.userid);
	local player = GetPlayerFromUserID(event.attacker);
	if(p.IsSurvivor() && IsPlayerABot(p))
	{
		if(player != null && VSLib.Entity(player).IsPressingDuck() && VSLib.Entity(player).IsPressingJump())
			p.SetOrigin(player.GetOrigin());
		BotReset(p);
		
		local p = GetPlayerFromUserID(event.userid);
		
		if(NetProps.GetPropInt(p, "m_reviveOwner") != -1)
		{
			local player1 = GetPlayerFromUserID(NetProps.GetPropInt(p, "m_reviveOwner"));
			if(player1 != null && player1.IsValid())
			{
				NetProps.SetPropInt(player1, "m_reviveOwner", -1);
				NetProps.SetPropInt(player1, "m_reviveTarget", -1);
			}
		}
		
		if(NetProps.GetPropInt(p, "m_reviveTarget") != -1)
		{
			local player2 = GetPlayerFromUserID(NetProps.GetPropInt(p, "m_reviveTarget"));
			if(player2 != null && player2.IsValid())
			{
				NetProps.SetPropInt(player2, "m_reviveOwner", -1);
				NetProps.SetPropInt(player2, "m_reviveTarget", -1);
			}
		}
		
		NetProps.SetPropInt(p, "m_reviveOwner", -1);
		NetProps.SetPropInt(p, "m_reviveTarget", -1);
		printl("[Bot AI] Reset " + getPlayerBaseName(p));
	}
}

// function OnGameEvent_item_pickup(event)
function Notifications::OnItemPickup::OnBotUpdate(ply, wpn, event)
{
	local p = GetPlayerFromUserID(event.userid);
	local item = event.item;
	if((item == "first_aid_kit_spawn" || item == "first_aid_kit" || item == "weapon_first_aid_kit_spawn" || item == "weapon_first_aid_kit" )&& p.IsSurvivor() && IsPlayerABot(p))
		doAmmoUpgrades(p);
}

// function OnGameEvent_weapon_fire(event)
function Notifications::OnWeaponFire::OnBotUpdate(ply, wpn, event)
{
	local p = GetPlayerFromUserID(event.userid);
	if(p.IsSurvivor() && IsPlayerABot(p))
	{
		weapon <- p.GetActiveWeapon();
		if(weapon.GetClassname() == "weapon_pistol" || weapon.GetClassname() == "weapon_pistol_magnum")
		{
			if(NetProps.GetPropInt(weapon, "m_iClip1") < 4)
				NetProps.SetPropInt(weapon, "m_iClip1", 15);
		}
	}
}

// function OnGameEvent_round_start(event)
function Notifications::OnRoundBegin::OnBotUpdate(event)
{
	printl("[Bot AI] Loading timers...");
	::VSLib.EasyLogic.AddInterceptChat(::g_OnBotUpdateScript.InterceptChat_OnBotUpdate);
	
	printl("[Bot AI] Add Timer " + Timers.AddTimer(0.1, true, ::g_OnBotUpdateScript.AvoidDanger));
	// printl("[Bot AI] Add Timer " + Timers.AddTimer(0.1, true, ::g_OnBotUpdateScript.updateBotFireState));
	// printl("[Bot AI] Add Timer " + Timers.AddTimer(0.1, true, ::g_OnBotUpdateScript.hitInfected));
	printl("[Bot AI] Add Timer " + Timers.AddTimer(0.1, true, ::g_OnBotUpdateScript.searchButtonTimed));
	// printl("[Bot AI] Add Timer " + Timers.AddTimer(0.1, true, searchVomitjar));
	// printl("[Bot AI] Add Timer " + Timers.AddTimer(0.1, true, searchMolotov));
	// printl("[Bot AI] Add Timer " + Timers.AddTimer(0.1, true, searchPipe));

	printl("[Bot AI] Add Timer " + Timers.AddTimer(0.3, true, ::g_OnBotUpdateScript.savePlayerFromSmoker));
	
	// printl("[Bot AI] Add Timer " + Timers.AddTimer(0.5, true, searchEntity));
	
	// printl("[Bot AI] Add Timer " + Timers.AddTimer(2, true, searchBody));
	printl("[Bot AI] Add Timer " + Timers.AddTimer(2, true, ::g_OnBotUpdateScript.tryTakeGasCan));
	
	// printl("[Bot AI] Add Timer " + Timers.AddTimer(3, true, transItem));
	printl("[Bot AI] Add Timer " + Timers.AddTimer(3, true, ::g_OnBotUpdateScript.locateUseTarget));
	
	// printl("[Bot AI] Add Timer " + Timers.AddTimer(5, true, ThrowTank));
	printl("[Bot AI] Add Timer " + Timers.AddTimer(5, true, ::g_OnBotUpdateScript.searchButton));
	// printl("[Bot AI] Add Timer " + Timers.AddTimer(5, true, transKit));
	printl("[Bot AI] Add Timer " + Timers.AddTimer(5, true, ::g_OnBotUpdateScript.BotFillGasCan));
	printl("[Bot AI] Add Timer " + Timers.AddTimer(5, true, ::g_OnBotUpdateScript.adjustBotsUpdateRate));
	
	// printl("[Bot AI] Add Timer " + Timers.AddTimer(7, true, ::g_OnBotUpdateScript.doUpgrades));
	
	// printl("[Bot AI] Add Timer " + Timers.AddTimer(5, true, ::g_OnBotUpdateScript.checkToThrowGen));
	
	printl("[Bot AI] Add Timer " + Timers.AddTimer(15, false, ::g_OnBotUpdateScript.resetAllBots));
	printl("[Bot AI] Add Timer " + Timers.AddTimer(15, true, ::g_OnBotUpdateScript.countPlayer));
	printl("[Bot AI] Timers loaded.");
}

