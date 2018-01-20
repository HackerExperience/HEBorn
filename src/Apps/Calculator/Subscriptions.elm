module Apps.Calculator.Subscriptions exposing (..)

import Apps.Calculator.Config exposing (..)
import Apps.Calculator.Models exposing (Model)
import Apps.Calculator.Messages exposing (Msg(..))


subscriptions : Config msg -> Model -> Sub Msg
subscriptions config model =
    Sub.none
