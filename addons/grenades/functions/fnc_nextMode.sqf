/*
 * Author: commy2
 *
 * Select the next throwing mode and display message.
 * 
 * Argument:
 * Nothing
 * 
 * Return value:
 * Nothing
 */

#include "script_component.hpp"
 
private ["_mode", "_hint"];

if (!([ACE_player] call EFUNC(common,canUseWeapon))) exitWith {false};

_mode = missionNamespace getVariable [QGVAR(currentThrowMode), 0];

if (_mode == 4) then {
  _mode = 0;
} else {
  _mode = _mode + 1;
};

// ROLL GRENADE DOESN'T WORK RIGHT NOW
if (_mode == 3) then {
  _mode = 4;
};

_hint = [
  localize "STR_ACE_Grenades_NormalThrow",
  localize "STR_ACE_Grenades_HighThrow",
  localize "STR_ACE_Grenades_PreciseThrow",
  localize "STR_ACE_Grenades_RollGrenade",
  localize "STR_ACE_Grenades_DropGrenade"
] select _mode;

[_hint] call EFUNC(common,displayTextStructured);

GVAR(currentThrowMode) = _mode;

true
