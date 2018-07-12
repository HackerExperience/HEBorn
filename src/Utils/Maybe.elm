module Utils.Maybe exposing (..)

import Utils.React as React exposing (React)


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


react : (a -> React b) -> Maybe a -> c -> ( c, React b )
react r m i =
    case m of
        Nothing ->
            React.update i

        Just j ->
            ( i, r j )


react2 : (a -> c -> React b) -> Maybe a -> Maybe c -> d -> ( d, React b )
react2 r m1 m2 i =
    case uncurry m1 m2 of
        Just ( a, b ) ->
            ( i, r a b )

        Nothing ->
            React.update i
