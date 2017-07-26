module OS.SessionManager.Dock.Update exposing (update)

import Dict
import Game.Data as Game
import Game.Servers.Models as Servers
import Core.Dispatch as Dispatch exposing (Dispatch)
import OS.SessionManager.Dock.Messages exposing (..)
import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Helpers exposing (..)
import OS.SessionManager.WindowManager.Models as WM
import OS.SessionManager.Messages as SessionManager


update :
    Game.Data
    -> Msg
    -> Model
    -> ( Model, Cmd SessionManager.Msg, Dispatch )
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

                    ( model_, cmd, dispatch ) =
                        openApp data id ip app model
                in
                    ( model_, cmd, dispatch )

            AppButton app ->
                let
                    ip =
                        data
                            |> Game.getServer
                            |> Servers.getEndpoint

                    ( model_, cmd, dispatch ) =
                        openOrRestoreApp data id ip app model
                in
                    ( model_, cmd, dispatch )

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
