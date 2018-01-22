module Events.Shared exposing (..)

import Json.Decode exposing (Value)


type alias Router a =
    String -> Value -> Result String a


type alias Handler a b =
    (a -> b) -> Value -> Result String b
