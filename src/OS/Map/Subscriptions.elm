module OS.Map.Subscriptions exposing (subscriptions)

import OS.Map.Config exposing (..)
import OS.Map.Messages exposing (..)
import OS.Map.Models exposing (..)


subscriptions : Config msg -> Model -> Sub msg
subscriptions config model =
    Sub.none
