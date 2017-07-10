module Game.Servers.Tunnels.Update exposing (update)

import Game.Models as Game
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Servers.Tunnels.Messages exposing (..)
import Game.Servers.Tunnels.Models exposing (..)


update : Game.Model -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update game msg model =
    ( model, Cmd.none, Dispatch.none )
