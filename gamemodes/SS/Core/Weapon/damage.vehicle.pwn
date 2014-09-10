#include <YSI\y_hooks>


static
		// Always for targetid
Float:	dmg_ReturnBleedrate[MAX_PLAYERS],
Float:	dmg_ReturnKnockMult[MAX_PLAYERS];


forward OnPlayerVehicleCollide(playerid, targetid, Float:bleedrate, Float:knockmult);


hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	if(weaponid == 49)
	{
		_DoVehicleCollisionDamage(issuerid, playerid);
	}

	return 1;
}

_DoVehicleCollisionDamage(playerid, targetid)
{
	if(IsPlayerOnAdminDuty(playerid) || IsPlayerOnAdminDuty(targetid))
		return 0;

	new
		Float:velocity,
		Float:bleedrate,
		Float:knockmult = 1.0;

	velocity = GetPlayerTotalVelocity(playerid);
	bleedrate = 0.04 * (velocity / 50.0);

	if(velocity > 55.0 && frandom(velocity) > 55.0)
		KnockOutPlayer(targetid, floatround(1000 + ((velocity / 20.0) * 1000)));

	dmg_ReturnBleedrate[targetid] = bleedrate;
	dmg_ReturnKnockMult[targetid] = knockmult;

	if(CallLocalFunction("OnPlayerVehicleCollide", "ddff", playerid, targetid, bleedrate, knockmult))
		return 0;

	if(dmg_ReturnBleedrate[targetid] != bleedrate)
		bleedrate = dmg_ReturnBleedrate[targetid];

	if(dmg_ReturnKnockMult[targetid] != knockmult)
		knockmult = dmg_ReturnKnockMult[targetid];

	PlayerInflictWound(playerid, targetid, E_WOUND_MELEE, bleedrate, 0, NO_CALIBRE, random(2) ? (BODY_PART_TORSO) : (random(2) ? (BODY_PART_RIGHT_LEG) : (BODY_PART_LEFT_LEG)), "Collision");

	return 1;
}

stock DMG_VEHICLE_SetBleedRate(targetid, Float:bleedrate)
{
	if(!IsPlayerConnected(targetid))
		return 0;

	dmg_ReturnBleedrate[targetid] = bleedrate;

	return 1;
}

stock DMG_VEHICLE_SetKnockMult(targetid, Float:knockmult)
{
	if(!IsPlayerConnected(targetid))
		return 0;

	dmg_ReturnKnockMult[targetid] = knockmult;

	return 1;
}
