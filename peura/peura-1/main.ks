lock throttle to 1.

wait 5.
stage.

when ship:partstagged("engine.booster")[0]:thrust <= ship:partstagged("engine.main")[0]:thrust then {
    stage.
}

when ship:verticalspeed <= 0 then {
    stage.
}

until false {
    wait 0.01.
}