module Apps.Browser.Launch exposing (..)

import Utils.React as React exposing (React)
import Game.Servers.Models as Servers
import Game.Servers.Requests.Browse as BrowseRequest exposing (browseRequest)
import Game.Meta.Types.Network as Network
import Game.Meta.Types.Apps.Desktop exposing (Reference, Requester)
import Apps.Browser.Config exposing (..)
import Apps.Browser.Models exposing (..)
import Apps.Browser.Messages exposing (..)


type alias LaunchResponse msg =
    ( Model, React msg )


launch : Config msg -> Maybe Params -> LaunchResponse msg
launch config maybeParams =
    case maybeParams of
        Just (OpenAtUrl url) ->
            launchOpenAtUrl config url

        Nothing ->
            ( initialModel config.reference, React.none )


launchOpenAtUrl : Config msg -> URL -> LaunchResponse msg
launchOpenAtUrl config url =
    let
        ( cid, server ) =
            config.activeServer

        networkId =
            server
                |> Servers.getActiveNIP
                |> Network.getId

        model =
            initialModel config.reference

        model_ =
            model
                |> getNowTab
                |> gotoPage url (LoadingModel url)
                |> flip setNowTab model

        react =
            config
                |> browseRequest url networkId cid
                |> Cmd.map
                    (HandleBrowse
                        >> SomeTabMsg model_.lastTab
                        >> config.toMsg
                    )
                |> React.cmd
    in
        ( model_, react )
