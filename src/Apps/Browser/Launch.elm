module Apps.Browser.Launch exposing (..)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Game.Data as Game
import Game.Models
import Game.Servers.Models as Servers
import Game.Meta.Types.Network as Network
import Apps.Reference exposing (..)
import Apps.Browser.Config exposing (..)
import Apps.Browser.Models exposing (..)
import Apps.Browser.Messages exposing (..)


type alias LaunchResponse =
    ( Model, Cmd Msg, Dispatch )


launch : Config msg -> Maybe Params -> Reference -> LaunchResponse
launch config maybeParams me =
    case maybeParams of
        Just (OpenAtUrl url) ->
            launchOpenAtUrl config url me

        Nothing ->
            Update.fromModel <| initialModel me


launchOpenAtUrl : Config msg -> URL -> Reference -> LaunchResponse
launchOpenAtUrl config url me =
    let
        nid =
            config.activeServer
                |> Servers.getActiveNIP
                |> Network.getId

        model =
            initialModel me

        reference =
            { sessionId = me.sessionId
            , windowId = me.windowId
            , context = me.context
            , tabId = model.lastTab
            }

        --dispatch =
        --    Dispatch.server cid <| Servers.FetchUrl url nid reference
        model_ =
            model
                |> getNowTab
                |> gotoPage url (LoadingModel url)
                |> flip setNowTab model
    in
        ( model_, Cmd.none, Dispatch.none )
