module OS.SessionManager.Dock.Update exposing (update)

import Dict
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Game.Servers.Models as Servers
import Apps.Messages as Apps
import OS.SessionManager.Dock.Messages exposing (..)
import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Helpers exposing (..)
import OS.SessionManager.WindowManager.Models as WM


update :
    Game.Data
    -> Msg
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
update data msg ({ sessions } as model) =
    let
        id =
            toSessionID data
    in
        case msg of
            OpenApp app ->
                let
                    ip =
                        data
                            |> Game.getServer
                            |> Servers.getEndpoint

                    ( model_, wId ) =
                        openApp id ip app model

                    loadedDispatch =
                        case wId of
                            Just wId ->
                                Dispatch.window wId <| Apps.Loaded wId

                            Nothing ->
                                Dispatch.none
                in
                    ( model_, Cmd.none, loadedDispatch )

            AppButton app ->
                let
                    ip =
                        data
                            |> Game.getServer
                            |> Servers.getEndpoint

                    ( model_, wId ) =
                        openOrRestoreApp id ip app model

                    loadedDispatch =
                        case wId of
                            Just wId ->
                                Dispatch.window wId <| Apps.Loaded wId

                            Nothing ->
                                Dispatch.none
                in
                    ( model_, Cmd.none, loadedDispatch )

            _ ->
                case Dict.get id sessions of
                    Just wm ->
                        let
                            sessions_ =
                                Dict.insert
                                    id
                                    (wmUpdate msg wm)
                                    sessions

                            model_ =
                                { model | sessions = sessions_ }
                        in
                            ( model_, Cmd.none, Dispatch.none )

                    Nothing ->
                        ( model, Cmd.none, Dispatch.none )



-- internals


wmUpdate : Msg -> WM.Model -> WM.Model
wmUpdate msg wm =
    case msg of
        CloseApps app ->
            WM.removeAll app wm

        MinimizeApps app ->
            WM.minimizeAll app wm

        CloseWindow id ->
            WM.remove id wm

        RestoreWindow id ->
            WM.restore id wm

        MinimizeWindow id ->
            WM.minimize id wm

        FocusWindow id ->
            WM.focus id wm

        _ ->
            wm
