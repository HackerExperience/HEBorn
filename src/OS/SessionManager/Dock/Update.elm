module OS.SessionManager.Dock.Update exposing (update)

import Dict
import Utils.React as React exposing (React)
import Game.Servers.Models as Servers
import Core.Dispatch as Dispatch exposing (Dispatch)
import OS.SessionManager.Dock.Config exposing (..)
import OS.SessionManager.Dock.Messages exposing (..)
import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Helpers exposing (..)
import OS.SessionManager.Launch exposing (..)
import OS.SessionManager.WindowManager.Models as WM
import OS.SessionManager.Messages as SessionManager


type alias UpdateResponse msg =
    ( Model, React msg )



-- CONFREFACT: give Dock a real config and get rid of data


update :
    Config msg
    -> Msg
    -> Model
    -> UpdateResponse msg
update config msg ({ sessions } as model) =
    let
        id =
            config.sessionId
    in
        case msg of
            OpenApp app ->
                let
                    ip =
                        config.endpointCId

                    ( model_, react ) =
                        openApp config.wmConfig Nothing Nothing id ip app model
                in
                    ( model_, react )

            AppButton app ->
                let
                    ip =
                        config.endpointCId

                    ( model_, react ) =
                        openOrRestoreApp config.wmConfig Nothing Nothing id ip app model
                in
                    ( model_, react )

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
                            ( model_, React.none )

                    Nothing ->
                        ( model, React.none )



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
