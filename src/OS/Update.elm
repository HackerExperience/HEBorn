module OS.Update exposing (update)

import Core.Models exposing (CoreModel)
import Core.Messages exposing (CoreMsg)
import OS.Messages exposing (OSMsg(..))
import OS.Models exposing (Model)
import OS.WindowManager.Update
import OS.Dock.Update
import OS.Context.Messages as MsgContext
import OS.Context.Update
import OS.Context.Actions exposing (actionHandler)


update : OSMsg -> Model -> CoreModel -> ( Model, Cmd OSMsg, List CoreMsg )
update msg model core =
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

        ContextMsg (MsgContext.MenuClick action) ->
            actionHandler action model core.game

        ContextMsg subMsg ->
            let
                ( context_, cmd, coreMsg ) =
                    OS.Context.Update.update subMsg model.context core.game

                cmd_ =
                    Cmd.map ContextMsg cmd
            in
                ( { model | context = context_ }, cmd_, coreMsg )

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
