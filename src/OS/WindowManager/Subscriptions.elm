module OS.WindowManager.Subscriptions exposing (subscriptions)

import Dict exposing (Dict)
import Draggable
import Window
import Utils.Maybe as Maybe
import Apps.LocationPicker.Subscriptions as LocationPicker
import Apps.TaskManager.Subscriptions as TaskManager
import Game.Meta.Types.Context exposing (Context(..))
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
            , Window.resizes (SetAppSize >> config.toMsg)
            ]


subsApp : Config msg -> Model -> AppId -> App -> Maybe (Sub msg)
subsApp config model appId app =
    let
        cid =
            getAppCId app

        activeServer =
            config
                |> serversFromConfig
                |> Servers.get cid
                |> Maybe.map ((,) cid)

        activeGateway =
            case getAppContext app of
                Gateway ->
                    activeServer

                Endpoint ->
                    model
                        |> getWindowOfApp appId
                        |> Maybe.andThen (flip getWindow model)
                        |> Maybe.andThen (getEndpointOfWindow config model)
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
subsAppDelegate config activeServer activeGateway appId app =
    case getModel app of
        LocationPickerModel appModel ->
            appModel
                |> LocationPicker.subscriptions
                    (locationPickerConfig appId config)
                |> Just

        TaskManagerModel appModel ->
            appModel
                |> TaskManager.subscriptions
                    (taskManagerConfig appId activeServer config)
                |> Just

        _ ->
            Nothing
