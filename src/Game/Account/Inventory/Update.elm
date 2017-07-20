module Game.Account.Inventory.Update exposing (update)

import Core.Dispatch as Dispatch
import Game.Models as Game
import Game.Account.Inventory.Messages exposing (..)
import Game.Account.Inventory.Models exposing (..)


update : Game.Model -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update game msg model =
    ( model, Cmd.none, Dispatch.none )
