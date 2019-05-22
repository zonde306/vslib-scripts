::ResourceLite <-
{
	PrivateDataDefault =
	{
		CurrentCount = 0,
		DropChance = 0.0
	},
	
	PrivateData = {},
	
	// 防止访问时抛出异常
	CurrentCount = 0,
	DropChance = 0.0,
	
	// 掉落物品模型
	DropItemModel =
	[
		"models/editor/air_node_hint.mdl",
		"models/editor/air_node.mdl",
		"models/editor/node_hint.mdl",
		"models/editor/scriptedsequence.mdl",
		"models/editor/overlay_helper.mdl",
		"models/items/l4d_gift.mdl",
		"models/extras/info_speech.mdl"
	],
	
	function CanAfford(cost)
	{
		return (::ResourceLite.PrivateData.CurrentCount >= cost);
	},
	
	function Purchase(cost)
	{
		if(!::ResourceLite.CanAfford(cost))
			return false;
		
		::ResourceLite.RemoveResources(cost);
		return true;
	},
	
	function RemoveResources(val)
	{
		if(val > ::ResourceLite.PrivateData.CurrentCount)
			val = ::ResourceLite.PrivateData.CurrentCount;
		
		::ResourceLite.PrivateData.CurrentCount -= val;
		UpdateHud();
	},
	
	function AddResources(val)
	{
		::ResourceLite.PrivateData.CurrentCount += val;
		UpdateHud();
	},
	
	function UpdateHud()
	{
		local params = {newcount = ::ResourceLite.PrivateData.CurrentCount};
		::ResourceLite.CurrentCount = ::ResourceLite.PrivateData.CurrentCount;
		FireScriptEvent("on_resources_changed", params);
	},
	
	function CreateDropItem(origin)
	{
		local index = RandomInt(0, ::ResourceLite.DropItemModel.len() - 1);
		local entity = Utils.SpawnEntity("scripted_item_drop", "vslib_resources_lite", origin, QAngle(0, 0, 0),
			{model = ::ResourceLite.DropItemModel[index], solid = 6});
		
		if(entity == null)
			return null;
		
		if(index == 3)
			entity.SetModelScale(0.7);
		else if(index == 4)
			entity.SetModelScale(1.5);
		
		local time = Time();
		entity.SetNetPropInt("m_hasTankGlow", 1);
		entity.SetNetPropInt("m_isCarryable", 0);
		entity.SetNetPropInt("m_noGhostCollision", 1);
		entity.SetNetPropFloat("m_flCreateTime", time);
		entity.SetNetPropFloat("m_flFrozen", time + 16);
		entity.SetNetPropFloat("m_flAnimTime", 0.0);
		entity.ConnectOutput("OnPlayerTouch", ::ResourceLite.OnOutput_OnDropItemPickup);
		entity.ConnectOutput("OnPlayerPickup", ::ResourceLite.OnOutput_OnDropItemPickup);
		entity.AddThinkFunction(::ResourceLite.OnOutput_OnDropItemThink);
		entity.SetNextThinkTime(time + 0.1);
		
		return entity;
	},
	
	function OnOutput_OnDropItemPickup()
	{
		local entity = Utils.GetEntityOrPlayer(this.caller);
		local player = Utils.GetEntityOrPlayer(this.activator);
		if(entity == null || !entity.IsEntityValid() || player == null || !player.IsSurvivor())
			return;
		
		entity.Kill();
		player.PlaySound("WAM.PointScored");
		::ResourceLite.AddResources(1);
	},
	
	function OnOutput_OnDropItemThink()
	{
		local entity = Utils.GetEntityOrPlayer(this.ent);
		if(entity == null || !entity.IsEntityValid())
			return;
		
		local time = Time();
		local endDelay = entity.GetNetPropFloat("m_flCreateTime") + 16 - time;
		
		if(endDelay <= 0)
		{
			entity.PlaySound("Plastic_Barrel.Break");
			entity.KillDelayed(0.1);
			return;
		}
		
		if(endDelay <= 5 && entity.GetNetPropFloat("m_flAnimTime") <= time)
		{
			if(entity.GetNetPropBool("m_bFlashing"))
			{
				entity.SetColor(255, 255, 255, 255);
				entity.SetNetPropInt("m_bFlashing", 0);
			}
			else
			{
				entity.SetColor(255, 0, 0, 255);
				entity.SetNetPropInt("m_bFlashing", 1);
			}
			
			entity.PlaySound("Strongman.puck_tick");
			entity.SetNetPropFloat("m_flAnimTime", time + 0.25);
		}
		
		entity.SetAngles(entity.GetAngles() + QAngle(0, 9, 0));
		entity.SetNextThinkTime(Time() + 0.1);
	}
};

function Notifications::OnZombieDeath::ResourceLite_DropResource(victim, attacker, params)
{
	if(victim == null || attacker == null || params["infected_id"] == Z_COMMON)
		return;
	
	if(RandomFloat(0, 1) > ::ResourceLite.PrivateData.DropChance)
		return;
	
	local entityGroup = g_MapScript.GetEntityGroup("PlaceableResource");
	
	if(entityGroup)
		g_MapScript.SpawnSingleAt(entityGroup, victim.GetLocation() + Vector(0, 0, 16), QAngle(0, 0, 0));
	else
		::ResourceLite.CreateDropItem(victim.GetLocation() + Vector(0, 0, 16));
}

function CommandTriggersEx::gift(player, args, text)
{
	if(!::AdminSystem.IsPrivileged(player))
		return;
	
	IncludeScript("entitygroups/placeable_resource_group.nut", g_MapScript);
	::ResourceLite.CreateDropItem(player.GetLookingLocation() + Vector(0, 0, 16));
}

::g_ResourceManager <- ::ResourceLite.weakref();
::ResourceLite.PLUGIN_NAME <- "resource_lite";

function Notifications::OnRoundStart::ResourceLite_LoadData()
{
	RestoreTable(::ResourceLite.PLUGIN_NAME, ::ResourceLite.PrivateData);
	if(::ResourceLite.PrivateData == null || ::ResourceLite.PrivateData.len() <= 0)
		::ResourceLite.PrivateData = ::ResourceLite.PrivateDataDefault;
	
	::ResourceLite.CurrentCount = ::ResourceLite.PrivateData.CurrentCount;
	::ResourceLite.DropChance = ::ResourceLite.PrivateData.DropChance;
}

function EasyLogic::OnShutdown::ResourceLite_SaveData(reason, nextmap)
{
	if(reason > 0 && reason < 4)
		SaveTable(::ResourceLite.PLUGIN_NAME, ::ResourceLite.PrivateData);
}
