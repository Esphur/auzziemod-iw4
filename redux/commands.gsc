#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;


init()
{
	level endon( "game_ended" );
	self endon( "disconnect" );

	_ = [];

	//_["suicide"] = ::_suicide;
	_["bottele"] = redux\botfuncs::botTele;
	_["botmovement"] = redux\botfuncs::botMoveFreeze;
	_["botaggression"] = redux\botfuncs::botFires;
	_["dropwep"] = redux\functions::dropWep;
	_["ufomode"] = redux\functions::ufoModeToggle;
	
	_["savepos"] = redux\functions::savePos;
	_["loadpos"] = redux\functions::loadPos;

	_["roundreset"] = redux\functions::sndRoundReset;
	_["altswap"] = redux\functions::altSwapToggle;

	foreach ( name, func in _ )
		self childthread run( name, func );
}

run( name, func )
{
	self setClientDvar( name, "Script command" );
	self notifyOnPlayerCommand( name, name );

	for ( ;; )
	{
		self waittill( name );
		self thread [[func]]();
	}
}
