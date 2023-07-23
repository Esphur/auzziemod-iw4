#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

runDvars()
{
    game["strings"]["change_class"] = undefined; //Removes Class Change Text
    level.pers["meters"] = 10; //Meters required to kill.
    level.pers["almost_hit_sens"] = 2; //Almost hit sensitivity.
    level setClientDvar( "g_teamcolor_myteam", "0.501961 0.8 1 1" ); 	
    level setClientDvar( "g_teamTitleColor_myteam", "0.501961 0.8 1 1" );

    setDvarIfUninitialized( "class_change", 1 ); // enables/disabled mid-game cc
    setDvarIfUninitialized( "first_blood", 0 ); // enables/disabled first blood

    setDvar( "safeArea_adjusted_horizontal", 0.85 );
    setDvar( "safeArea_adjusted_vertical", 0.85 );
    setDvar( "safeArea_horizontal", 0.85 );
    setDvar( "safeArea_vertical", 0.85 );
    setDvar( "scr_sd_multibomb", "1" );
    setDvar( "ui_streamFriendly", true );
    setDvar( "cg_newcolors", 0 );
    setDvar( "intro", 0 );
    setDvar( "cl_autorecord", 0 );
    setDvar( "snd_enable3D" , 1 );
    setDvar( "bg_fallDamageMaxHeight", 9999999 );
    setDvar( "bg_fallDamageMinHeight", 9999999 );
    setDvar( "cg_overheadnamessize", 0.80 );
    setDvar( "g_knockback", 1 );
	setDvar( "bg_surfacePenetration", 128 );
	setDvar( "player_sprintUnlimited", true );
	setDvar( "bg_viewKickMin", 2 );
	setDvar( "bg_viewKickMax", 10 );
	setDvar( "bg_viewKickRandom", 0.4 );
	setDvar( "bg_viewKickScale", 0.15 );
    setDvar( "player_lean_rotate_left", 3 );
    setDvar( "player_lean_shift_left", 20 );
    setDvar( "player_lean_shift_right", 20 );
    setDvar( "jump_ladderpushvel", 128 ); // default ladder jump velo
    setDvar( "jump_height", 39 ); // default jump height
    setDvar( "g_gravity", 800 ); // default gravity
    setDvar( "bg_shock_movement", 0 ); // concussion/flash effect - not entriely sure if this is even it
    setDvar( "player_backSpeedScale", 0.7 ); // default backwards run speed
    // setDvar( "player_useRadius", 128 ); // default use/pickup radius
    setDvar( "g_speed", 190 ); // default run speed
    // setDvar( "sv_padpackets", 5000 ); // defaults ping to 60-70
    setDvar( "scr_sd_timelimit", 2.5 ); // stops unlimited time
    setDvar( "jump_slowdownEnable", 0 ); // removes jump fatigue
    setDvar( "bg_surfacePenetration", 9999 ); // wallbang everything
    setDvar( "bg_bulletRange", 99999 ); // no bullet trail limit
    setDvar( "sv_allowAimAssist", 1 ); // aim assist enable/disable
    setDvar( "bg_bounces", 2 ); // allow double bouncing
    setDvar( "bg_elevators", 2 ); // allow ez elevators
    // setDvar( "bg_rocketJump", 1 ); // allow rocket jumps
    setDvar( "bg_bouncesAllAngles", 1 ); // allow multi bouncing
    setDvar( "bg_playerEjection", 0 ); // removes collision
    setDvar( "bg_playerCollision", 0 ); // removes ejection
    setDvar( "dbarriers", 1 ); // 0 dbarriers are on, 1 they are off.
    setDvar( "mantle_check_angle", 180 ); // can grab mantles from 180 degrees
    setDvar( "mantle_view_yawcap", 180 ); // enables spins during mantles
    setDvar( "player_lean_rotate_right", 3 ); // all of these are cooking up lean angles
}

resetDvars()
{
    setDvar( "jump_height", 39 );
    setDvar( "g_gravity", 800 );
    setDvar( "player_backSpeedScale", 0.7 );
    setDvar( "g_speed", 190 );
}