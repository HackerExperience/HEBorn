module Game.Web.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Events.Events as Events
import Utils.Update as Update
import Game.Models as Game
import Game.Web.Messages exposing (..)
import Game.Web.Types exposing (..)
import Game.Web.DNS as DNS
import Game.Web.Requests exposing (..)
import Game.Web.Requests.DNS as DNS
import Apps.Browser.Messages as Browser


type alias UpdateResponse =
    ( Cmd Msg, Dispatch )


update : Game.Model -> Msg -> UpdateResponse
update game msg =
    case msg of
        Request data ->
            onRequest game (receive data)

        FetchUrl serverId url nid requester ->
            ( DNS.request serverId url nid requester game, Dispatch.none )



-- internals


onRequest : Game.Model -> Maybe Response -> UpdateResponse
onRequest game response =
    case response of
        Just response ->
            updateRequest game response

        Nothing ->
            ( Cmd.none, Dispatch.none )


updateRequest : Game.Model -> Response -> UpdateResponse
updateRequest game response =
    case response of
        DNS requester response ->
            onDNS game requester response


onDNS : Game.Model -> DNS.Requester -> DNS.Response -> UpdateResponse
onDNS game { sessionId, windowId, context, tabId } response =
    let
        dispatch =
            Browser.Fetched response
                |> Browser.SomeTabMsg tabId
                |> Dispatch.browser ( sessionId, windowId ) context
    in
        ( Cmd.none, dispatch )
