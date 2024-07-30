#include "..\..\script_macros.hpp"
/*
    File: fn_jail.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Starts the initial process of jailing.
*/

private ["_illegalItems"];
params [
    ["_unit", objNull, [objNull]],
    ["_bad", false, [false]],
    ["_time", 15, [0]]
];

// Check if the unit is valid
if (isNull _unit) exitWith {
    hint "Invalid unit!";
};

// Ensure the unit is the player
if !(_unit isEqualTo player) exitWith {
    hint "You can only jail yourself!";
};

// Check if the player is already arrested
if (life_is_arrested) exitWith {
    hint "You are already arrested!";
};

// Get existing jail time if applicable
if !((_unit getVariable ["JailTime", 0]) isEqualTo 0) then {
    _time = (_unit getVariable ["JailTime", 0]);
};

_illegalItems = LIFE_SETTINGS(getArray, "jail_seize_vItems");

// Reset player variables related to arrest
player setVariable ["restrained", false, true];
player setVariable ["Escorting", false, true];
player setVariable ["transporting", false, true];

// Show jail warning and notification
titleText [localize "STR_Jail_Warn", "PLAIN"];
[localize "STR_Jail_LicenseNOTF", 'warning', 20] spawn advanced_notifications_tpfn_displayMessage;

// Move player to jail marker position
player setPos (getMarkerPos "jail_marker");

if (_bad) then {
    waitUntil {alive player};
    sleep 1;
};

// Ensure the player stays within jail bounds
if (player distance (getMarkerPos "jail_marker") > 40) then {
    player setPos (getMarkerPos "jail_marker");
};

// Remove licenses
[1] call life_fnc_removeLicenses;

// Handle illegal items
{
    _amount = ITEM_VALUE(_x);
    if (_amount > 0) then {
        [false, _x, _amount] call life_fnc_handleInv;
    };
} forEach _illegalItems;

// Set the player as arrested
life_is_arrested = true;

// Seize inventory if setting is enabled
if (LIFE_SETTINGS(getNumber, "jail_seize_inventory") isEqualTo 1) then {
    [] spawn life_fnc_seizeClient;
} else {
    removeAllWeapons player;
    {player removeMagazine _x} forEach (magazines player);
};

// Execute jail system on HC or server
if (life_HC_isActive) then {
    [player, _bad, _time] remoteExecCall ["HC_fnc_jailSys", HC_Life];
} else {
    [player, _bad, _time] remoteExecCall ["life_fnc_jailSys", RSERV];
};

// Update the database
[5] call SOCK_fnc_updatePartial;
