lock throttle to 1.

wait 5.
stage.

when ship:partstagged("engine.booster")[0]:thrust = 0 then {
    stage.
}

when ship:verticalspeed <= 0 then {
    stage.
}

until false {
    wait 0.01.
}