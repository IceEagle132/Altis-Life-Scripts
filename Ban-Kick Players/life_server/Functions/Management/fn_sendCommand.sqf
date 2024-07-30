/*
    File: fn_sendCommand.sqf
    Description: Sends a server command with a password.
*/

private["_command", "_password", "_return"];  // Declare private variables
_command = _this;  // Assign the input parameter (the command) to _command

// Load the password from an external configuration file
_password = trim (loadFile "config.cfg");

// Check if the password is empty (should be handled by configuration management)
if (_password isEqualTo "") then {
    throw "Server command password is not set in the configuration file!";
};

// Execute the server command with the password and store the result in _return
try {
    _return = _password serverCommand _command;
} catch {
    _return = "Error executing server command";
};

// Return the result
_return;