#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include redux\common;


altSwapToggle()
{
    if ( !self.pers["altswap"] )
    {
        self.pers["savedweapon"] = self getCurrentWeapon();
        self.pers["altswap"] = true;
        self giveWeapon( self.pers["savedweapon"] );
    }
    else
    {
        self.pers["altswap"] = false;
        self takeWeapon( self.pers["savedweapon"] );
    }
        self iPrintLnBold( "Alt Swap: " + boolToText(self.pers["altswap"] ) );
        wait 2;
        self iPrintLnBold( "Alt Swap Weapon: " + ( self.pers["savedweapon"] ) );
        wait 5;
}

classChangeWatch()
{
    self endon( "game_ended" );

    oldclass = self.pers["class"];

    for ( ;; )
    {
        if ( self.pers["altswap"] )
        {
            
   	        if ( self.pers["class"] != oldclass )
	        {
		        self giveWeapon( self.pers["savedweapon"] );
	        }
            oldclass = self.pers["class"];
        }
        wait 0.05;
    }
}

ufoModeToggle()
{
    if ( !self.pers["allow_ufo"] ) 
    {
        self thread ufoMode();
        self.pers["allow_ufo"] = true;  
        self disableweapons();
        self.owp=self getWeaponsListOffhands();
        foreach( w in self.owp )
        self takeweapon( w );
    } 
    else 
    { 
        self.pers["allow_ufo"] = false;
        self notify( "noclipoff" );
        self unlink();
        self enableweapons();
        foreach( w in self.owp )
        self giveweapon( w );
    }
    self iPrintLnBold( "UFO Mode: " + boolToText( self.pers["allow_ufo"] ) );
}

ufoMode()
{ 
    self endon( "death" ); 
    self endon( "noclipoff" );

    if ( isdefined( self.newufo ) ) self.newufo delete(); 
        self.newufo = spawn( "script_origin", self.origin ); 
        self.newufo.origin = self.origin; 
        self playerlinkto( self.newufo );

    for( ;; )
    { 

        
        vec=anglestoforward( self getPlayerAngles() );
        if ( self FragButtonPressed() )
        {
            end=( vec[0]*60,vec[1]*80,vec[2]*60 );
            self.newufo.origin=self.newufo.origin+end;
        }
        if ( self SecondaryOffhandButtonPressed() )
        {
            end=( vec[0]*10,vec[1]*10, vec[2]*10 );
            self.newufo.origin=self.newufo.origin+end;
        }
        if ( self attackButtonPressed() )
        {
            self thread ufoSavePos();
            wait 1;
        }
        if ( self adsButtonPressed() )
        {
            self redux\botfuncs::botTele();
            wait 1;
        }
        else if ( self meleeButtonPressed() ) 
        {
            self thread ufoModeToggle();
        }
        
        wait 0.05; 
    } 
}

ufoSavePos()
{
	if ( !self isOnGround() )
	{
		self iPrintLnBold( "Your saving mid air, make sure your not stuck in something idiot." );
        wait 2.5;
	}

	self.pers["saved_position"] = spawnStruct();
	self.pers["saved_position"].origin = self getOrigin();
	self.pers["saved_position"].angles = self getPlayerAngles();
    wait 1;
	self iPrintLnBold( "Saved position." );
}

savePos()
{
	if ( !self isOnGround() )
	{
		self iPrintLnBold( "Can't save position here." );
		return;
	}

	self.pers["saved_position"] = spawnStruct();
	self.pers["saved_position"].origin = self getOrigin();
	self.pers["saved_position"].angles = self getPlayerAngles();
	self iPrintLnBold( "Saved position." );
}

loadPos()
{
	if ( !isDefined( self.pers["saved_position"] ) )
	{
		self iPrintLnBold( "No saved position found." );
		return;
	}

	self setOrigin( self.pers["saved_position"].origin );
	self setPlayerAngles( self.pers["saved_position"].angles );
}

forceSpawn()
{
    self setOrigin( self.pers["saved_position"].origin );
	self setPlayerAngles( self.pers["saved_position"].angles );
}

sndRoundReset()
{
	game["roundsWon"]["axis"] = 0;
	game["roundsWon"]["allies"] = 0;
	game["teamScores"]["allies"] = 0;
	game["teamScores"]["axis"] = 0;
	game["roundsPlayed"] = 3;

	maps\mp\gametypes\_gamescore::updateTeamScore( "axis" );
	maps\mp\gametypes\_gamescore::updateTeamScore( "allies" );

	wait .05;

	level notify( "updating_scores" );
	level endon( "updating_scores" );

	wait .05;

	self updateScores();
	self iPrintLnBold( "Rounds have been reset" );

}

dropWep()
{
	weapon = self getCurrentWeapon();

	if ( isKillstreakWeapon( weapon ) || isSubStr( weapon, "briefcase" ) )
	{
		self iPrintLnBold( "Can't drop this weapon." );
		return;
	}

	weapons = self getWeaponsListPrimaries();
	self dropItem( weapon );
    self iPrintLnBold( "Dropped:^2 " + ( weapon ) );

	while ( self getCurrentWeapon() == "none" )
	{
		waitframe();
		self switchToWeapon( weapons[ randomInt( weapons.size ) ] );
	}
}
