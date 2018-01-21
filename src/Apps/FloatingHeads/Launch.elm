module Apps.FloatingHeads.Launch exposing (..)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Game.Data as Game
import Game.Servers.Models as Servers
import Game.Meta.Types.Network as Network
import Apps.Reference exposing (..)
import Apps.FloatingHeads.Config exposing (..)
import Apps.FloatingHeads.Models exposing (..)
import Apps.FloatingHeads.Messages exposing (..)


type alias LaunchResponse =
    ( Model, Cmd Msg, Dispatch )


launch : Config msg -> Maybe Params -> Reference -> LaunchResponse
launch config maybeParams me =
    case maybeParams of
        Just (OpenAtContact contact) ->
            launchOpenAtContact config contact me

        Nothing ->
            Update.fromModel <| initialModel Nothing me


launchOpenAtContact : Config msg -> String -> Reference -> LaunchResponse
launchOpenAtContact config contact me =
    let
        model =
            initialModel (Just contact) me
    in
        ( model, Cmd.none, Dispatch.none )
