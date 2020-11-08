#include "script_component.hpp"
/*
 * Author: Glowbal
 * Load object into vehicle.
 * Objects loaded via classname remain virtual until unloaded.
 *
 * Arguments:
 * 0: Item <OBJECT or STRING>
 * 1: Vehicle <OBJECT>
 * 2: Ignore interaction distance and stability checks <BOOL>
 *
 * Return Value:
 * Object loaded <BOOL>
 *
 * Example:
 * [object, vehicle] call ace_cargo_fnc_loadItem
 *
 * Public: Yes
 */

params [["_item","",[objNull,""]], ["_vehicle",objNull,[objNull]], ["_ignoreInteraction", false]];
TRACE_2("params",_item,_vehicle);

if !([_item, _vehicle, _ignoreInteraction] call FUNC(canLoadItemIn)) exitWith {TRACE_2("cannot load",_item,_vehicle); false};

private _loaded = _vehicle getVariable [QGVAR(loaded), []];
_loaded pushBack _item;
_vehicle setVariable [QGVAR(loaded), _loaded, true];

TRACE_1("added to loaded array",_loaded);

private _space = [_vehicle] call FUNC(getCargoSpaceLeft);
private _itemSize = [_item] call FUNC(getSizeItem);
_vehicle setVariable [QGVAR(space), _space - _itemSize, true];

if (_item isEqualType objNull) then {
    detach _item;
    if !(_vehicle setVehicleCargo _item) then {
        private _itemsCargo = _loaded arrayIntersect getVehicleCargo _vehicle;
        private _cargoNet = createVehicle [GVAR(cargoNetType), [0, 0, 0], [], 0, "CAN_COLLIDE"];
        if ([_vehicle, _cargoNet, _itemsCargo] call FUNC(canItemCargo)) then {
            while {!(_vehicle setVehicleCargo _cargoNet)} do { // Move ViV cargo to ACE Cargo
                if (_itemsCargo isEqualTo []) exitWith {deleteVehicle _cargoNet; /*Should not happen*/};
                private _itemViV = _itemsCargo deleteAt 0;

                if !(objNull setVehicleCargo _itemViV) exitWith {deleteVehicle _cargoNet;};

                _itemViV setVariable [QGVAR(cargoNet), _cargoNet, true];
                _itemViV attachTo [_vehicle, [0,0,-100]];
                [QEGVAR(common,hideObjectGlobal), [_itemViV, true]] call CBA_fnc_serverEvent;

                // Some objects below water will take damage over time and eventualy become "water logged" and unfixable (because of negative z attach)
                [_itemViV, "blockDamage", "ACE_cargo", true] call EFUNC(common,statusEffect_set);
            };
        } else {
            deleteVehicle _cargoNet;
        };
        if !(isNull _cargoNet) then {
            _cargoNet setVariable [QGVAR(isCargoNet), true, true];
            _item setVariable [QGVAR(cargoNet), _cargoNet, true];
        };

        _item attachTo [_vehicle, [0,0,-100]];
        [QEGVAR(common,hideObjectGlobal), [_item, true]] call CBA_fnc_serverEvent;

        // Some objects below water will take damage over time and eventualy become "water logged" and unfixable (because of negative z attach)
        [_item, "blockDamage", "ACE_cargo", true] call EFUNC(common,statusEffect_set);
    };
};

true
