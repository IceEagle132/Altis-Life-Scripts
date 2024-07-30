/*
    File: fn_managePlayer.sqf
    Description:
    Kicks or bans a player and logs the event to the database.

    Parameters:
        0: OBJECT (Player to be managed)
        1: STRING (Action to be taken: "kick" or "ban")
        2: STRING (Reason for the action, optional)
        3: STRING (Duration for the ban, optional)

    Usage:
    [player, "kick", "Reason for kick"] remoteExecCall ["TON_fnc_managePlayer",RSERV];
    [player, "ban", "3600", "Reason for ban"] remoteExecCall ["TON_fnc_managePlayer",RSERV];
*/

// Validate parameters
params ["_player", "_action", ["_duration", "0"], ["_reason", "No reason provided"]];
if (!isPlayer _player) exitWith {};

// Get player details
private _playerID = getPlayerUID _player;
private _playerName = name _player;
private _guid = ('BEGuid' callExtension (["get", _playerID] joinString ":"));

// Action handlers
switch (_action) do {
    case "kick": {
        // Execute the kick command
        format ['#kick "%1"', _playerID] call TON_fnc_sendCommand;
        
        // Log the kick event
        diag_log format ["Player: %1 (UID: %2) has been kicked for: %3", _playerName, _playerID, _reason];

        // Prepare and execute the SQL query to log the kick event in the database
        private _query = format [
            "INSERT INTO kick_log (player_name, player_uid, reason) VALUES ('%1', '%2', '%3')",
            _playerName, _playerID, _reason
        ];
        [_query, 1, false] call DB_fnc_asyncCall;
    };
    
    case "ban": {
        // Execute the ban command
        format ["#beserver addBan %1 %2 %3", _guid, _duration, _reason] call TON_fnc_sendCommand;
        "#beserver writeBans" call TON_fnc_sendCommand;
        "#beserver loadBans" call TON_fnc_sendCommand;

        // Log the ban event
        diag_log format ["Player: %1 (UID: %2) has been banned for: %3", _playerName, _playerID, _reason];

        // Prepare and execute the SQL query to log the ban event in the database
        private _query = format [
            "INSERT INTO ban_log (player_name, player_uid, reason, duration) VALUES ('%1', '%2', '%3', '%4')",
            _playerName, _playerID, _reason, _duration
        ];
        [_query, 1, false] call DB_fnc_asyncCall;
    };

    default {
        diag_log "Invalid action specified. Use 'kick' or 'ban'.";
    };
};