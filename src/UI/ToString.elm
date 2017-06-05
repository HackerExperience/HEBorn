module UI.ToString exposing (..)

import Time exposing (Time, inHours, inMinutes, inSeconds)


bytesToString : Float -> String
bytesToString value =
    (floatToPrefixedValues value) ++ "B"


bibytesToString : Float -> String
bibytesToString value =
    (floatToPrefixedValues value) ++ "iB"


bitsPerSecondToString : Float -> String
bitsPerSecondToString value =
    (floatToPrefixedValues value) ++ "bps"


frequencyToString : Float -> String
frequencyToString value =
    (floatToPrefixedValues value) ++ "Hz"


floatToPrefixedValues : Float -> String
floatToPrefixedValues x =
    -- TODO: Move this function to a better place
    -- TODO: Use "round 2" from elm-round
    if (x > (10 ^ 9)) then
        toString (x / (10 ^ 9)) ++ " G"
    else if (x > (10 ^ 6)) then
        toString (x / (10 ^ 6)) ++ " M"
    else if (x > (10 ^ 3)) then
        toString (x / (10 ^ 3)) ++ " K"
    else
        toString (x) ++ " "


pointToSvgAttr : ( Float, Float ) -> String
pointToSvgAttr ( x, y ) =
    (toString x) ++ "," ++ (toString y)


secondsToTimeNotation : Time -> String
secondsToTimeNotation timeLeft =
    let
        totalHours =
            floor (inHours timeLeft)

        days =
            totalHours // 24

        hours =
            totalHours % 24

        minutes =
            (floor (inMinutes timeLeft)) % 60

        seconds =
            (floor (inSeconds timeLeft)) % 60

        showFun ( value, posfix ) accum =
            if (String.isEmpty accum) && (value <= 0) then
                accum
            else
                (accum ++ " " ++ (toString value) ++ posfix)

        show =
            List.foldl
                showFun
                ""
                [ ( days, "d" )
                , ( hours, "h" )
                , ( minutes, "m" )
                , ( seconds, "s" )
                ]
    in
        show
