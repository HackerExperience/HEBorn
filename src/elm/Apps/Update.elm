module Apps.Update exposing (..)

import Requests.Models exposing (Request(NewRequest), NewRequestData)
import Core.Messages exposing (CoreMsg(MsgApp))
import Core.Components exposing (Component(..))
import Core.Models exposing (CoreModel)
import Apps.Models exposing (AppModel)
import Apps.Messages exposing (AppMsg(..))
import Apps.Explorer.Messages
import Apps.Explorer.Update


delegateRequest : NewRequestData -> Component -> List CoreMsg
delegateRequest requestData component =
    [ MsgApp (Request (NewRequest requestData) component) ]


update : AppMsg -> AppModel -> CoreModel -> ( AppModel, Cmd AppMsg, List CoreMsg )
update msg model core =
    case msg of
        MsgExplorer (Apps.Explorer.Messages.Request (NewRequest requestData)) ->
            ( model, Cmd.none, delegateRequest requestData ComponentExplorer )

        MsgExplorer subMsg ->
            let
                ( explorer_, cmd, coreMsg ) =
                    Apps.Explorer.Update.update subMsg model.explorer core.game
            in
                ( { model | explorer = explorer_ }, Cmd.map MsgExplorer cmd, coreMsg )

        Event _ ->
            ( model, Cmd.none, [] )

        Request _ _ ->
            ( model, Cmd.none, [] )

        Response _ _ ->
            ( model, Cmd.none, [] )

        NoOp ->
            ( model, Cmd.none, [] )
