module UI.ToString exposing (..)


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


secondsToTimeNotation : Int -> String
secondsToTimeNotation count =
    if (count > 3600) then
        let
            h =
                (toString (count // 3600))

            l =
                (count % 3600)

            m =
                (toString (l // 60))

            s =
                (toString (l % 60))
        in
            h ++ "h" ++ m ++ "m" ++ s ++ "s"
    else if (count > 60) then
        let
            m =
                (toString (count // 60))

            s =
                (toString (count % 60))
        in
            m ++ "m" ++ s ++ "s"
    else
        (toString count) ++ "s"
