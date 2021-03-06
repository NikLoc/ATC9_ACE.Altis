if (isServer) then {
	_arg_pos = _this select 0;

	_radioTowerName = switch (_this select 1) do {
		case "mrk_buildZoneRadioTowerA": {"ATC_radioTowerA"};
		case "mrk_buildZoneRadioTowerB": {"ATC_radioTowerB"};
	};
	_mrk_rTower = createMarker ["mrk_" + _radioTowerName, _arg_pos];
    _mrk_rTower setMarkerShape "ICON";
    _mrk_rTower setMarkerType "loc_Transmitter";
    _mrk_rTower setMarkerText "Radio tower"; 
	_mrk_rTower setMarkerAlpha 0;

    call compile format [
		"%1 = 'Land_Communication_F' createVehicle %2;%1 setPos %2;%1 setVectorUp [0,0,1];publicVariable '%1'",
		_radioTowerName,
		_arg_pos
	];
	
	//Added By Armilio for ATC8
	_rtn = _radioTowerName;
	_Radiotwobj= call compile _rtn;
	_Radiotwobj addEventHandler ["HandleDamage",
	{
		private _unit = _this select 0; 
		private _hitSelection = _this select 1; 
		_damage = 0;
		if((_this select 4)=="SatchelCharge_Remote_Ammo" || (_this select 4)=="DemoCharge_Remote_Ammo") then { 
			_unit gethit _hitSelection 
		} else {  
			_damage
		};
	}];
	if (_radioTowerName == "ATC_radioTowerA") then {
		TowerBplaced= true;
		publicVariable "TowerBplaced";
		TowerKilledB = false;
		publicVariable "TowerKilledB";
		_Radiotwobj addMPEventHandler ["MPKilled",{TowerKilledB = true; publicVariable "TowerKilledB"}];
	};
	if (_radioTowerName == "ATC_radioTowerB") then {
		TowerRplaced= true;
		publicVariable "TowerRplaced";
		TowerKilledR = false;
		publicVariable "TowerKilledR";
		_Radiotwobj addMPEventHandler ["MPKilled",{TowerKilledR = true; publicVariable "TowerKilledR"}];
	};	
};
