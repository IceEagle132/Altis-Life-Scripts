Make sure you put the BEGuid_x64.dll in the same folder as your extDB3.dll

config.cfg needs to be in the same folder as your arma3server_x64.exe

You can change the name of the config.cfg but you also need to update it inside fn_sendCommand.sqf
_password = trim (loadFile "config.cfg");

Make sure to add the class Management inside the TON_System

Also make sure to add this to your CfgRemoteExec.hpp
F(TON_fnc_managePlayer,SERVER)

Run the following to take actions on players:

[player, "kick", "Reason for kick"] remoteExecCall ["TON_fnc_managePlayer",RSERV];
[player, "ban", "3600", "Reason for ban"] remoteExecCall ["TON_fnc_managePlayer",RSERV];


Such As:

if (_detection) exitWith {
    [player,getPlayerUID player,format ["MenuBasedHack_%1",_targetName]] remoteExecCall ["SPY_fnc_cookieJar",RSERV];
    [player,format ["Menu Hack: %1",_targetName]] remoteExecCall ["SPY_fnc_notifyAdmins",RCLIENT];
    [player, "ban", "3600", "Menu Hack"] remoteExecCall ["TON_fnc_managePlayer",RSERV];// Lets Ban A Bitch
    sleep 0.5;
};