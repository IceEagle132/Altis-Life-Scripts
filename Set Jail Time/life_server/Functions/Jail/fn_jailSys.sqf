#include "\life_server\script_macros.hpp"
/*
    File: fn_jailSys.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Handles the jail system.
*/

private ["_unit", "_bad", "_time", "_query", "_result", "_id", "_ret"];

// Get parameters
_unit = [_this, 0, objNull, [objNull]] call BIS_fnc_param;
_bad = [_this, 1, false, [false]] call BIS_fnc_param;
_time = [_this, 2, 15, [0]] call BIS_fnc_param;

// Validate unit
if (isNull _unit) exitWith {
    diag_log "Invalid unit.";
};

// Handle jail time based on _bad status
if (_bad) then {
    // Load time from database
    _query = format ["SELECT jail_time FROM players WHERE pid='%1'", getPlayerUID _unit];
    _result = [_query, 2] call DB_fnc_asyncCall;
    _time = _result select 0;
    
    // Check if jail time is up
    if (_time <= 0) then {
        // Update jail time in database to 0
        _query = format ["UPDATE players SET jail_time='0' WHERE pid='%1'", getPlayerUID _unit];
        _result = [_query, 1] call DB_fnc_asyncCall;
    };
} else {
    // Update jail time in database
    _query = format ["UPDATE players SET jail_time='%1' WHERE pid='%2'", _time, getPlayerUID _unit];
    _result = [_query, 1] call DB_fnc_asyncCall;
};

// Get owner ID and wanted status
_id = owner _unit;
_ret = [_unit] call life_fnc_wantedPerson;

// Execute jail function on client
[_ret, _bad, _time] remoteExec ["life_fnc_jailMe", _id];