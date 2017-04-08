module OS.Update exposing (update)


import Update.Extra as Update

import OS.Messages exposing (OSMsg(..))
import OS.Models exposing (Model)
import Game.Messages exposing (GameMsg)

import OS.WindowManager.Update
import OS.Dock.Update


update : OSMsg -> Model -> (Model, Cmd OSMsg)
update msg model =
    case msg of

        MsgWM subMsg ->
            let
                (wm_, cmd, gameMsg, osMsg) =
                    OS.WindowManager.Update.update subMsg model.wm
            in
                ({model | wm = wm_}, cmd)
                    |> Update.andThen update (getOSMsg osMsg)

        MsgDock subMsg ->
            let
                (dock_, cmd, gameMsg, osMsg) =
                    OS.Dock.Update.update subMsg model.dock
            in
                ({model | dock = dock_}, cmd)
                    |> Update.andThen update (getOSMsg osMsg)

        Event _ ->
            (model, Cmd.none)

        Request _ ->
            (model, Cmd.none)

        Response _ _ ->
            (model, Cmd.none)

        NoOp ->
            (model, Cmd.none)


getOSMsg : List OSMsg -> OSMsg
getOSMsg msg =
    case msg of
        [] ->
            NoOp
        m :: _ ->
            m
