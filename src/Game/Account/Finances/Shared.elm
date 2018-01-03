module Game.Account.Finances.Shared exposing (toMoney)


toMoney : Int -> String
toMoney value =
    let
        str =
            toString value

        ( dolars, cents ) =
            ( String.dropRight 2 str, String.right 2 str )

        formatedStr =
            if String.length dolars > 0 then
                dolars ++ "." ++ cents
            else
                "0." ++ cents
    in
        formatedStr
