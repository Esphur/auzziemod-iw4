#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include redux\functions;

init()
{
	if ( level.script == "oilrig" )
		thread createRamp( ( 1676, 1330, -70 ), ( 2489, 1844, 900 ) );

	level.onlineGame = true;
	level.rankedMatch = true;
	level.modifyPlayerDamage = ::modifyPlayerDamage;
	level.player_out_of_playable_area_monitor = 0;

	level._effect["flesh_body"] = loadFX( "impacts/flesh_hit_body_fatal_exit" );
	level._effect["flesh_head"] = loadFX( "impacts/flesh_hit_head_fatal_exit" );
	
	// asset precaching
    if ( !isDefined( game["precachedAssets"] ) )
    {
        precacheMenu( "map_voting" );
        precacheMenu( "loadout" );
        precacheMenu( "loadout_select" );
        precacheMenu( "mod_options" );
        precacheMenu( "callvote" );

        precacheItem( "cheytac_irons_mp" );
        precacheItem( "ax50_mp" );
        precacheItem( "m200_mp" );
        precacheItem( "l115a3_mp" );
        precacheItem( "msr_mp" );

        game["precachedAssets"] = true;
    }

	level thread redux\voting::init();
	level thread onPlayerConnect();
	level thread redux\dvars::runDvars();

	if ( level.gametype == "sd" )
	{
		level waittill( "update_scorelimit" );
		setDvar( "ui_allow_teamchange", 0 );
		setDvar( "scr_sd_roundswitch", 0 );
	}
}

createRamp( top, bottom )
{
	blocks = ceil( ( distance( top, bottom ) ) / 30 );
	cx = top[0] - bottom[0];
	cy = top[1] - bottom[1];
	cz = top[2] - bottom[2];
	xz = cx / blocks;
	ya = cy / blocks;
	za = cz / blocks;
	angles = vectorToAngles( top - bottom );

	for ( b = 0; b < blocks; b++ )
	{
		block = spawn( "script_model", ( bottom + ( ( xz, ya, za ) * b ) ) );
		block.angles = ( angles[2], angles[1] + 90, angles[0] );
		block solid();
		block cloneBrushmodelToScriptmodel( level.airDropCrateCollision );
		waitframe();
	}

	block = spawn( "script_model", ( bottom + ( ( xz, ya, za ) * blocks ) - ( 0, 0, 5 ) ) );
	block.angles = ( angles[2], angles[1] + 90, 0 );
	block solid();
	block cloneBrushmodelToScriptmodel( level.airDropCrateCollision );
}

onPlayerConnect()
{
	for ( ;; )
	{
		level waittill( "connected", player );

		if ( !player isTestClient() )
		{
			if ( !isDefined( player.pers["loadout"] ) )
				player.pers["loadout"] = [];
			if ( !isDefined( player.pers["altswap"] ) )
				player.pers["altswap"] = false;

			player thread redux\commands::init();
			player thread redux\ui_callbacks::onScriptMenuResponse();

			player childthread beginAutoPlant();
		}

		if ( level.gametype == "sd" )
			player thread onJoinedTeam();

		player thread onPlayerSpawned();
	}
}

rememberFunc()
{
    if ( self.pers["altswap"] == true )
	    wait 2;
        self giveWeapon( self.pers["savedweapon"] );
}

onPlayerSpawned()
{
	self endon( "disconnect" );
	for ( ;; )
	{
		self waittill( "spawned_player" );
		if ( !self isTestClient() )

            self.hasRadar = true;
		    self.radarMode = "fast_radar";

		    self childthread sustainAmmo();
		    self childthread rememberFunc();
		    self childthread deathBarrierFix();
			self redux\functions::forceSpawn();
			self redux\botfuncs::botForceSpawn();
			self redux\functions::classChangeWatch();

		if ( self isTestClient() )
			self childthread botLogPosition();
	}
}

onJoinedTeam()
{
	self endon( "disconnect" );

    if ( self isTestClient() )
        self maps\mp\gametypes\_menus::addToTeam( "allies", true );
    else
        self maps\mp\gametypes\_menus::addToTeam( "axis", true );

	for ( ;; )
	{
		self waittill_any( "joined_team" );

		// failsafe
		if ( self isTestClient() && self.pers["team"] != "allies" )
			self [[level.allies]]();

		if ( !self isTestClient() && self.pers["team"] != "axis" )
			self [[level.axis]]();
	}
}

deathBarrierFix()
{
	ents = getEntArray();
	for ( index = 0; index < ents.size; index++ )
	{
		self.fix = false;
				
		if ( isSubStr(ents[index].classname, "trigger_hurt" ) )
		{
			ents[index].origin = ( 0, 0, 10000 );
			setDvar( "dbarriers", "1" );
		}
	}
}

sustainAmmo()
{
	self endon( "death" );

	for ( ;; )
	{
		self waittill_notify_or_timeout( "reload", 10 );

		if ( !isAlive( self ) )
			continue;

		foreach ( weapon in self getWeaponsListAll() )
		{
			if ( maps\mp\gametypes\_weapons::isPrimaryWeapon( weapon ) )
				self setWeaponAmmoStock( weapon, weaponMaxAmmo( weapon ) );
			else
				self setWeaponAmmoClip( weapon, self getWeaponAmmoClip( weapon ) + 1 );
		}
	}
}

Select( eval, a, b )
{
	if ( eval )
		return a;

	return b;
}

modifyPlayerDamage( victim, eAttacker, iDamage, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc )
{
	if ( victim isTestClient() && ( !isDefined( sMeansOfDeath ) || sMeansOfDeath == "MOD_TRIGGER_HURT" ) )
	{
		victim thread botTeleportFix();
		return 0;
	}

	if ( sMeansOfDeath == "MOD_FALLING" )
		return Select( level.gametype == "sd", 0, iDamage );

	if ( isKillstreakWeapon( sWeapon ) )
		return 0;

	if ( eAttacker isTestClient() )
		return Select( victim isTestClient(), iDamage, iDamage * 0.25 );

	if ( sMeansOfDeath == "MOD_MELEE"
	        || sMeansOfDeath == "MOD_GRENADE"
	        || sMeansOfDeath == "MOD_GRENADE_SPLASH"
	        || sMeansOfDeath == "MOD_PROJECTILE"
	        || sMeansOfDeath == "MOD_PROJECTILE_SPLASH"
	        || sMeansOfDeath == "MOD_EXPLOSIVE"
	        || sMeansOfDeath == "MOD_IMPACT" )
		iDamage = 1;

	if ( isSubStr( sWeapon, "gl_" ) && sMeansOfDeath == "MOD_IMPACT" )
		iDamage = 99999;

	if ( isBulletDamage( sMeansOfDeath ) && getWeaponClass( sWeapon ) != "weapon_sniper" )
		iDamage = 1;

	// Mala fix
	if ( isBulletDamage( sMeansOfDeath ) && ( getWeaponClass( sWeapon ) == "weapon_grenade" || getWeaponClass( sWeapon ) == "weapon_explosive" ) )
		iDamage = 99999;

	if ( getWeaponClass( sWeapon ) == "weapon_sniper" || sWeapon == "throwingknife_mp" )
		iDamage = 99999;

	return iDamage;
}

consolePrint( head, msg )
{
	printConsole( "^6[" + head + "] ^7" + msg + "\n" );
}

botTeleportFix()
{
	self setOrigin( self.lastOnGround + ( 0, 0, 10 ) );

	self.stop = true;
	self.bot.target = self;
	self.bot.towards_goal = undefined;
	self.bot.script_goal = undefined;

	self notify( "kill_goal" );
	self notify( "new_goal_internal" );
	self notify( "bad_path_internal" );

	wait 7;
	self.stop = undefined;
}

botLogPosition()
{
	level endon( "game_ended" );
	self endon( "disconnect" );

	if ( level.gametype == "sd" )
		self endon( "death" );

	self.lastOnGround = ( 0, 0, 0 );

	for ( ;; )
	{
		if ( self isOnGround() )
			self.lastOnGround = self.origin;

		wait 5;
	}
}

beginAutoPlant()
{
	level endon( "game_ended" );
	level waittill( "spawned_player" );
	for ( ;; )
    {	
		if ( maps\mp\gametypes\_gamelogic::getTimeRemaining() < 5010 )
        {
			thread forceBombPlant();
			return;
		}
		wait 1;
	}
}

boolToText( bool )
{
    if ( bool )
        return "[^2On^7]";
    else
        return "[^1Off^7]";
}

forceBombPlant()
{	
    if ( level.bombplanted )
        return;
	
    self thread maps\mp\gametypes\_hud_message::SplashNotify( "plant", maps\mp\gametypes\_rank::getScoreInfoValue( "plant" ) );
    level thread teamPlayerCardSplash( "callout_bombplanted", self, self.pers["team"] );
    self thread maps\mp\gametypes\_rank::giveRankXP( "plant" );
    self.bombPlantedTime = getTime();
    maps\mp\gametypes\_gamescore::givePlayerScore( "plant", self );	
    self playSound( "mp_bomb_plant" );
    leaderDialog( "bomb_planted" );

    if ( cointoss() )
    {
        level thread maps\mp\gametypes\sd::bombplanted( level.bombZones[0], undefined );
        level.bombZones[1] maps\mp\gametypes\_gameobjects::disableObject();
    }
	else
	{
        level thread maps\mp\gametypes\sd::bombplanted( level.bombZones[1], undefined );
        level.bombZones[0] maps\mp\gametypes\_gameobjects::disableObject();
    }
}
