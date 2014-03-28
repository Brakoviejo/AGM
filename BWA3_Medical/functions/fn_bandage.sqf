/*
 * Author: KoffeinFlummi
 *
 * Bandage the given unit.
 * 
 * Argument:
 * 0: Unit to be bandaged (Object)
 * 1: HitPoint to be healed (String; Example: "HitLeftShoulder")
 * 
 * Return value:
 * none
 */

#define BANDAGETIMEMEDIC 4
#define BANDAGETIMENONMEDIC 8
#define BANDAGEHEAL 0.8

#define LEGDAMAGETHRESHOLD1 1
#define LEGDAMAGETHRESHOLD2 2
#define ARMDAMAGETHRESHOLD 2

player removeItem "BWA3_Bandage";

_this spawn {
  _unit = _this select 0;
  _selection = _this select 1;

  // determine if unit is medic
  _healtime = 0;
  if ([player] call BWA3_Medical_fnc_isMedic) then {
    _healtime = BANDAGETIMEMEDIC;
  } else {
    _healtime = BANDAGETIMENONMEDIC;
  };

  // animation
  player playMoveNow "AinvPknlMstpSnonWnonDnon_medic1";

  // countdown
  _i = _healtime;
  while {_i > 0} do {
    hintSilent format ["Bandaging %1:\n%2", _selection, _i];
    _i = _i - 1;
    sleep 1;
  };
  hintSilent format ["Bandaging %1:\nDone", _selection];
  sleep 1;
  hintSilent "";

  // is unit still in range?
  if (player distance _unit > 4 or vehicle player != player or damage player >= 1) exitWith {};

  // change damage of body part
  _damage = ((_unit getHitPointDamage _selection) - BANDAGEHEAL) max 0;
  _unit setHitPointDamage [_selection, _damage];

  // check if legs are healed
  _legdamage = (_unit getHitPointDamage "HitLeftUpLeg") + (_unit getHitPointDamage "HitLeftLeg") + (_unit getHitPointDamage "HitLeftFoot") + (_unit getHitPointDamage "HitRightUpLeg") + (_unit getHitPointDamage "HitRightLeg") + (_unit getHitPointDamage "HitRightFoot");
  if (_legdamage < LEGDAMAGETHRESHOLD1) then {
    _unit setHitPointDamage ["HitLegs", 0];
  };

  // remove extremely small wounds
  _fullyHealed = true;
  {
    if (_unit getHitPointDamage _x > 0.01) exitWith {_fullyHealed = false;};
  } forEach ["HitHead","HitBody","HitLeftShoulder","HitLeftArm","HitLeftForeArm","HitRightShoulder","HitRightArm","HitRightForeArm","HitLeftUpLeg","HitLeftLeg","HitLeftFoot","HitRightUpLeg","HitRightLeg","HitRightFoot"];
  if (_fullyHealed) then {
    _unit setDamage 0;
  };
};