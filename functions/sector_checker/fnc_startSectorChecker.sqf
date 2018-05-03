/**
* ATC_fnc_startSectorChecker
*
* @author ^eNable [enc0ded] <enc0ded.enable@gmail.com>
*		Edited by {BDR}*Armilio*© for ATC7
*		Edited by {BDR}*Armilio*© for ATC8
* @param string _this select 0 Marker name
* @public_variable ATC_PV_deffenders%marker text% Num of deffenders in area
* @public_variable ATC_PV_attackers%marker text% Num of attackers in area
* @return void
*/

private ["_arg_marker","_marker_info","_timeChanged","_timeKept","_paramDefenders","_paramAttckers","_currLevel","_prevLevel","_levelCondition","_unitsInSector","_VehInSector","_attakers","_defenders", "_SpecialForces"];

_arg_marker = _this select 0;

_marker_info = "_info_" + _arg_marker;

_timeChanged = time;
_timeKept = 0;

_paramDefenders = 0;
_paramAttckers = 0;

_currLevel = 0;
_prevLevel = 0;

_levelCondition = call {
    private "_str";

    _str = "";

    for "_i" from 0 to (count ATC_sectorDifficultyParams) - 1 do {
        private "_arr";
        _arr = ATC_sectorDifficultyParams select _i;
        if (_i == 0) then {
            _str = _str + format ["if (%1) then {_currLevel = %2;_paramDefenders = %3;_paramAttckers = %4};", _arr select 0, _arr select 1, _arr select 2, _arr select 3];
        } else {
            _str = format ["if (%1) then {_currLevel = %2;_paramDefenders = %3;_paramAttckers = %4} else {%5};", _arr select 0, _arr select 1, _arr select 2, _arr select 3, _str];
        };
    };

    _str
};

waitUntil {ATC_gameStarted};

while {!ATC_gameStoped} do {
    sleep ATC_sectorCheckerDelay;

    _timeKept = time - _timeChanged;

    call compile _levelCondition;

    _unitsInSector = [];
	_VehInSector = []; //array che serve per non contare più volte lo stesso veicolo, visto che lo script fa foreach units.

    {
            if (((getPosASL _x) inArea _arg_marker) && 
			{((getPos vehicle _x) select 2 < 3)&&((getPosASL vehicle _x) select 2 > 0.01)}) then {//{(getPosATL vehicle _x) select 2 < 1} per dire che deve essere a terra 
				if (vehicle _x != _x) then { //added by Armilio (veicoli contano per 1)
					_vehx = _VehInSector find (vehicle _x); 
					if (_vehx == -1) then {
						_unitsInSector pushBack (side _x);
						_VehInSector pushBack (vehicle _x);
					};
				}else { //if (vehicle _x == _x) then
					_isSF = _x getVariable ["isSF",false];
					
					if (!(_isSF)) then
					{
						_unitsInSector pushBack (side _x);
					};
				};	//added by Armilio (veicoli contano per 1)
			};
    } forEach allUnits;

    if (_currLevel != _prevLevel) then {
        [format ["Sector %1 is now level: %2", markerText _arg_marker, _currLevel], "ATC_fnc_sendHintMsg", nil, false] spawn BIS_fnc_MP;
        
        switch (markerColor _arg_marker) do {
            case ATC_sideMrkColorA: {
                [_marker_info, ATC_sideMrkColorA, [markerText _arg_marker, ATC_sideA, _currLevel, _paramDefenders, _paramAttckers]] call ATC_fnc_setInfoMarker;
            };
            case ATC_sideMrkColorB: {
                [_marker_info, ATC_sideMrkColorB, [markerText _arg_marker, ATC_sideB, _currLevel, _paramDefenders, _paramAttckers]] call ATC_fnc_setInfoMarker;
            };
        };

        _prevLevel = _currLevel;
    };

    _attakers = 0;
    _defenders = 0;

    switch (markerColor _arg_marker) do {
        case ATC_sideMrkColorA: {
            _attakers = {_x == ATC_sideB} count _unitsInSector;
            _defenders = {_x == ATC_sideA} count _unitsInSector;
            if (_attakers >= _paramAttckers) then {
				if (_defenders < _paramDefenders) then {
					[format ["Sector %1 has been taken by %2", markerText _arg_marker, ATC_sideNameB], "ATC_fnc_sendHintMsg", nil, false] spawn BIS_fnc_MP;
					_arg_marker setMarkerColor ATC_sideMrkColorB;

					[_marker_info, ATC_sideMrkColorB, [markerText _arg_marker, ATC_sideNameB, _currLevel, _paramDefenders, _paramAttckers]] call ATC_fnc_setInfoMarker;
					_timeChanged = time;

					call ATC_fnc_changeAreaSide;
				};           
			};
         };
        case ATC_sideMrkColorB: {
            _attakers = {_x == ATC_sideA} count _unitsInSector;
            _defenders = {_x == ATC_sideB} count _unitsInSector;
            if (_attakers >= _paramAttckers) then {
			if (_defenders < _paramDefenders) then {
					[format ["Sector %1 has been taken by %2", markerText _arg_marker, ATC_sideNameA], "ATC_fnc_sendHintMsg", nil, false] spawn BIS_fnc_MP;
					_arg_marker setMarkerColor ATC_sideMrkColorA;

					[_marker_info, ATC_sideMrkColorA, [markerText _arg_marker, ATC_sideNameA, _currLevel, _paramDefenders, _paramAttckers]] call ATC_fnc_setInfoMarker;
					_timeChanged = time;
                
					call ATC_fnc_changeAreaSide;
				};
			};
        };
      };
     };
