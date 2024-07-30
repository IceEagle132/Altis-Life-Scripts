#include "..\..\script_macros.hpp"
/*
    File: fn_jailMe.sqf
    Author: Bryan "Tonic" Boardwine

    Description:
    Once word is received by the server the rest of the jail execution is completed.
*/

private ["_time", "_bail", "_esc", "_countDown"];

params [
    ["_ret", [], [[]]],
    ["_bad", false, [false]],
    ["_time", 15, [0]]
];

// Calculate the end time for the jail period
_time = time + (_time * 60);

// Set bail amount
if (count _ret > 0) then { 
    life_bail_amount = (_ret select 2); 
} else { 
    life_bail_amount = 1500; 
};

_esc = false;
_bail = false;

// Ensure a fallback time if provided time is zero
if (_time <= 0) then { 
    _time = time + (15 * 60); 
    hintC "Please Report to Admin: JAIL_FALLBACK_15, time is zero!"; 
};

// Control when bail can be paid
[_bad, _time] spawn {
    life_canpay_bail = false;
    //life_bail_amount = life_bail_amount * 5;
    if (_this select 0) then {
        sleep ((_this select 1) * 0.5);
    } else {
        sleep ((_this select 1) * 0.2);
    };
    life_canpay_bail = true;
};

for "_i" from 0 to 1 step 0 do {
    if (round(_time - time) > 0) then {
        _countDown = [(_time - time), "MM:SS.MS"] call BIS_fnc_secondsToString;
        [format [
            (localize "STR_Jail_Time") + "<br/> <t size='2'><t color='#FF0000'>%1</t></t><br/><br/>" + 
            (localize "STR_Jail_Pay") + " %3<br/>" + 
            (localize "STR_Jail_Price") + " $%2", 
            _countDown, 
            [life_bail_amount] call life_fnc_numberText, 
            if (life_canpay_bail) then {"Yes"} else {"No"}
        ], "info", 20] spawn advanced_notifications_tpfn_displayMessage;
    };

    // Force walk if setting is enabled
    if (LIFE_SETTINGS(getNumber, "jail_forceWalk") isEqualTo 1) then {
        player forceWalk true;
    };

    // Determine escape distance based on terrain
    private _escDist = [[["Altis", 60], ["Tanoa", 145]]] call TON_fnc_terrainSort;

    // Check for escape attempt
    if (player distance (getMarkerPos "jail_marker") > _escDist) exitWith {
        _esc = true;
    };

    // Check if bail is paid
    if (life_bail_paid) exitWith {
        _bail = true;
    };

    // Check if jail time is over
    if (round(_time - time) < 1) exitWith {
        ["", 'info', 20] spawn advanced_notifications_tpfn_displayMessage;
    };

    // Check if player is dead
    if (!alive player && {(round(_time - time)) > 0}) exitWith {};
    
    sleep 0.1;
};

switch (true) do {
    case (_bail): {
        life_is_arrested = false;
        life_bail_paid = false;

        hint localize "STR_Jail_Paid";
        serv_wanted_remove = [player];
        player setPos (getMarkerPos "jail_release");
        player setVariable ["JailTime", 0];

        if (life_HC_isActive) then {
            [getPlayerUID player] remoteExecCall ["HC_fnc_wantedRemove", HC_Life];
        } else {
            [getPlayerUID player] remoteExecCall ["life_fnc_wantedRemove", RSERV];
        };

        [5] call SOCK_fnc_updatePartial;
    };

    case (_esc): {
        life_is_arrested = false;
        hint localize "STR_Jail_EscapeSelf";
        [0, "STR_Jail_EscapeNOTF", true, [profileName]] remoteExecCall ["life_fnc_broadcast", west];
        player setVariable ["JailTime", 0];
        
        if (life_HC_isActive) then {
            [getPlayerUID player, profileName, "901"] remoteExecCall ["HC_fnc_wantedAdd", HC_Life];
        } else {
            [getPlayerUID player, profileName, "901"] remoteExecCall ["life_fnc_wantedAdd", RSERV];
        };
       
        [5] call SOCK_fnc_updatePartial;
    };

    case (alive player && !_esc && !_bail): {
        life_is_arrested = false;
        hint localize "STR_Jail_Released";

        if (life_HC_isActive) then {
            [getPlayerUID player] remoteExecCall ["HC_fnc_wantedRemove", HC_Life];
        } else {
            [getPlayerUID player] remoteExecCall ["life_fnc_wantedRemove", RSERV];
        };

        player setPos (getMarkerPos "jail_release");
        [5] call SOCK_fnc_updatePartial;
    };
};

// Allow the player to run and jump again
player forceWalk false;