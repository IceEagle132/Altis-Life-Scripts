#include "..\..\script_macros.hpp"
/*
    File: fn_arrestAction.sqf
    Author:

    Description:
    Arrests the targeted person.
*/

private ["_unit", "_time"];
_unit = param [0, objNull, [objNull]];
_time = param [1, 30];

// Check if the unit is valid
if (isNull _unit) exitWith {
    hint "Invalid unit!";
};

// Ensure the unit is a man and a player
if (!(_unit isKindOf "Man")) exitWith {
    hint "Target is not a valid unit!";
};

if (!isPlayer _unit) exitWith {
    hint "Target is not a human player!";
};

// Check if the unit is restrained
if (!(_unit getVariable "restrained")) exitWith {
    hint "Target is not restrained!";
};

// Check if the unit belongs to a valid side
if (!((side _unit) in [civilian, independent, east])) exitWith {
    hint "Target is not a civilian, independent, or east!";
};

// Ensure the jail time is valid
if (_time < 1) exitWith {
    hint "Invalid jail time!";
};

// Handle the arrest based on HC status
if (life_HC_isActive) then {
    [getPlayerUID _unit, _unit, player, false] remoteExecCall ["HC_fnc_wantedBounty", HC_Life];
} else {
    [getPlayerUID _unit, _unit, player, false] remoteExecCall ["life_fnc_wantedBounty", RSERV];
};

// Detach the unit and execute jail process
detach _unit;
[_unit, false, _time] remoteExecCall ["life_fnc_jail", _unit];
[0, "STR_NOTF_Arrested_1", true, [_unit getVariable ["realname", name _unit], profileName]] remoteExecCall ["life_fnc_broadcast", west];

// Log the arrest if advanced logging is enabled
if (LIFE_SETTINGS(getNumber, "player_advancedLog") isEqualTo 1) then {
    if (LIFE_SETTINGS(getNumber, "battlEye_friendlyLogging") isEqualTo 1) then {
        advanced_log = format [localize "STR_DL_AL_Arrested_BEF", _unit getVariable ["realname", name _unit]];
    } else {
        advanced_log = format [localize "STR_DL_AL_Arrested", profileName, (getPlayerUID player), _unit getVariable ["realname", name _unit]];
    };
    publicVariableServer "advanced_log";
};