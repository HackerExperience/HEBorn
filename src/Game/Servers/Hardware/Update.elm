module Game.Servers.Hardware.Update exposing (update)

import Core.Dispatch as Dispatch
import Game.Models as Game
import Game.Servers.Hardware.Messages exposing (..)
import Game.Servers.Hardware.Models exposing (..)


update : Game.Model -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update game msg model =
    ( model, Cmd.none, Dispatch.none )
