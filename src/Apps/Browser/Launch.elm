module Apps.Browser.Launch exposing (..)

import Utils.React as React exposing (React)
import Game.Servers.Models as Servers
import Game.Meta.Types.Network as Network
import Game.Meta.Types.Apps.Desktop exposing (Reference, Requester)
import Apps.Browser.Config exposing (..)
import Apps.Browser.Models exposing (..)


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
        nid =
            config.activeServer
                |> Servers.getActiveNIP
                |> Network.getId

        model =
            initialModel config.reference

        requester =
            Requester config.reference model.lastTab

        react =
            React.msg <| config.onFetchUrl nid url requester

        model_ =
            model
                |> getNowTab
                |> gotoPage url (LoadingModel url)
                |> flip setNowTab model
    in
        ( model_, react )
