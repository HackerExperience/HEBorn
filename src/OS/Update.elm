module OS.Update exposing (update)

import Core.Messages exposing (CoreMsg)
import OS.Messages exposing (OSMsg(..))
import OS.Models exposing (Model)
import OS.WindowManager.Update
import OS.Dock.Update


update : OSMsg -> Model -> ( Model, Cmd OSMsg, List CoreMsg )
update msg model =
    case msg of
        MsgWM subMsg ->
            let
                ( wm_, cmd, coreMsg ) =
                    OS.WindowManager.Update.update subMsg model.wm
            in
                ( { model | wm = wm_ }, cmd, coreMsg )

        MsgDock subMsg ->
            let
                ( dock_, cmd, coreMsg ) =
                    OS.Dock.Update.update subMsg model.dock
            in
                ( { model | dock = dock_ }, cmd, coreMsg )

        Event _ ->
            ( model, Cmd.none, [] )

        Request _ ->
            ( model, Cmd.none, [] )

        Response _ _ ->
            ( model, Cmd.none, [] )

        NoOp ->
            ( model, Cmd.none, [] )


getOSMsg : List OSMsg -> OSMsg
getOSMsg msg =
    case msg of
        [] ->
            NoOp

        m :: _ ->
            m
