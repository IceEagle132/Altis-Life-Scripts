#include "..\..\script_macros.hpp"
/*
    File: fn_showArrestDialog.sqf
    Description: Shows cop arrest dialog
*/

// Check if the player is on the west side (cop)
if (playerSide != west) exitWith {
    hint "You do not have the authority to make arrests!";
};

// Create the arrest dialog
createDialog "jail_time";