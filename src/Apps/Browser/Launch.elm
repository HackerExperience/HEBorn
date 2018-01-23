module Apps.Browser.Launch exposing (..)

import Utils.React as React exposing (React)
import Game.Models
import Game.Servers.Models as Servers
import Game.Meta.Types.Network as Network
import Game.Storyline.Emails.Contents as Emails
import Apps.Reference exposing (..)
import Apps.Browser.Config exposing (..)
import Apps.Browser.Models exposing (..)
import Apps.Browser.Messages exposing (..)


type alias LaunchResponse msg =
    ( Model, React msg )


launch : Config msg -> Maybe Params -> Reference -> LaunchResponse msg
launch config maybeParams me =
    case maybeParams of
        Just (OpenAtUrl url) ->
            launchOpenAtUrl config url me

        Nothing ->
            ( initialModel me, React.none )


launchOpenAtUrl : Config msg -> URL -> Reference -> LaunchResponse msg
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

        react =
            React.msg <| config.onFetchUrl url nid reference

        model_ =
            model
                |> getNowTab
                |> gotoPage url (LoadingModel url)
                |> flip setNowTab model
    in
        ( model_, react )
