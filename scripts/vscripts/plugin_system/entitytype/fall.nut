class ::ObjectSpawner2.Entity_FallDamage extends ::ObjectSpawner2.BaseEntityType
{
	constructor(entity)
	{
		base.constructor(entity);
	}
	
	function _typeof()
	{
		return "OBJECT_SPAWNER_FALLDAMAGE";
	}
	
	_OldName = "";
}

::EntityType.Creator["fall"] <- ::ObjectSpawner2.Entity_FallDamage;

function ObjectSpawner2::Entity_FallDamage::OnCreate(params)
{
	_ent.SetRenderMode(RENDER_TRANSCOLOR);
	_ent.SetColor(128, 128, 64, 255);
	
	_OldName = _ent.GetNetPropString("m_iName");
	_ent.SetNetPropString("m_iName", "et_fall");
}

function ObjectSpawner2::Entity_FallDamage::OnRelease()
{
	_ent.SetColor(255, 255, 255, 255);
	_ent.SetNetPropString("m_iName", _OldName);
}

function EasyLogic::OnTakeDamage::EntityType_FallDamage(dmgTable)
{
	if(dmgTable["Victim"] == null || dmgTable["DamageDone"] <= 0.0 ||
		!dmgTable["Victim"].IsSurvivor() || !(dmgTable["DamageType"] & DMG_FALL))
		return true;
	
	local entity = ::ObjectSpawner2.GetPlayerGroundEntity(dmgTable["Victim"],
		::ObjectSpawner2.ConfigVar.GroundDistance);
	if(entity == null || !entity.IsEntityValid())
		return true;
	
	return (entity.GetNetPropString("m_iName") != "et_fall");
}
