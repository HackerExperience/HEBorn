module Apps.TaskManager.Subscriptions exposing (..)

import Time exposing (Time, second)
import Apps.TaskManager.Config exposing (Config)
import Apps.TaskManager.Models exposing (Model)
import Apps.TaskManager.Messages exposing (Msg(..))


subscriptions : Config msg -> Model -> Sub msg
subscriptions config _ =
    Time.every second (Tick >> config.toMsg)
