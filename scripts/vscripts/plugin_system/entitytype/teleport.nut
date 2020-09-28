class ::ObjectSpawner2.Entity_Teleport extends ::ObjectSpawner2.BaseEntityType
{
	constructor(entity)
	{
		base.constructor(entity);
	}
	
	function _typeof()
	{
		return "OBJECT_SPAWNER_TELEPORT";
	}
	
	_TargetOrigin = null;
	_TargetAngles = null;
}

::EntityType.Creator["teleport"] <- ::ObjectSpawner2.Entity_Teleport;
::EntityType.Creator["warp"] <- ::ObjectSpawner2.Entity_Teleport;
::EntityType.Creator["tp"] <- ::ObjectSpawner2.Entity_Teleport;

function ObjectSpawner2::Entity_Teleport::OnCreate(params)
{
	_TargetOrigin = params["teleport_origin"];
	_TargetAngles = params["teleport_angles"];
	
	_ent.SetRenderMode(RENDER_TRANSCOLOR);
	_ent.SetColor(0, 0, 255, 255);
}

function ObjectSpawner2::Entity_Teleport::OnGround(player)
{
	player.SetLocation(_TargetOrigin);
	player.SetEyeAngles(_TargetAngles);
	player.PlaySoundEx("level/startwam.wav");
}

function ObjectSpawner2::Entity_Teleport::OnTouch(player)
{
	player.SetLocation(_TargetOrigin);
	player.SetEyeAngles(_TargetAngles);
	player.PlaySoundEx("level/startwam.wav");
}

function ObjectSpawner2::Entity_Teleport::OnRelease()
{
	_ent.SetColor(255, 255, 255, 255);
}
