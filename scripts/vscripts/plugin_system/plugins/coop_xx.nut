/*

编辑者：C_D.og
版本：8.3

安装:
压缩文件中有两个文件 一个meleeunlock.vpk 和 一个 .nut文件 
meleeunlock.vpk放到?:\game\Steam\steamapps\common\Left 4 Dead 2\left4dead2\addons文件夹下。
用于解锁近战。

.nut放到?:\game\Steam\steamapps\common\Left 4 Dead 2\left4dead2\scripts\vscripts文件夹下。
PS:注意修改文件名为需要建房的游戏模式 .文件可以复制为多份分别命名为不同模式。本脚本默认命名为coop

使用方法:
1.修改文件名为你需要运行游戏的模式名字:例如: 战役模式=coop.nut 生还者模式=survival.nut 写实模式=realism.nut
2.除了默认战役模式之外其他如果使用map建房【盗版】必须加后缀。map + 地图名字 + 模式名字 例如:map c2m2xxxx realism 【写实模式建房】
3.正版玩家无需考虑这些。直接大厅建房即可。注意文件名和需要建立的游戏模式一致。有些不知道模式名的可以百度。
4.编辑该文本的时候建议使用notepad++或者别的比较高级点击文本编辑器。以免发生无法修改文本或者修改后文本失效的问题。

脚本特性：
1。游戏L4D2 Cvars参数设置。包括：备用子弹数量修改，各个模式参数添加等等。开服各参数可直接添加。
2。特感数量，特感重生时间，坦克血量，小僵尸数量。静态和动态修改。
3。游戏DirectorOptions高级参数自定义。
4。由于难度提升，开局自动给予近战和t1武器。
5。拥有反伤部分。【如果没有，则代码被屏蔽】：位置：
6。击杀特感回血，附带一部分效果。 【如果没有，则代码被屏蔽】：位置：
7。多坦克，多witch。按照路程进度产生坦克。
8。解锁cs武器
9。武器伤害修改，特感伤害修改，witch伤害修改，僵尸伤害修改
10。多重补给。全部补给装备相同补给次数。
11。所有地图最终章节增加为3轮坦克攻击，一次出现只数为1，2，3。增加尸潮数量。一些图最终章可能是噩梦。
12。c7m3开一个发电机即可防守到桥下降，并且逃离。三个发电机一起开可以大大减少防守时间
*/

Msg("启用自定义战役脚本\n");
IncludeScript("VSLib");
//======================================Convars============================
//预加载所有生还者模型。为了DirectorOptions中cm_NoSurvivorBots为1的时候，第二个以上玩家加入后过图容易出现model没有加载的问题
Convars.SetValue( "precache_all_survivors", "1" );
//作死向，多tank。基本固定1/4路程一只坦克 但是会出现没有witch的情况。witch通过手动与坦克一起生产
//Convars.SetValue( "director_force_tank", "1" );
//不允许坦克自杀 在某些时候玩家会盲点卡坦克，但是坦克不会自杀。[最终章坦克卡住后容易出现无法继续下一个环节的bug：建议不开启]
//Convars.SetValue( "tank_stuck_failsafe", "0" );
//如果出现联机的时候提示server is enforing consistency for this file：xxxx 请开启为0.原因是cs武器解锁部分玩家会出现
//Convars.SetValue( "sv_consistency", "0" );
//witch一命击杀。
Convars.SetValue( "z_witch_always_kills", "0" );
//设置备用弹药量
Convars.SetValue( "ammo_shotgun_max", "65" );
Convars.SetValue( "ammo_autoshotgun_max", "90" );
//机枪
Convars.SetValue( "ammo_smg_max", "650" );
Convars.SetValue( "ammo_assaultrifle_max", "650" );
//猎枪
Convars.SetValue( "ammo_huntingrifle_max", "150" );
//连狙
Convars.SetValue( "ammo_sniperrifle_max", "180" );
//榴弹
Convars.SetValue( "ammo_grenadelauncher_max", "30" );
//难度。即使在游戏中修改。只要下一个roundstart就会被刷新为该难度
//Convars.SetValue( "z_difficulty", "Impossible" );
//药包可以在多少血量以内使用。默认100.超过99无法打包
//Convars.SetValue( "first_aid_kit_max_heal", "199" );
//药瓶可以在多少血量以内使用。默认100.超过99无法吃药
//Convars.SetValue( "pain_pills_health_threshold ", "199" );
//=====================================参数===================================================
//是否修改c9m1玩家开机关吃药穿越火墙，其他部分地图玩家卡盲点卡特感。
::MAPFIX <- false;
//设置枪械和补给拾取次数。详细拾取次数跳到WEAPONTOONE代码中修改
::WEAPONTOONE <- true;
//对玩家伤害处理【反伤= 2 无队伤 = 1[谁发火谁受伤] 默认 = 0 or other】
::SDAMAGEOVER <- 0;
//击杀回血 血量设置请跳下去自己修改
::KILLRECHEL <- false;
//特感变动数量[根据实际人数增减]
::COEFFICIENT_PZ  <- 0 ;
//特感基本数量
::CARDINALNUMBER_PZ <- 2 ;
//坦克可变血量[根据实际人数增减]
::COEFFICIENT_TANK <- 0 ;
//坦克基本血量
//[代码中添加根据难度调控血量：计算公式=COEFFICIENT_TANK*玩家个数+ CARDINALNUMBER_TANK+难度血量] 难度血量：易2000 普4000 高6000 专8000
::CARDINALNUMBER_TANK <- 0 ;
//特感基本复活时间
::CARDINALNUMBER_RESPAWN <- 15 ;
//特感可变复活时间[根据实际人数减少]
::COEFFICIENT_RESPAWN <- 0 ;
//僵尸可变数量[根据实际人数增减]
::COEFFICIENT_ZOMBIE <- 0 ;
//僵尸基本数量
::CARDINALNUMBER_ZOMBIE <- 45 ;

ERROR <- -1 ;
PANIC <- 0 ;
TANK <- 1 ;
DELAY <- 2 ;
SCRIPTED <- 3 ;
::_TankHealth  <- 0;
::_rhealth <- {};
::PlayerZombie <-{};
::PlayerRank<-{};
::tankhealthmsg <- {};
::prop_dynamic <- {};
::HintCurrent <- {};
::OneAllDamage <- {};
::HandleTimer <- {};
::survivors <-{
   Coach = "models/survivors/survivor_coach.mdl",
   Ellis = "models/survivors/survivor_mechanic.mdl",
   Nick = "models/survivors/survivor_gambler.mdl",
   Rochelle = "models/survivors/survivor_producer.mdl",
   Zoey = "models/survivors/survivor_teenangst.mdl",
   Francis = "models/survivors/survivor_biker.mdl",
   Louis = "models/survivors/survivor_manager.mdl",
   Bill = "models/survivors/survivor_namvet.mdl"
}
::weaponsNoReGive <-
{
	weapon_smg = 0
	weapon_pumpshotgun = 0
	weapon_autoshotgun = 0
	weapon_rifle = 0
	weapon_hunting_rifle = 0
	weapon_smg_silenced = 0
	weapon_shotgun_chrome = 0
	weapon_rifle_desert = 0
	weapon_sniper_military = 0
	weapon_shotgun_spas = 0
	weapon_rifle_ak47 = 0
	weapon_smg_mp5 = 0      
	weapon_rifle_sg552 = 0      
	weapon_sniper_awp = 0   
	weapon_sniper_scout = 0
}

function Precache()
{
	//Utils.PrecacheCSSWeapons();
	Utils.PrecacheSurvivors();
	Utils.PrecacheModel("models/editor/axis_helper_thick.mdl");
	Utils.PrecacheModel("models/infected/witch.mdl");
	Utils.PrecacheModel("models/infected/witch_bride.mdl");
}

//======================================Director==================================================
DirectorOptions <-
{
	ActiveChallenge = 1	
	//以下为该脚本动态值。上面flag修改
	cm_SpecialRespawnInterval = 1
	cm_MaxSpecials = 14
	DominatorLimit = 14
	cm_CommonLimit = 1
	//大于6特感需要设置该值>=2 因为这个因人而异。所以没有做固定修改。喜欢一次刷2/4/5/6/7/9。。只怪。都相同的可以设置该值为2/4/5/6/7/9。。
	//cm_BaseSpecialLimit = 2
	//特感速递替换上面cm_BaseSpecialLimit参数
	SmokerLimit = 2
	BoomerLimit = 2
	HunterLimit = 2
	SpitterLimit = 2
	JockeyLimit = 2
	ChargerLimit = 2
	SpecialInitialSpawnDelayMin = 0
	SpecialInitialSpawnDelayMax = 1
	//允许坦克和witch出现后继续刷特感【false：出现witch会暂停一段时间刷特】
	ShouldAllowSpecialsWithTank = true	
	//添加坦克和witch出现后允许尸潮爆发
	//ShouldAllowMobsWithTank = true	
	EscapeSpawnTanks = true
	//开启后没有bot。有别人加入后过图可能出现模型预加载报错。
	//cm_NoSurvivorBots = 1
	//堕落生还者出现几率和出现比重 【不是很了解】
	//测试中》fallen值开启会造成c7m3坦克变成3只。每个发电机3个.一起开会刷多只坦克，大概是9只。
	//FallenSurvivorPotentialQuantity = 6
   // FallenSurvivorSpawnChance       = 0.75
	//油箱背在背上
	//GasCansOnBacks = true
	//是否出坦克和witch false=出 true=不出
	cm_ProhibitBosses = false
	//坦克攻击伤害比例。按照当前难度调整
	//TankHitDamageModifierCoop = 0.1
	cm_AllowPillConversion = 0
	//AlwaysAllowWanderers = 1
	//MobMaxPending = 30
	//SurvivorMaxIncapacitatedCount = 1
	//允许自救。前提是上面允许倒地几次。被控制后起效
	//cm_AutoReviveFromSpecialIncap = 1 
	//尸潮僵尸数量动态浮动范围
	MobMinSize = 30
	MobMaxSize = 45
	//爆头模式
	//cm_HeadshotOnly = 1
	//MobSpawnSize = ？//尸潮静态固定数量。上面两个参数会被自动屏蔽
	//不希望太变态就不要开启
/*
	MobSpawnMinTime = 25
	MobSpawnMaxTime = 45
	MobMaxPending = 20
	SustainPeakMinTime = 0
	SustainPeakMaxTime = 0
	IntensityRelaxThreshold = 0.00
	RelaxMinInterval = 0
	RelaxMaxInterval = 0
	RelaxMaxFlowTravel = 100
*/

	//设置以下值，测试中感觉,在官图中会让特感有更好的出生点
	//SPAWN_ABOVE_SURVIVORS, SPAWN_ANYWHERE, SPAWN_BEHIND_SURVIVORS, SPAWN_FAR_AWAY_FROM_SURVIVORS, SPAWN_IN_FRONT_OF_SURVIVORS, SPAWN_LARGE_VOLUME, SPAWN_NEAR_IT_VICTIM, SPAWN_NO_PREFERENCE   
	PreferredMobDirection = SPAWN_LARGE_VOLUME
	//SPAWN_SPECIALS_ANYWHERE, SPAWN_SPECIALS_IN_FRONT_OF_SURVIVORS
	PreferredSpecialDirection = SPAWN_LARGE_VOLUME
	//ShouldConstrainLargeVolumeSpawn = false
	//ShouldIgnoreClearStateForSpawn  = true
	//最好不要小于800.僵尸可以出生最大范围
	//ZombieSpawnRange = 1500	

	
	//cm_ShouldHurry = 1
	//开场给个矮人玩具。必须抱着进安全门否则无法通关。矮人变异模式参数
	//cm_HealingGnome = 1
	//cm_TempHealthOnly = 1
	//修改后僵尸挤在一起。或者没有僵尸。
	//WanderingZombieDensityModifier = 1.1
	//指章节上同时出现的坦克最大数量。一般用于生还者模式。限制坦克数量。
	//cm_TankLimit = 2
	TankLimit = 6
	//徘徊僵尸~指的是地图上前方刷新的各种状态的僵尸非尸潮。该值似乎只能减少不能增加。否则僵尸会一坨一坨的。
	//cm_WanderingZombieDensityModifier = 1.0
	//应该和cm_TankLimit同理
	//cm_WitchLimit = 2
	WitchLimit = 6
	//NumReservedWanderers = 200
	//TempHealthDecayRate = 0.001
	 A_CustomFinale_StageCount = 12
 
	 A_CustomFinale1 = PANIC
	 A_CustomFinaleValue1 = 2 
	 
	 A_CustomFinale2 = DELAY
	 A_CustomFinaleValue2 = 15 
 
	 A_CustomFinale3 = TANK
	 A_CustomFinaleValue3 = 2 

	 A_CustomFinale4 = DELAY
	 A_CustomFinaleValue4 = 12 
 
	 A_CustomFinale5 = PANIC
	 A_CustomFinaleValue5 = 3  
 
	 A_CustomFinale6 = DELAY
	 A_CustomFinaleValue6 = 15 
 
	 A_CustomFinale7 = TANK
	 A_CustomFinaleValue7 = 2  
	 
	 A_CustomFinale8 = DELAY
	 A_CustomFinaleValue8 = 15 
 
	 A_CustomFinale9 = PANIC
	 A_CustomFinaleValue9 = 4  
 
	 A_CustomFinale10 = DELAY
	 A_CustomFinaleValue10 = 15
 
	 A_CustomFinale11 = TANK
	 A_CustomFinaleValue11 = 2 
	 
	 A_CustomFinale12 = DELAY
	 A_CustomFinaleValue12 = 15
	//以上为实用部分参数。可以自行添加和修改
	//参考资料https://developer.valvesoftware.com/wiki/L4D2_Director_Scripts
	//替换隐藏武器。。如果不想使用。或者只想有低级武器，可以设置替换为低级武器。但是if(RandomInt(0,1))可以去掉或者或者设置RandomInt(0,1)为true		
	weaponsToConvert =
	{
		//weapon_autoshotgun = "weapon_pumpshotgun_spawn"
		//weapon_rifle_ak47 = "weapon_smg_spawn"
		//weapon_rifle_desert = "weapon_smg_spawn"
		//weapon_rifle_m60 = "weapon_smg_silenced_spawn"
		//weapon_rifle = "weapon_smg_silenced_spawn"
		//weapon_shotgun_spas =  "weapon_shotgun_chrome_spawn"
		//weapon_sniper_military = "weapon_hunting_rifle_spawn"
		//weapon_grenade_launcher = "weapon_shotgun_chrome_spawn"	
		//weapon_rifle_spawn = "weapon_smg_silenced_spawn"
		
		//weapon_defibrillator = "weapon_pain_pills_spawn"
		weapon_first_aid_kit =	"weapon_pain_pills_spawn"
		//weapon_adrenaline =	"weapon_pain_pills_spawn"
		//因为插件平台扩展组件已经包含cs武器解锁。小刀 高尔夫解锁。
		// weapon_pistol =	"weapon_pistol_magnum"
		// weapon_hunting_rifle = "weapon_sniper_scout_spawn"
		// weapon_sniper_military = "weapon_sniper_awp_spawn"
		// weapon_rifle_desert = "weapon_rifle_sg552_spawn"
		// weapon_smg = "weapon_smg_mp5_spawn"
		// weapon_smg_silenced = "weapon_smg_mp5_spawn"		
	}

	
	function ConvertWeaponSpawn( classname )
	{			
		if ( classname in weaponsToConvert )
		{
			if(classname == "weapon_first_aid_kit")
				return weaponsToConvert[classname];	
			else if(classname == "weapon_defibrillator")
				return weaponsToConvert[classname];	
			else(RandomInt(0,1))
				return weaponsToConvert[classname];	
		}	
		return 0;
	}	
	
	//去掉了电击器
	weaponsToRemove =
	{
		//weapon_first_aid_kit = 0
		//weapon_defibrillator = 0
	}

	function AllowWeaponSpawn( classname )
	{
		if ( classname in weaponsToRemove )
		{
			return false;
		}
		return true;
	}
	
//每次玩家死亡后复活会再次给予下列道具~谨慎添加加血类道具和投掷物
	DefaultItems =
	[
		"knife",
		"baseball_bat",
		"katana",
		"frying_pan",
		"cricket_bat",
		"electric_guitar",
		"tonfa",
		"machete",
		"fireaxe",
		"crowbar",
		//"riotshield",
		"golfclub",
		"pistol_magnum",
		//"pistol"
	]
	//Repeatedly called with incrementing indices. Return a string of a weapon name to make it a default item for survivors, or 0 to end the iteration.
	function GetDefaultItem(idx)
	{
		if(idx == 0)
		{
			return DefaultItems[RandomInt(0,DefaultItems.len()-1)];	
		}
		return 0;
	}	
}


//========================================================hookevent=============================================
//反伤比较特殊：
//如果受害者无敌。那么受害者可以故意，跳火里面，或者故意无视往别人枪口上冲。
//所以不设置无敌。如果有人喜欢造势，但是他绝对不会逍遥，也不会让一些人恶意利用受害者无敌的特点制造故意反伤的事情。
::ClearFun <- function(what)
{
	what.Damage(OneAllDamage[what.GetIndex()], DMG_GENERIC);
	Timers.RemoveTimer(HandleTimer[what.GetIndex()]);
	OneAllDamage[what.GetIndex()] = 0;
	HandleTimer[what.GetIndex()]= null;
}
function EasyLogic::OnDamage::player( victim, attacker, damageDone, damageTable )
{
	if (!victim || !attacker || victim.GetIndex() == attacker.GetIndex())
		return;
	
	switch(attacker.GetClassname())
	{
		
		case "infected":
		{
			return damageDone;
		}	
		case "player":
		{
			switch (attacker.GetPlayerType())
			{
				case Z_SURVIVOR:
				{		
					if(attacker.GetTeam() == victim.GetTeam() && victim.GetIndex() != attacker.GetIndex() && attacker.IsHuman() && victim.IsHuman() ) 
					{
						switch(SDAMAGEOVER)
						{
							case 1:
							{
								if(damageTable.DamageType == 268435464)
									return 0 ;	
								return 0 ;
							}
							case 2:
							{
								if(victim.IsSurvivorTrapped()) break;
								OneAllDamage[attacker.GetIndex()] += damageDone;
								if(HandleTimer[attacker.GetIndex()] == null)
									HandleTimer[attacker.GetIndex()]<- Timers.AddTimer ( 0.1, false, ClearFun,attacker);								
								break;
							}
							default:break;
						}					
					}
					if(!attacker.IsHuman() || damageTable.Weapon == null)
						return;			
					if(damageTable.Weapon.GetClassname() == "weapon_smg_mp5")
						return damageDone*2;						
					if(damageTable.Weapon.GetClassname() == "weapon_rifle_sg552")
						return damageDone*2;			
					if(damageTable.Weapon.GetClassname() == "weapon_sniper_awp")
						return damageDone*2;						
					if(damageTable.Weapon.GetClassname() == "weapon_sniper_scout")
						return damageDone*2;								
					if(damageTable.Weapon.GetClassname() == "weapon_smg")
						return damageDone;						
					if(damageTable.Weapon.GetClassname() == "weapon_smg_silenced")
						return damageDone;				
					if(damageTable.Weapon.GetClassname() == "weapon_pumpshotgun")
						return damageDone;						
					if(damageTable.Weapon.GetClassname() == "weapon_shotgun_chrome")
						return damageDone;
					if(damageTable.Weapon.GetClassname() == "weapon_pistol_magnum")
						return damageDone;						
					if(damageTable.Weapon.GetClassname() == "weapon_pistol")
						return damageDone;				
					if(damageTable.Weapon.GetClassname() == "weapon_hunting_rifle")
						return damageDone;						
					if(damageTable.Weapon.GetClassname() == "weapon_rifle_ak47")
						return damageDone;
					if(damageTable.Weapon.GetClassname() == "weapon_rifle")
						return damageDone;						
					if(damageTable.Weapon.GetClassname() == "weapon_rifle_desert")
						return damageDone;				
					if(damageTable.Weapon.GetClassname() == "weapon_rifle_m60")
						return damageDone;						
					if(damageTable.Weapon.GetClassname() == "weapon_shotgun_spas")
						return damageDone;
					if(damageTable.Weapon.GetClassname() == "weapon_autoshotgun")
						return damageDone;						
					if(damageTable.Weapon.GetClassname() == "weapon_sniper_military")
						return damageDone;				
					if(damageTable.Weapon.GetClassname() == "weapon_melee")
						return damageDone;
				}
				case Z_SMOKER:
					return damageDone;
				case Z_BOOMER:
					return damageDone;
				case Z_HUNTER:
					return damageDone;
				case Z_SPITTER:
					return damageDone;
				case Z_JOCKEY:
					return damageDone;
				case Z_CHARGER:
					return damageDone;
				case Z_WITCH:
					return damageDone;	
				case Z_TANK:
					return damageDone*2;						
			}
		}
		case "witch":
		{
			return Utils.GetRandNumber(50, 200);
		}
	}
}


function OnGameEvent_player_team(params)
{
	local user = null;
	local disconnect = false;
	local Player = null;
	
	if (params.rawin("userid"))
	{
		user = params["userid"];
		Player = GetPlayerFromUserID(user); 
		if(!Player.GetClassname() == "player" || !Player.IsSurvivor() || IsPlayerABot(Player)) return;
		disconnect = params["disconnect"];
		if(disconnect)
		{
			PlayerZombie[Player.GetEntityIndex()] = 0;
			OneAllDamage[Player.GetEntityIndex()] = 0;
			HandleTimer[Player.GetEntityIndex()] = null;
		}
	}
}


function Notifications::OnDeath::PlayerDeath ( victim, attacker, params)
{
	if (!victim || !attacker || victim.GetIndex() == attacker.GetIndex())
		return;
	switch(victim.GetClassname())
	{
		case "infected":
		{
			break;
		}	
		case "player":
		{
				
			if(victim.GetTeam() == INFECTED && attacker.GetTeam() == SURVIVORS && !IsPlayerABot(attacker))
			{
				PlayerZombie[attacker.GetIndex()]++;		
				AttachParticle(attacker,"achieved", 5.0);
				if(KILLRECHEL && !attacker.IsIncapacitated())
				{
					if(Player(victim).GetPlayerType() == Z_TANK)
					{
						foreach(surs in Players.AliveSurvivors	())
						{
							surs.SetHealth(surs.GetRawHealth()+ Utils.GetRandNumber(3, 10));
							Utils.FadeScreen(attacker, 100, 200, 50, 100, 2.0, 2.0,true,true);
						}
					}
					else if(params["headshot"])
					{
						attacker.Speak("nicejob01");	
						attacker.SetHealth(attacker.GetRawHealth()+ Utils.GetRandNumber(5, 15));
						Utils.FadeScreen(attacker, 100, 200, 50, 100, 2.0, 2.0,true,true);					
					}	
					else
					{
						attacker.SetHealth(attacker.GetRawHealth()+ Utils.GetRandNumber(2, 8));
						Utils.FadeScreen(attacker, 100, 200, 50, 100, 2.0, 2.0,true,true);
					}
				}
			}
			break;
		}
		case "witch":
		{
			if(attacker.GetTeam() == SURVIVORS && !IsPlayerABot(attacker))
			{
				Utils.ForcePanicEvent(); 
				PlayerZombie[attacker.GetIndex()]++;		
				AttachParticle(attacker,"achieved", 5.0);
				if(KILLRECHEL && !attacker.IsIncapacitated())
				{
					attacker.SetHealth(attacker.GetRawHealth()+ Utils.GetRandNumber(3,10));
					Utils.FadeScreen(attacker, 100, 200, 50, 100, 2.0, 2.0,true,true);					
				}			
			}
			break;
		}	
	}

}

function OnActivate()
{
	for(local i=0;i<=32;i+=1)
	{
		PlayerZombie[i] <- 0;
		OneAllDamage[i] <- 0;
		HandleTimer[i] <- null;	
		PlayerRank[i]<-"";		
	}	
	
	LogicRelay <- SpawnEntityFromTable("logic_relay", { targetname = "cdog_relay",spawnflags = "1"});
	EntFire("cdog_relay", "Trigger","",0.3);		
	LogicRelay.ValidateScriptScope();
	local RelayScope = LogicRelay.GetScriptScope();
	LogicRelay.ConnectOutput("OnTrigger","Relaylogic");
	RelayScope.Relaylogic <- function()
	{
		foreach(m in ::survivors)
		{
			player <- Entities.FindByModel(null, m)
			local boolen = true;
			if(player)
			{			
				if(player.IsSurvivor())
				{
					child <- player.FirstMoveChild()
					if (child) 
					{
						while (child)
						{
							if ( child.GetClassname() in ::weaponsNoReGive)
							{
								boolen = false;
								break;
							}
							child = child.NextMovePeer();
						}					  	
					}
					if(boolen)	
					{
						switch(RandomInt(1,4))
						{
							case 1:
								player.GiveItem("weapon_smg");	
								break;
							case 2:
								player.GiveItem("weapon_smg_silenced");	
								break;
							case 3:
								player.GiveItem("weapon_pumpshotgun");	
								break;
							case 4:		
								player.GiveItem("weapon_shotgun_chrome");	
								break;					
						}					
					}
				}				
			}
		}
		EntFire("cdog_relay", "Kill");		
	}	
}



function Notifications::OnModeStart::GameStart(gamemode)
{
	local hudtip = HUD.Item("vscript8.3:输入!rank查看排行菜单");
	hudtip.AttachTo(HUD_TICKER);

	//hudtimer.ChangeHUDNative(0, 90, 200, 300, 1024, 768);
	hudtip.SetTextPosition(TextAlign.Center);

	hudtip.AddFlag(g_ModeScript.HUD_FLAG_NOBG|HUD_FLAG_BLINK);
	Timers.AddTimer ( 15.0, false, CloseHud,hudtip );	
	//由于游戏全局名物品回复系统。需要延缓补给[在该hook下应该可以无需延迟，但是为了保证不会出现下一章节第一轮多重补给失效,延迟1秒]
	Timers.AddTimer ( 1.0, false, MultipleSupply);	
	if(MAPFIX)
		GetCampaignFix();	
}


::MultipleSupply <- function(params)
{
	if(WEAPONTOONE)
	{
	//武器	
		UpdateEntCount("weapon_pistol_spawn",2);
		UpdateEntCount("weapon_pistol_magnum_spawn",2);
		UpdateEntCount("weapon_smg_spawn",2);
		UpdateEntCount("weapon_pumpshotgun_spawn",2);
		UpdateEntCount("weapon_autoshotgun_spawn",2);
		UpdateEntCount("weapon_rifle_spawn",2); //以该武器为主。如果修改其他无效
		UpdateEntCount("weapon_hunting_rifle_spawn",2);
		UpdateEntCount("weapon_smg_silenced_spawn",2);
		UpdateEntCount("weapon_shotgun_chrome_spawn",2);
		UpdateEntCount("weapon_rifle_desert_spawn",2);
		UpdateEntCount("weapon_sniper_military_spawn",2);
		UpdateEntCount("weapon_shotgun_spas_spawn",2);
		UpdateEntCount("weapon_rifle_ak47_spawn",2);
		UpdateEntCount("weapon_smg_mp5_spawn",2);
		UpdateEntCount("weapon_rifle_sg552_spawn",2);
		UpdateEntCount("weapon_sniper_awp_spawn",2);
		UpdateEntCount("weapon_sniper_scout_spawn",2);
		UpdateEntCount("weapon_spawn",2);
	//补给品		
		UpdateEntCount("weapon_molotov_spawn",2);
		UpdateEntCount("weapon_pipe_bomb_spawn",2);
		UpdateEntCount("weapon_vomitjar_spawn",2);
		UpdateEntCount("weapon_pain_pills_spawn",2);
		UpdateEntCount("weapon_adrenaline_spawn",2);
		UpdateEntCount("weapon_defibrillator_spawn",1);
		UpdateEntCount("weapon_first_aid_kit_spawn",1);
		UpdateEntCount("weapon_melee_spawn",1);

	}	
}

::UpdateEntCount <- function(ClassName,Count)
{
	weaponindex <- null;
	while ((weaponindex = Entities.FindByClassname(weaponindex, ClassName)) != null)
	{
		weaponindex.__KeyValueFromInt("count", Count);	
		weaponindex.__KeyValueFromInt("spawnflags", 0);				
	}			
}

::CloseHud <- function(hud)
{
	hud.Detach();
}
/*
17 闪闪
15 隐形 5 6
3 半透明
7 无到有
9 闪烁 10快速 11超快 12间歇性 13
*/

// 6 隐身 10
//375 树苗 272 smoker 280 witch 281白色zombie
function Notifications::OnTankSpawned::TankSpawn( tank, params )
{
	//tank.SetRenderEffects(2);
	//tank.SetRenderMode(10);
	//tank.SetModelIndex();
	
	tank.SetHealth(_TankHealth);	
	tank.SetMaxHealth(_TankHealth);	
	::_rhealth[tank.GetIndex()] <- _TankHealth;
	// if(Utils.IsFinale())
	// {
		// tank.InputColor(Utils.GetRandNumber(0, 255),Utils.GetRandNumber(0, 255),Utils.GetRandNumber(0, 255));
	// }
	// else
	// {
		// local player = Players.SurvivorWithHighestFlow();
		// Utils.SpawnZombieNearPlayer( player,11, 1500, 500 );	//Z_WITCH
		// tank.SetRenderEffects(2);	  
	// }


	tankhealthmsg[tank.GetIndex()] <- healbar(_TankHealth,_TankHealth);
	::prop_dynamic[tank.GetIndex()] <- ent_dynamic(tank);
	local TankUniqueName = ::prop_dynamic[tank.GetIndex()].GetName();

	local HintTempSpawnerPos = Entities.FindByName(null,TankUniqueName).GetOrigin();
	HintCurrent[tank.GetIndex()] <- Entities.FindByClassnameWithin(null, "env_instructor_hint", HintTempSpawnerPos, 32);

	HintCurrent[tank.GetIndex()].__KeyValueFromString("hint_caption", tankhealthmsg[tank.GetIndex()]);
	EntFire(HintCurrent[tank.GetIndex()].GetName(), "ShowHint");		
	
}


function Notifications::OnTankKilled::TankKilled ( tank, attacker, params )
{
	delete tankhealthmsg[tank.GetIndex()];
	delete ::_rhealth[tank.GetIndex()];
	DoEntFire("!self", "Kill", "", 0.0, null, ::prop_dynamic[tank.GetIndex()]);
	DoEntFire("!self", "Kill", "", 0.0, null, HintCurrent[tank.GetIndex()]);
}

function Notifications::OnHurt::Hurt ( victim, attacker, params )
{
		local _rhealth = 0;
		
		if(victim.GetPlayerType() == Z_TANK) //.GetIndex()
		{
			_rhealth = params["health"];
			//printf(_rhealth);
			if(::_rhealth[victim.GetIndex()]  > _rhealth && _rhealth != 0) 
			{
					tankhealthmsg[victim.GetIndex()] = healbar(_TankHealth,_rhealth);
					::_rhealth[victim.GetIndex()] = _rhealth;
				//	tankhealthmsg[victim.GetEntityIndex()] = "["+victim.GetPlayerName()+"]"+"坦克血量:"+_rhealth;

			}
			else 
			{
					tankhealthmsg[victim.GetIndex()] = "(●︶╯﹏╰︶●)";

					//tankhealthmsg[victim.GetIndex()] = "["+victim.GetPlayerName()+"]死亡了";
			}

			HintCurrent[victim.GetIndex()].__KeyValueFromString("hint_caption", tankhealthmsg[victim.GetIndex()]);
			EntFire(HintCurrent[victim.GetIndex()].GetName(), "ShowHint");			
	
		}
}

function OnGameEvent_survivor_rescued(params)
{
	local vim = null;
	local player = null;
	local boolen = true;
	vim = params["victim"];
	player = GetPlayerFromUserID(vim); 
	if(player)
	{			
		if(player.IsSurvivor())
		{
			child <- player.FirstMoveChild();
			if (child) 
			{
				while (child)
				{
					if ( child.GetClassname() in weaponsNoReGive)
					{
						boolen = false;
						break;
					}
					child = child.NextMovePeer();
				}					  	
			}
			if(boolen)	
			{
				switch(RandomInt(1,4))
				{
					case 1:
						player.GiveItem("weapon_smg");	
						break;
					case 2:
						player.GiveItem("weapon_smg_silenced");	
						break;
					case 3:
						player.GiveItem("weapon_pumpshotgun");	
						break;
					case 4:		
						player.GiveItem("weapon_shotgun_chrome");	
						break;					
				}					
			}
		}				
	}
}


//========================================================HUD=============================================
function ChatTriggers::rank ( player, args, text )
{
	local hudtip1 = HUD.Item("\n{info}\n{rank01}\n{rank02}\n{rank03}");
	hudtip1.SetValue("info", rank16);
	hudtip1.SetValue("rank01", rank01);
	hudtip1.SetValue("rank02", rank02);
	hudtip1.SetValue("rank03", rank03);
	hudtip1.AttachTo(HUD_MID_BOX);
	hudtip1.ChangeHUDNative(0, 0, 350, 150, 1366, 720);
	hudtip1.SetTextPosition(TextAlign.Left);
	hudtip1.AddFlag(g_ModeScript.HUD_FLAG_NOBG|HUD_FLAG_BLINK); 
	
	local hudtip2 = HUD.Item("{rank04}\n{rank05}\n{rank06}\n{rank07}");
	hudtip2.SetValue("rank04", rank04);
	hudtip2.SetValue("rank05", rank05);
	hudtip2.SetValue("rank06", rank06);
	hudtip2.SetValue("rank07", rank07);
	hudtip2.AttachTo(HUD_SCORE_2);
	hudtip2.ChangeHUDNative(0, 120, 350, 150, 1366, 720);
	hudtip2.SetTextPosition(TextAlign.Left);
	hudtip2.AddFlag(g_ModeScript.HUD_FLAG_NOBG|HUD_FLAG_BLINK);
	local hudtip3 = HUD.Item("{rank08}\n{rank09}\n{rank10}\n{rank11}");
	hudtip3.SetValue("rank08",rank08);
	hudtip3.SetValue("rank09", rank09);
	hudtip3.SetValue("rank10", rank10);
	hudtip3.SetValue("rank11", rank11);
	hudtip3.AttachTo(HUD_SCORE_3);
	hudtip3.ChangeHUDNative(0, 225, 350, 150, 1366, 720);
	hudtip3.SetTextPosition(TextAlign.Left);
	hudtip3.AddFlag(g_ModeScript.HUD_FLAG_NOBG|HUD_FLAG_BLINK); 
	
	local hudtip4 = HUD.Item("{rank12}\n{rank13}\n{rank14}\n{rank15}");
	hudtip4.SetValue("rank12", rank12);
	hudtip4.SetValue("rank13", rank13);
	hudtip4.SetValue("rank14", rank14);
	hudtip4.SetValue("rank15", rank15);
	hudtip4.AttachTo(HUD_SCORE_4);
	hudtip4.ChangeHUDNative(0, 330, 350, 150, 1366, 720);
	hudtip4.SetTextPosition(TextAlign.Left);
	hudtip4.AddFlag(g_ModeScript.HUD_FLAG_NOBG|HUD_FLAG_BLINK); 
	
	Timers.AddTimer ( 6.0, false, CloseHud,hudtip1 );
	Timers.AddTimer ( 6.0, false, CloseHud,hudtip2 );
	Timers.AddTimer ( 6.0, false, CloseHud,hudtip3 );
	Timers.AddTimer ( 6.0, false, CloseHud,hudtip4 );
}

::rank01 <- function ()
{
	return PlayerRank[0];
}

::rank02 <- function ()
{
	return PlayerRank[1];
}

::rank03 <- function ()
{
	return PlayerRank[2];
}

::rank04 <- function ()
{
	return PlayerRank[3];
}

::rank05 <- function ()
{
	return PlayerRank[4];
}

::rank06 <- function ()
{
	return PlayerRank[5];
}

::rank07 <- function ()
{
	return PlayerRank[6];
}

::rank08 <- function ()
{
	return PlayerRank[7];
}

::rank09 <- function ()
{
	return PlayerRank[8];
}

::rank10 <- function ()
{
	return PlayerRank[9];
}

::rank11 <- function ()
{
	return PlayerRank[10];
}

::rank12 <- function ()
{
	return PlayerRank[11];
}

::rank13 <- function ()
{
	return PlayerRank[12];
}

::rank14 <- function ()
{
	return PlayerRank[13];
}

::rank15 <- function ()
{
	return PlayerRank[14];
}

::rank16 <- function ()
{
	return PlayerRank[15];
}

//===============================================数据更新=====================================
function VSLib::EasyLogic::Update::DateUpDate()
{
	//Utils.SayToAll( ""+ );
	local SurvivorsCount = 0;
	ClientIndex <- {};
	foreach(surmodel in ::survivors)
	{
		playerindex <- null;
		while ((playerindex = Entities.FindByModel(playerindex, surmodel)) != null)
		{			
			if(playerindex.IsValid()&&playerindex.IsPlayer()&&!IsPlayerABot(playerindex))
			{			
				ClientIndex[SurvivorsCount] <- playerindex.GetEntityIndex();
				SurvivorsCount++;	
			}		
		}
	}	
	switch(Utils.GetDifficulty())
	{
		case EASY:
		{
			_TankHealth  = SurvivorsCount*COEFFICIENT_TANK + CARDINALNUMBER_TANK + 2000;
			break;
		}

		case NORMAL:
		{
			_TankHealth  = SurvivorsCount*COEFFICIENT_TANK + CARDINALNUMBER_TANK + 4000;
			break;
		}
		case ADVANCED:
		{
			_TankHealth  = SurvivorsCount*COEFFICIENT_TANK + CARDINALNUMBER_TANK + 6000;
			break;
		}
		case EXPERT: 
		{
			_TankHealth  = SurvivorsCount*COEFFICIENT_TANK + CARDINALNUMBER_TANK + 8000;
			break;
		}
	}
	
	local _Specials = SurvivorsCount*COEFFICIENT_PZ + CARDINALNUMBER_PZ; 
	local _RespawnInterval  = CARDINALNUMBER_RESPAWN - SurvivorsCount*COEFFICIENT_RESPAWN;
	local _CommonLimit  = SurvivorsCount*COEFFICIENT_ZOMBIE + CARDINALNUMBER_ZOMBIE;

	//15人 
	for(local i = 0; i < 15; i++)
	{
		PlayerRank[i]<-"";
	}		
	PlayerRank[15]<-"统计" + "[("+_Specials+")特("+_RespawnInterval+")秒]:";


	bubbleSort(ClientIndex); 
	for(local i = 0; i < ClientIndex.len(); i++)
	{
		if(ClientIndex[i] == null) break;
		local NO = i+1;
		if(PlayerInstanceFromIndex(ClientIndex[i]).GetPlayerName().len()>15)
			PlayerRank[i] = NO+"."+PlayerInstanceFromIndex(ClientIndex[i]).GetPlayerName().slice(0, 15)+":"+PlayerZombie[ClientIndex[i]]+"只";
		else
			PlayerRank[i] = NO+"."+PlayerInstanceFromIndex(ClientIndex[i]).GetPlayerName()+":"+PlayerZombie[ClientIndex[i]]+"只";
	}	
	
	DirectorOptions.cm_MaxSpecials = _Specials;
	DirectorOptions.DominatorLimit = _Specials;
	DirectorOptions.cm_SpecialRespawnInterval = _RespawnInterval;
	DirectorOptions.SpecialInitialSpawnDelayMax = _RespawnInterval+3;
	DirectorOptions.SpecialInitialSpawnDelayMin = _RespawnInterval;
	DirectorOptions.cm_CommonLimit = _CommonLimit;
}

	
//========================================实体调用==========================================

::AttachParticle <- function(ent,particleName = "", duration = 0.0)
{	
	local particle = g_ModeScript.CreateSingleSimpleEntityFromTable({ classname = "info_particle_system", targetname = "info_particle_system" + UniqueString(), origin = ent.GetEyePosition(), angles = QAngle(0,0,0), start_active = true, effect_name = particleName });
	if (!particle)
	{
		Msg("警告:创建粒子实体失败.");
		return;
	}
	DoEntFire("!self", "Start", "", 0, null, particle);
	DoEntFire("!self", "Kill", "", duration, null, particle);
	AttachOther(PlayerInstanceFromIndex(ent.GetIndex()),particle, true,ent.GetEyePosition());
}


::ent_dynamic <- function(Entity)
{
	//	Msg(Entity);
	HintSpawnInfo <-
	{
		hint_auto_start = "1"
		hint_range = "0"
		hint_suppress_rest = "1"
		hint_nooffscreen = "1"
		hint_forcecaption = "0"
		hint_icon_onscreen = "" //icon_skull
		hint_color = "155 255 10"
		hint_allow_nodraw_target = "0"
		
	}	
	local spawn =
	{
		classname = "prop_dynamic",
		solid = "0",
		model = "models/editor/axis_helper_thick.mdl",
		targetname = "prop_dynamic" + UniqueString(),
		rendermode = "10",
		angles = QAngle(0, 0, 0)
	};
	spawn["spawnflags"] <- 256;
	local pos = Entity.GetEyePosition();
	pos.z += 20.0;
	local prop_dynamic = g_ModeScript.CreateSingleSimpleEntityFromTable(spawn);
	local TankUniqueName = prop_dynamic.GetName();;
	AttachOther(PlayerInstanceFromIndex(Entity.GetIndex()),prop_dynamic, true,pos);
	
	g_MapScript.CreateHintTarget( TankUniqueName, prop_dynamic.GetOrigin(), null, g_MapScript.TrainingHintTargetCB )
	g_MapScript.CreateHintOn(TankUniqueName, null,tankhealthmsg[Entity.GetIndex()], HintSpawnInfo, g_MapScript.TrainingHintCB )
	return prop_dynamic;
}

::AttachOther <- function(Entity,otherEntity, teleportOther,pos)
{
	teleportOther = (teleportOther.tointeger() > 0) ? true : false;
	if (teleportOther)
		otherEntity.SetOrigin(pos);
	DoEntFire("!self", "SetParent", "!activator", 0, Entity, otherEntity);
}

//============================================stock================================================

::bubbleSort <- function(arrindex)
{
    for (local i = 0; i < arrindex.len() - 1; i++)
    {
		for (local j = 0; j < arrindex.len() - 1 - i; j++)
		{
			if (PlayerZombie[arrindex[j]] < PlayerZombie[arrindex[j+1]])
			{
				local temp = arrindex[j + 1];
				arrindex[j + 1] = arrindex[j];
				arrindex[j] = temp;
			}
		}
	}
}


::healbar<-function(fullheal,remainheal)
{
	local x = "☻";//♥
	local _x = "☺";//♡[无效] ๓
	local BAR = "";
	local count = remainheal/(fullheal/10.0);	
	for(local i=0 ; i<ceil(count); i++)
	{
		BAR += x;
	}
	for(local i = ceil(count); i<10 ; i++)
	{
		BAR += _x;
	}
	return BAR;
}

//=========================================================修补======================
::GetCampaignFix <- function()
{
	local mapname = SessionState.MapName.tolower();
	
	if ( mapname.find("c2m5_concert") != null )
	{
		
		local spawn =
		{
			classname = "prop_dynamic",
			solid = "6",
			//disableselfshadowing = "1",
			model = "models/props_doors/roll-up_door_open.mdl",
			//targetname = "prop_dynamic" + UniqueString(),
			rendermode = "10",
			angles = QAngle(0, 90, 0),
		}; 
		//spawn["origin"] <- Vector(6808.0, 1475.0, 218.0)
	//	g_ModeScript.CreateSingleSimpleEntityFromTable(spawn);
		//spawn["origin"] <- Vector(6668.0, 1475.0, 218.0)
		//g_ModeScript.CreateSingleSimpleEntityFromTable(spawn); 
		//2ceng
		spawn["origin"] <- Vector(-2305.510986, 2483.664795, -29.271255)
		g_ModeScript.CreateSingleSimpleEntityFromTable(spawn);
	}
	else if ( mapname.find("c3m1_plankcountry") != null )
	{
		local spawn =
		{
			classname = "prop_dynamic",
			solid = "6",
			model = "models/props_equipment/diesel_pump.mdl",
			//rendermode = "10",
			angles = QAngle(0, 3, 0),
		}; 
		spawn["origin"] <- Vector(-7195.384277,6242.740723, 8.827160)
		g_ModeScript.CreateSingleSimpleEntityFromTable(spawn);
	}
	else if ( mapname.find("c6m3_port") != null ) //该图nav没问题。其实可以不用加模型
	{
		local spawn =
		{
			classname = "prop_dynamic",
			solid = "6",
			model = "models/props_unique/generator_short.mdl",
			rendermode = "10",
			angles = QAngle(0, 90, 0),
		}; 
		spawn["origin"] <- Vector(-410.490601, -1105.183228, 90.343811)
		g_ModeScript.CreateSingleSimpleEntityFromTable(spawn);
	}
	else if ( mapname.find("c7m3_port") != null )
	{
		local spawn =
		{
			classname = "prop_dynamic",
			solid = "6",
			model = "models/props_unique/generator_short.mdl",
			rendermode = "10",
			angles = QAngle(0, 90, 0),
		}; 
		spawn["origin"] <- Vector(-410.490601, -1105.183228, 90.343811)
		g_ModeScript.CreateSingleSimpleEntityFromTable(spawn);
	}
	else if ( mapname.find("c8m5_rooftop") != null )
	{
		local spawn1 =
		{
			classname = "prop_dynamic",
			solid = "6",
			model = "models/props_fortifications/sandbags_line2.mdl",
			rendermode = "10",
			angles = QAngle(0, 0, 0),
		}; 
		//放弃治疗
		/* 
		local spawn2 =
		{
			classname = "prop_dynamic",
			solid = 2,
			model = "models/props_fortifications/sandbags_line2.mdl",
			rendermode = "10",
			angles = QAngle(0, 0, 0),
		};
		*/
		spawn1["origin"] <- Vector(5574.025391, 8477.664063, 6100.031250)
		g_ModeScript.CreateSingleSimpleEntityFromTable(spawn1);
		//spawn2["origin"] <- Vector(5994.963379, 8408.181641, 6150.031250)
//g_ModeScript.CreateSingleSimpleEntityFromTable(spawn2);
		
	}
	else if ( mapname.find("c9m1_alleys") != null )
	{
		local index = null;
		index = Entities.FindByName(index, "howitzer_burn_trigger");
		if(index)
		{
			index.__KeyValueFromString("damage", "200");	
			index.__KeyValueFromString("damagecap", "200");				
		}
	}
	else if ( mapname.find("c9m2_lots") != null )
	{
		local spawn =
		{
			classname = "prop_dynamic",
			solid = 2,
			model = "models/props/cs_militia/boxes_frontroom.mdl",
			rendermode = "10",
			angles = QAngle(0, 90, 0),
		}; 
		spawn["origin"] <- Vector (8292.878906, 6507.525586, 108.225731)
		g_ModeScript.CreateSingleSimpleEntityFromTable(spawn);
	}
	else if ( mapname.find("c12m5_cornfield") != null )
	{
		local spawn =
		{
			classname = "prop_dynamic",
			solid = "6",
			//disableselfshadowing = "1",
			model = "models/props/cs_militia/logpile2.mdl",
			//targetname = "prop_dynamic" + UniqueString(),
			rendermode = "10",
			angles = QAngle(0, 90, 0),
		}; 
		//spawn["origin"] <- Vector(6808.0, 1475.0, 218.0)
	//	g_ModeScript.CreateSingleSimpleEntityFromTable(spawn);
		//spawn["origin"] <- Vector(6668.0, 1475.0, 218.0)
		//g_ModeScript.CreateSingleSimpleEntityFromTable(spawn); 
		//2ceng
		spawn["origin"] <- Vector(6936.0, 1475.0, 420.0)
		g_ModeScript.CreateSingleSimpleEntityFromTable(spawn);
		spawn["origin"] <- Vector(6808.0, 1475.0, 420.0)
		g_ModeScript.CreateSingleSimpleEntityFromTable(spawn);
		spawn["origin"] <- Vector(6708.0, 1475.0, 420.0)
		g_ModeScript.CreateSingleSimpleEntityFromTable(spawn); 
	}
}
