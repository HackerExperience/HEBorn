module Apps.Update exposing (..)

import Requests.Models exposing (Request(NewRequest), NewRequestData)
import Core.Messages exposing (CoreMsg(MsgApp))
import Core.Components exposing (Component(..))
import Core.Models exposing (CoreModel)
import Apps.Models exposing (AppModel)
import Apps.Messages exposing (AppMsg(..))
import Apps.Explorer.Update
import Apps.Explorer.Messages
import Apps.LogViewer.Update
import Apps.LogViewer.Messages
import Apps.Browser.Update
import Apps.Browser.Messages


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

        MsgLogViewer (Apps.LogViewer.Messages.Request (NewRequest requestData)) ->
            ( model, Cmd.none, delegateRequest requestData ComponentLogViewer )

        MsgLogViewer subMsg ->
            let
                ( logViewer_, cmd, coreMsg ) =
                    Apps.LogViewer.Update.update subMsg model.logViewer core.game
            in
                ( { model | logViewer = logViewer_ }, Cmd.map MsgLogViewer cmd, coreMsg )

        MsgBrowser subMsg ->
            let
                ( browser_, cmd, coreMsg ) =
                    Apps.Browser.Update.update subMsg model.browser core.game
            in
                ( { model | browser = browser_ }, Cmd.map MsgBrowser cmd, coreMsg )

        Event _ ->
            ( model, Cmd.none, [] )

        Request _ _ ->
            ( model, Cmd.none, [] )

        Response _ _ ->
            ( model, Cmd.none, [] )

        NoOp ->
            ( model, Cmd.none, [] )


delegateRequest : NewRequestData -> Component -> List CoreMsg
delegateRequest requestData component =
    [ MsgApp (Request (NewRequest requestData) component) ]
