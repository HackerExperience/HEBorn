module Utils.Maybe exposing (..)


uncurry : Maybe a -> Maybe b -> Maybe ( a, b )
uncurry ma mb =
    case ( ma, mb ) of
        ( Just a, Just b ) ->
            Just ( a, b )

        _ ->
            Nothing
