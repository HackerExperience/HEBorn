module OS.WindowManager.Subscriptions exposing (subscriptions)

import Dict exposing (Dict)
import Draggable
import Utils.Maybe as Maybe
import Apps.LocationPicker.Subscriptions as LocationPicker
import Apps.TaskManager.Subscriptions as TaskManager
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Shared as Servers exposing (CId(..))
import OS.WindowManager.Config exposing (..)
import OS.WindowManager.Helpers exposing (..)
import OS.WindowManager.Messages exposing (..)
import OS.WindowManager.Models exposing (..)
import OS.WindowManager.Shared exposing (..)


subscriptions : Config msg -> Model -> Sub msg
subscriptions config model =
    let
        apps =
            model.apps
                |> Dict.toList
                |> List.filterMap (uncurry <| subsApp config model)
                |> Sub.batch
    in
        Sub.batch
            [ apps
            , Draggable.subscriptions (DragMsg >> config.toMsg) model.drag
            ]


subsApp : Config msg -> Model -> AppId -> App -> Maybe (Sub msg)
subsApp config model appId app =
    let
        activeGateway =
            model
                |> getWindow (getWindowId app)
                |> Maybe.andThen (getWindowGateway config model)

        activeServer =
            getAppActiveServer config app
    in
        case Maybe.uncurry activeServer activeGateway of
            Just ( active, gateway ) ->
                subsAppDelegate config active gateway appId app

            Nothing ->
                -- this shouldn't happen really
                Nothing


subsAppDelegate :
    Config msg
    -> ( CId, Server )
    -> ( CId, Server )
    -> AppId
    -> App
    -> Maybe (Sub msg)
subsAppDelegate config ( cid, server ) ( gCid, gServer ) appId app =
    case getModel app of
        LocationPickerModel appModel ->
            appModel
                |> LocationPicker.subscriptions
                    (locationPickerConfig appId config)
                |> Just

        TaskManagerModel appModel ->
            appModel
                |> TaskManager.subscriptions
                    (taskManagerConfig appId cid server config)
                |> Just

        _ ->
            Nothing
