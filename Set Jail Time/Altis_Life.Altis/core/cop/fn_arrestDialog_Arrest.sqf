#include "..\..\script_macros.hpp"
/*
    File: fn_arrestDialog_Arrest.sqf
    Author: Alan
    Description: Arrests the selected player
*/

private ["_time"];
if (playerSide != west) exitWith {
    hint "You do not have the authority to make arrests!";
};

if (isNil "life_pInact_curTarget") exitWith {
    hint "No target selected!";
};

// Get minutes from the dialog input
_time = ctrlText 1400;

if (!([_time] call TON_fnc_isnumber)) exitWith {
    hint localize "STR_ATM_notnumeric";
};

_time = parseNumber _time; // requested number
_time = round _time;

// Constants for min and max jail time
private _minJailTime = 5;
private _maxJailTime = 120;

if (_time < _minJailTime || _time > _maxJailTime) exitWith {
    hint format ["The time must be between %1 and %2 minutes!", _minJailTime, _maxJailTime];
};

closeDialog 0;

// Call the arrest action function with the selected target and time
[life_pInact_curTarget, _time] call life_fnc_arrestAction;