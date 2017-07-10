module Game.Account.Bounces.Update exposing (update)

import Game.Models as Game
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Account.Bounces.Messages exposing (..)
import Game.Account.Bounces.Models exposing (..)


update : Game.Model -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update game msg model =
    ( model, Cmd.none, Dispatch.none )
