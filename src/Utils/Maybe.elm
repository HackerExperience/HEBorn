module Utils.Maybe exposing (..)


uncurry : Maybe a -> Maybe b -> Maybe ( a, b )
uncurry ma mb =
    case ( ma, mb ) of
        ( Just a, Just b ) ->
            Just ( a, b )

        _ ->
            Nothing


isJust : Maybe a -> Bool
isJust m =
    case m of
        Nothing ->
            False

        Just _ ->
            True


isNothing : Maybe a -> Bool
isNothing m =
    case m of
        Nothing ->
            True

        Just _ ->
            False
