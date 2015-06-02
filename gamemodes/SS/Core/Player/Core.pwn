#include <YSI\y_hooks>


#define DEFAULT_POS_X				(10000.0)
#define DEFAULT_POS_Y				(10000.0)
#define DEFAULT_POS_Z				(1.0)


enum E_FLAGS:(<<= 1) // 17
{
			Alive = 1,
			Dying,
			Spawned,
			FirstSpawn, // TODO: fix this value

			ToolTips,
			ShowHUD,
			GlobalQuiet,

			Frozen,

			DebugMode
}

enum E_PLAYER_DATA
{
			// Database Account Data
			ply_Password[MAX_PASSWORD_LEN],
			ply_IP,
			ply_RegisterTimestamp,
			ply_LastLogin,
			ply_TotalSpawns,
			ply_Warnings,

			// Character Data
Float:		ply_HitPoints,
Float:		ply_ArmourPoints,
Float:		ply_FoodPoints,
			ply_Clothes,
			ply_Gender,
			ply_Karma,
Float:		ply_Velocity,
Float:		ply_SpawnPosX,
Float:		ply_SpawnPosY,
Float:		ply_SpawnPosZ,
Float:		ply_SpawnRotZ,
Float:		ply_RadioFrequency,
			ply_CreationTimestamp,
			ply_AimShoutText[128],

			// Internal Data
E_FLAGS:	ply_BitFlags,
			ply_ChatMode,
			ply_CurrentVehicle,
			ply_PingLimitStrikes,
			ply_ScreenBoxFadeLevel,
			ply_stance,
			ply_JoinTick,
			ply_SpawnTick,
			ply_ExitVehicleTick
}

static
			ply_Data[MAX_PLAYERS][E_PLAYER_DATA];
PlayerText:	ClassBackGround[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	ClassButtonMale[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	ClassButtonFemale[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};

new
			gPlayerName[MAX_PLAYERS][MAX_PLAYER_NAME];


forward OnPlayerDisconnected(playerid);


public OnGameModeInit()
{
	ClassBackGround[playerid]		=CreatePlayerTextDraw(playerid, 0.000000, 0.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, ClassBackGround[playerid], 255);
	PlayerTextDrawFont				(playerid, ClassBackGround[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ClassBackGround[playerid], 0.500000, 50.000000);
	PlayerTextDrawColor				(playerid, ClassBackGround[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, ClassBackGround[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, ClassBackGround[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, ClassBackGround[playerid], 1);
	PlayerTextDrawUseBox			(playerid, ClassBackGround[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, ClassBackGround[playerid], 255);
	PlayerTextDrawTextSize			(playerid, ClassBackGround[playerid], 640.000000, 0.000000);

	ClassButtonMale[playerid]		=CreatePlayerTextDraw(playerid, 250.000000, 200.000000, "~n~Male~n~~n~");
	PlayerTextDrawAlignment			(playerid, ClassButtonMale[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, ClassButtonMale[playerid], 255);
	PlayerTextDrawFont				(playerid, ClassButtonMale[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ClassButtonMale[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, ClassButtonMale[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, ClassButtonMale[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, ClassButtonMale[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, ClassButtonMale[playerid], 1);
	PlayerTextDrawUseBox			(playerid, ClassButtonMale[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, ClassButtonMale[playerid], 255);
	PlayerTextDrawTextSize			(playerid, ClassButtonMale[playerid], 44.000000, 100.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonMale[playerid], true);

	ClassButtonFemale[playerid]		=CreatePlayerTextDraw(playerid, 390.000000, 200.000000, "~n~Female~n~~n~");
	PlayerTextDrawAlignment			(playerid, ClassButtonFemale[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, ClassButtonFemale[playerid], 255);
	PlayerTextDrawFont				(playerid, ClassButtonFemale[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ClassButtonFemale[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, ClassButtonFemale[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, ClassButtonFemale[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, ClassButtonFemale[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, ClassButtonFemale[playerid], 1);
	PlayerTextDrawUseBox			(playerid, ClassButtonFemale[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, ClassButtonFemale[playerid], 255);
	PlayerTextDrawTextSize			(playerid, ClassButtonFemale[playerid], 44.000000, 100.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonFemale[playerid], true);
}

ShowClassBackground(playerid)
{
	PlayerTextDrawBoxColor(playerid, ClassBackGround[playerid], 0x000000FF);
	PlayerTextDrawShow(playerid, ClassBackGround[playerid]);
}

public OnPlayerConnect(playerid)
{
	logf("[JOIN] %p joined", playerid);

	SetPlayerColor(playerid, 0xB8B8B800);
	SetPlayerWeather(playerid, gWeatherID);
	GetPlayerName(playerid, gPlayerName[playerid], MAX_PLAYER_NAME);

	if(IsPlayerNPC(playerid))
		return 1;

	ResetVariables(playerid);

	ply_Data[playerid][ply_JoinTick] = GetTickCount();

	new
		ipstring[16],
		ipbyte[4];

	GetPlayerIp(playerid, ipstring, 16);

	sscanf(ipstring, "p<.>a<d>[4]", ipbyte);
	ply_Data[playerid][ply_IP] = ((ipbyte[0] << 24) | (ipbyte[1] << 16) | (ipbyte[2] << 8) | ipbyte[3]);

	if(BanCheck(playerid))
		return 0;

	defer LoadAccountDelay(playerid);

	LoadPlayerTextDraws(playerid);

	ply_Data[playerid][ply_ScreenBoxFadeLevel] = 0;
	PlayerTextDrawBoxColor(playerid, ClassBackGround[playerid], 0x000000FF);
	PlayerTextDrawShow(playerid, ClassBackGround[playerid]);

	TogglePlayerControllable(playerid, false);
	Streamer_ToggleIdleUpdate(playerid, true);
	TextDrawShowForPlayer(playerid, Branding);
	SetSpawn(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, 0.0);
	SpawnPlayer(playerid);

	MsgAllF(WHITE, " >  %P (%d)"C_WHITE" has joined", playerid, playerid);
	MsgF(playerid, YELLOW, " >  MoTD: "C_BLUE"%s", gMessageOfTheDay);

	t:ply_Data[playerid][ply_BitFlags]<ShowHUD>;

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(gServerRestarting)
		return 0;

	Logout(playerid);

	switch(reason)
	{
		case 0:
		{
			MsgAllF(GREY, " >  %p lost connection.", playerid);
			log(sprintf("[PART] %p (lost connection)", playerid), 0);
		}
		case 1:
		{
			MsgAllF(GREY, " >  %p left the server.", playerid);
			log(sprintf("[PART] %p (quit)", playerid), 0);
		}
	}

	SetTimerEx("OnPlayerDisconnected", 100, false, "dd", playerid, reason);

	return 1;
}

timer LoadAccountDelay[5000](playerid)
{
	if(gServerInitialising || GetTickCountDifference(GetTickCount(), gServerInitialiseTick) < 5000)
	{
		defer LoadAccountDelay(playerid);
		return;
	}

	new loadresult = LoadAccount(playerid);

	if(loadresult == -1) // LoadAccount aborted, kick player.
	{
		KickPlayer(playerid, "Account load failed");
		return;
	}

	if(loadresult == 0) // Account does not exist
	{
		DisplayRegisterPrompt(playerid);
	}

	if(loadresult == 1) // Account does exist, prompt login
	{
		DisplayLoginPrompt(playerid);
	}

	if(loadresult == 2) // Account does exist, auto login
	{
		Login(playerid);
	}

	if(loadresult == 3) // Account does exist, but not in whitelist
	{
		WhitelistKick(playerid);
	}

	if(loadresult == 4) // Account does exists, but is disabled
	{
		KickPlayer(playerid, "Account inactive");
	}

	CheckForExtraAccounts(playerid);

	return;
}

public OnPlayerDisconnected(playerid)
{
	ResetVariables(playerid);

	#if defined ply_OnPlayerDisconnected
		return ply_OnPlayerDisconnected(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnPlayerDisconnected
	#undef OnPlayerDisconnected
#else
	#define _ALS_OnPlayerDisconnected
#endif
#define OnPlayerDisconnected ply_OnPlayerDisconnected
#if defined ply_OnPlayerDisconnected
	forward ply_OnPlayerDisconnected(playerid);
#endif

ResetVariables(playerid)
{
	ply_Data[playerid][ply_BitFlags]			= E_FLAGS:0;

	ply_Data[playerid][ply_Password][0]			= EOS;
	ply_Data[playerid][ply_IP]					= 0;
	ply_Data[playerid][ply_Warnings]			= 0;
	ply_Data[playerid][ply_Karma]				= 0;

	ply_Data[playerid][ply_HitPoints]			= 100.0;
	ply_Data[playerid][ply_ArmourPoints]		= 0.0;
	ply_Data[playerid][ply_FoodPoints]			= 80.0;
	ply_Data[playerid][ply_Clothes]				= 0;
	ply_Data[playerid][ply_Gender]				= 0;
	ply_Data[playerid][ply_Velocity]			= 0.0;
	ply_Data[playerid][ply_SpawnPosX]			= 0.0;
	ply_Data[playerid][ply_SpawnPosY]			= 0.0;
	ply_Data[playerid][ply_SpawnPosZ]			= 0.0;
	ply_Data[playerid][ply_SpawnRotZ]			= 0.0;
	ply_Data[playerid][ply_RadioFrequency]		= 108.0;
	ply_Data[playerid][ply_AimShoutText][0]		= EOS;

	ply_Data[playerid][ply_ChatMode]			= CHAT_MODE_GLOBAL;
	ply_Data[playerid][ply_CurrentVehicle]		= 0;
	ply_Data[playerid][ply_PingLimitStrikes]	= 0;
	ply_Data[playerid][ply_ScreenBoxFadeLevel]	= 0;
	ply_Data[playerid][ply_stance]				= 0;
	ply_Data[playerid][ply_JoinTick]			= 0;
	ply_Data[playerid][ply_SpawnTick]			= 0;
	ply_Data[playerid][ply_ExitVehicleTick]		= 0;

	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL,			100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN,	100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI,		100);

	for(new i; i < 10; i++)
		RemovePlayerAttachedObject(playerid, i);
}

ptask PlayerUpdate[100](playerid)
{
	new pinglimit = (Iter_Count(Player) > 10) ? (gPingLimit) : (gPingLimit + 100);

	if(GetPlayerPing(playerid) > pinglimit)
	{
		if(GetTickCountDifference(GetTickCount(), ply_Data[playerid][ply_JoinTick]) > 10000)
		{
			ply_Data[playerid][ply_PingLimitStrikes]++;

			if(ply_Data[playerid][ply_PingLimitStrikes] == 30)
			{
				KickPlayer(playerid, sprintf("Having a ping of: %d limit: %d.", GetPlayerPing(playerid), pinglimit));

				ply_Data[playerid][ply_PingLimitStrikes] = 0;

				return;
			}
		}
	}
	else
	{
		ply_Data[playerid][ply_PingLimitStrikes] = 0;
	}

	if(NetStats_MessagesRecvPerSecond(playerid) > 200)
	{
		MsgAdminsF(3, YELLOW, " >  %p sending %d messages per second.", playerid, NetStats_MessagesRecvPerSecond(playerid));
		return;
	}

	if(!IsPlayerSpawned(playerid))
		return;

	new
		hour,
		minute,
		weather;

	if(IsPlayerInAnyVehicle(playerid))
	{
		PlayerVehicleUpdate(playerid);
	}
	else
	{
		if(!gVehicleSurfing)
			VehicleSurfingCheck(playerid);

		if(IsValidVehicle(ply_Data[playerid][ply_CurrentVehicle]))
		{
			new Float:health;

			GetVehicleHealth(ply_Data[playerid][ply_CurrentVehicle], health);

			if(health < 299.0)
				SetVehicleHealth(ply_Data[playerid][ply_CurrentVehicle], 299.0);
		}
	}

	if(ply_Data[playerid][ply_ScreenBoxFadeLevel] > 0)
	{
		PlayerTextDrawBoxColor(playerid, ClassBackGround[playerid], ply_Data[playerid][ply_ScreenBoxFadeLevel]);
		PlayerTextDrawShow(playerid, ClassBackGround[playerid]);

		ply_Data[playerid][ply_ScreenBoxFadeLevel] -= 4;

		if(ply_Data[playerid][ply_HitPoints] <= 40.0)
		{
			if(ply_Data[playerid][ply_ScreenBoxFadeLevel] <= floatround((40.0 - ply_Data[playerid][ply_HitPoints]) * 4.4))
				ply_Data[playerid][ply_ScreenBoxFadeLevel] = 0;
		}
	}
	else
	{
		if(ply_Data[playerid][ply_HitPoints] < 40.0)
		{
			if(IsPlayerUnderDrugEffect(playerid, drug_Painkill))
			{
				PlayerTextDrawHide(playerid, ClassBackGround[playerid]);
			}
			else if(IsPlayerUnderDrugEffect(playerid, drug_Adrenaline))
			{
				PlayerTextDrawHide(playerid, ClassBackGround[playerid]);
			}
			else
			{
				PlayerTextDrawBoxColor(playerid, ClassBackGround[playerid], floatround((40.0 - ply_Data[playerid][ply_HitPoints]) * 4.4));
				PlayerTextDrawShow(playerid, ClassBackGround[playerid]);

				if(!IsPlayerKnockedOut(playerid))
				{
					if(GetTickCountDifference(GetTickCount(), GetPlayerKnockOutTick(playerid)) > 5000 * ply_Data[playerid][ply_HitPoints])
					{
						if(GetPlayerBleedRate(playerid) > 0.0)
						{
							if(frandom(40.0) < (50.0 - ply_Data[playerid][ply_HitPoints]))
								KnockOutPlayer(playerid, floatround(2000 * (50.0 - ply_Data[playerid][ply_HitPoints]) + frandom(200 * (50.0 - ply_Data[playerid][ply_HitPoints]))));
						}
						else
						{
							if(frandom(40.0) < (40.0 - ply_Data[playerid][ply_HitPoints]))
								KnockOutPlayer(playerid, floatround(2000 * (40.0 - ply_Data[playerid][ply_HitPoints]) + frandom(200 * (40.0 - ply_Data[playerid][ply_HitPoints]))));
						}
					}
				}
			}
		}
		else
		{
			if(ply_Data[playerid][ply_BitFlags] & Spawned)
				PlayerTextDrawHide(playerid, ClassBackGround[playerid]);
		}
	}

	gettime(hour, minute);

	if(IsPlayerUnderDrugEffect(playerid, drug_Lsd))
	{
		hour = 22;
		minute = 3;
		weather = 33;
	}
	else if(IsPlayerUnderDrugEffect(playerid, drug_Heroin))
	{
		hour = 22;
		minute = 30;
		weather = 33;
	}
	else
	{
		weather = gWeatherID;
	}

	SetPlayerTime(playerid, hour, minute);
	SetPlayerWeather(playerid, weather);

	if(IsPlayerUnderDrugEffect(playerid, drug_Air))
	{
		SetPlayerDrunkLevel(playerid, 100000);

		if(random(100) < 50)
			GivePlayerHP(playerid, -0.1);
	}

	if(IsPlayerUnderDrugEffect(playerid, drug_Adrenaline))
	{
		GivePlayerHP(playerid, 0.01);
	}

	PlayerBagUpdate(playerid);

	return;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(IsPlayerNPC(playerid))return 1;

	t:ply_Data[playerid][ply_BitFlags]<FirstSpawn>;

	SetSpawn(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, 0.0);

	return 0;
}

public OnPlayerRequestSpawn(playerid)
{
	if(IsPlayerNPC(playerid))return 1;

	t:ply_Data[playerid][ply_BitFlags]<FirstSpawn>;

	SetSpawn(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, 0.0);

	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == Text:65535)
	{
		if(ply_Data[playerid][ply_BitFlags] & Dying)
		{
			SelectTextDraw(playerid, 0xFFFFFF88);
		}
		else
		{
			ShowWatch(playerid);
		}
	}

	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid))
		return 1;

	if(IsPlayerOnAdminDuty(playerid))
	{
		SetPlayerPos(playerid, 0.0, 0.0, 3.0);
		return 1;
	}

	ply_Data[playerid][ply_SpawnTick] = GetTickCount();

	SetAllWeaponSkills(playerid, 500);
	SetPlayerWeather(playerid, gWeatherID);
	SetPlayerTeam(playerid, 0);
	ResetPlayerMoney(playerid);

	PlayerPlaySound(playerid, 1186, 0.0, 0.0, 0.0);
	PreloadPlayerAnims(playerid);
	SetAllWeaponSkills(playerid, 500);
	Streamer_Update(playerid);

	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(ply_Data[playerid][ply_BitFlags] & Frozen)
		return 0;

	if(IsPlayerInAnyVehicle(playerid))
	{
		static
			str[8],
			Float:vx,
			Float:vy,
			Float:vz;

		GetVehicleVelocity(ply_Data[playerid][ply_CurrentVehicle], vx, vy, vz);
		ply_Data[playerid][ply_Velocity] = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * 150.0;
		format(str, 32, "%.0fkm/h", ply_Data[playerid][ply_Velocity]);
		PlayerTextDrawSetString(playerid, VehicleSpeedText[playerid], str);
	}
	else
	{
		static
			Float:vx,
			Float:vy,
			Float:vz;

		GetPlayerVelocity(playerid, vx, vy, vz);
		ply_Data[playerid][ply_Velocity] = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * 150.0;
	}

	if(ply_Data[playerid][ply_BitFlags] & Alive)
	{
		if(IsPlayerOnAdminDuty(playerid))
			ply_Data[playerid][ply_HitPoints] = 250.0;

		SetPlayerHealth(playerid, ply_Data[playerid][ply_HitPoints]);
		SetPlayerArmour(playerid, ply_Data[playerid][ply_ArmourPoints]);
	}
	else
	{
		SetPlayerHealth(playerid, 100.0);		
	}

	return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		ply_Data[playerid][ply_CurrentVehicle] = GetPlayerVehicleID(playerid);
		ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, " ", " ", " ", " ");
		HidePlayerGear(playerid);
	}

	return 1;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(IsPlayerKnockedOut(playerid))
		return 0;

	if(GetPlayerSurfingVehicleID(playerid) == vehicleid)
		CancelPlayerMovement(playerid);

	if(ispassenger)
	{
		new driverid = -1;

		foreach(new i : Player)
		{
			if(IsPlayerInVehicle(i, vehicleid))
			{
				if(GetPlayerState(i) == PLAYER_STATE_DRIVER)
				{
					driverid = i;
				}
			}
		}

		if(driverid == -1)
			CancelPlayerMovement(playerid);
	}

	return 1;
}

hook OnPlayerExitVehicle(playerid, vehicleid)
{
	ply_Data[playerid][ply_ExitVehicleTick] = GetTickCount();
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerKnockedOut(playerid))
		return 0;

	if(!IsPlayerInAnyVehicle(playerid))
	{
		new weaponid = GetPlayerItemWeaponBaseWeapon(playerid);

		if(weaponid == 34 || weaponid == 35 || weaponid == 43)
		{
			if(newkeys & 128)
			{
				TogglePlayerHeadwear(playerid, false);
				TogglePlayerMask(playerid, false);
			}
			if(oldkeys & 128)
			{
				TogglePlayerHeadwear(playerid, true);
				TogglePlayerMask(playerid, true);
			}
		}
	}

	return 1;
}


forward E_FLAGS:GetPlayerDataBitmask(playerid);
stock E_FLAGS:GetPlayerDataBitmask(playerid)
{
	if(!IsValidPlayerID(playerid))
		return E_FLAGS:0;

	return ply_Data[playerid][ply_BitFlags];
}

stock GetPlayerBitFlag(playerid, E_FLAGS:flag)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return _:(ply_Data[playerid][ply_BitFlags] & flag);
}
stock SetPlayerBitFlag(playerid, E_FLAGS:flag, toggle)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(toggle)
		t:ply_Data[playerid][ply_BitFlags]<flag>;

	else
		f:ply_Data[playerid][ply_BitFlags]<flag>;

	return 1;
}

// Alive
stock IsPlayerAlive(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return _:(ply_Data[playerid][ply_BitFlags] & Alive);
}

// Dying
stock IsPlayerDead(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return _:(ply_Data[playerid][ply_BitFlags] & Dying);
}

// Spawned
stock IsPlayerSpawned(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return _:(ply_Data[playerid][ply_BitFlags] & Spawned);
}

// FirstSpawn

// ToolTips
stock IsPlayerToolTipsOn(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return _:(ply_Data[playerid][ply_BitFlags] & ToolTips);
}

// ShowHUD
stock IsPlayerHudOn(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return _:(ply_Data[playerid][ply_BitFlags] & ShowHUD);
}

// GlobalQuiet

// Frozen

// DebugMode




// ply_Password
stock GetPlayerPassHash(playerid, string[MAX_PASSWORD_LEN])
{
	if(!IsValidPlayerID(playerid))
		return 0;

	string[0] = EOS;
	strcat(string, ply_Data[playerid][ply_Password]);

	return 1;
}

stock SetPlayerPassHash(playerid, string[MAX_PASSWORD_LEN])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_Password] = string;

	return 1;
}

// ply_IP
stock GetPlayerIpAsInt(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_IP];
}

// ply_Karma
stock GetPlayerKarma(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_Karma];
}

// ply_RegisterTimestamp
stock GetPlayerRegTimestamp(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_RegisterTimestamp];
}

stock SetPlayerRegTimestamp(playerid, timestamp)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_RegisterTimestamp] = timestamp;

	return 1;
}

// ply_LastLogin
stock GetPlayerLastLogin(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_LastLogin];
}

stock SetPlayerLastLogin(playerid, timestamp)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_LastLogin] = timestamp;

	return 1;
}

// ply_TotalSpawns
stock GetPlayerTotalSpawns(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_TotalSpawns];
}

stock SetPlayerTotalSpawns(playerid, amount)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_TotalSpawns] = amount;

	return 1;
}

// ply_Warnings
stock GetPlayerWarnings(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_Warnings];
}

stock SetPlayerWarnings(playerid, timestamp)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_Warnings] = timestamp;

	return 1;
}

// ply_HitPoints
forward Float:GetPlayerHP(playerid);
stock Float:GetPlayerHP(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0.0;

	return ply_Data[playerid][ply_HitPoints];
}

stock SetPlayerHP(playerid, Float:hp)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(hp > 100.0)
		hp = 100.0;

	ply_Data[playerid][ply_HitPoints] = hp;

	return 1;
}

// ply_ArmourPoints
forward Float:GetPlayerAP(playerid);
stock Float:GetPlayerAP(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0.0;

	return ply_Data[playerid][ply_ArmourPoints];
}

stock SetPlayerAP(playerid, Float:amount)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(amount <= 0.0)
	{
		amount = 0.0;

		ToggleArmour(playerid, false);
	}
	else
	{
		if(amount > 100.0)
			amount = 100.0;

		ToggleArmour(playerid, true);
	}

	ply_Data[playerid][ply_ArmourPoints] = amount;

	return 1;
}

// ply_FoodPoints
forward Float:GetPlayerFP(playerid);
stock Float:GetPlayerFP(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0.0;

	return ply_Data[playerid][ply_FoodPoints];
}

stock SetPlayerFP(playerid, Float:food)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_FoodPoints] = food;

	return 1;
}

// ply_Clothes
stock GetPlayerClothesID(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_Clothes];
}

stock SetPlayerClothesID(playerid, id)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_Clothes] = id;

	return 1;
}

// ply_Gender
stock GetPlayerGender(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_Gender];
}

stock SetPlayerGender(playerid, gender)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_Gender] = gender;

	return 1;
}

// ply_Velocity
forward Float:GetPlayerTotalVelocity(playerid);
Float:GetPlayerTotalVelocity(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0.0;

	return ply_Data[playerid][ply_Velocity];
}

// ply_SpawnPosX
// ply_SpawnPosY
// ply_SpawnPosZ
stock GetPlayerSpawnPos(playerid, &Float:x, &Float:y, &Float:z)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	x = ply_Data[playerid][ply_SpawnPosX];
	y = ply_Data[playerid][ply_SpawnPosY];
	z = ply_Data[playerid][ply_SpawnPosZ];

	return 1;
}

stock SetPlayerSpawnPos(playerid, Float:x, Float:y, Float:z)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_SpawnPosX] = x;
	ply_Data[playerid][ply_SpawnPosY] = y;
	ply_Data[playerid][ply_SpawnPosZ] = z;

	return 1;
}

// ply_SpawnRotZ
stock GetPlayerSpawnRot(playerid, &Float:r)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	r = ply_Data[playerid][ply_SpawnRotZ];

	return 1;
}

stock SetPlayerSpawnRot(playerid, Float:r)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_SpawnRotZ] = r;

	return 1;
}

// ply_RadioFrequency
forward Float:GetPlayerRadioFrequency(playerid);
stock Float:GetPlayerRadioFrequency(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0.0;

	return ply_Data[playerid][ply_RadioFrequency];
}
stock SetPlayerRadioFrequency(playerid, Float:frequency)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_RadioFrequency] = frequency;

	return 1;
}

// ply_CreationTimestamp
stock GetPlayerCreationTimestamp(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_CreationTimestamp];
}

stock SetPlayerCreationTimestamp(playerid, timestamp)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_CreationTimestamp] = timestamp;

	return 1;
}

// ply_AimShoutText
stock GetPlayerAimShoutText(playerid, string[])
{
	if(!IsValidPlayerID(playerid))
		return 0;

	string[0] = EOS;
	strcat(string, ply_Data[playerid][ply_AimShoutText], 128);

	return 1;
}
stock SetPlayerAimShoutText(playerid, string[128])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_AimShoutText] = string;

	return 1;
}


// ply_ChatMode
stock GetPlayerChatMode(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_ChatMode];
}
stock SetPlayerChatMode(playerid, chatmode)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_ChatMode] = chatmode;

	return 1;
}

// ply_CurrentVehicle
stock GetPlayerLastVehicle(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_CurrentVehicle];
}

// ply_PingLimitStrikes
// ply_ScreenBoxFadeLevel
stock GetPlayerScreenFadeLevel(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_ScreenBoxFadeLevel];
}
stock SetPlayerScreenFadeLevel(playerid, level)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(level > 255)
		level = 255;

	if(level < 0)
		level = 0;

	ply_Data[playerid][ply_ScreenBoxFadeLevel] = level;

	return 1;
}

// ply_stance
stock GetPlayerStance(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_stance];
}

stock SetPlayerStance(playerid, stance)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_stance] = stance;

	return 1;
}

// ply_JoinTick
stock GetPlayerServerJoinTick(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_JoinTick];
}

// ply_SpawnTick
stock GetPlayerSpawnTick(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_SpawnTick];
}

// ply_ExitVehicleTick
stock GetPlayerVehicleExitTick(playerid)
{
	if(!IsValidPlayerID(playerid))
		return 0;

	return ply_Data[playerid][ply_ExitVehicleTick];
}
