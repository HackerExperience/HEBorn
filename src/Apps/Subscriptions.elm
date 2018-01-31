module Apps.Subscriptions exposing (subscriptions)

import Apps.Config exposing (..)
import Apps.Models exposing (..)
import Apps.Messages exposing (..)
import Apps.TaskManager.Subscriptions as TaskManager
import Apps.LocationPicker.Subscriptions as LocationPicker


subscriptions : Config msg -> AppModel -> Sub msg
subscriptions config model =
    case model of
        TaskManagerModel model ->
            TaskManager.subscriptions (taskManConfig config) model

        LocationPickerModel model ->
            LocationPicker.subscriptions (locationPickerConfig config) model
                |> Sub.map (LocationPickerMsg >> config.toMsg)

        _ ->
            Sub.none
