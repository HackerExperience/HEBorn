module Game.Account.Bounces.Update exposing (update)

import Game.Account.Bounces.Config exposing (..)
import Game.Account.Bounces.Messages exposing (..)
import Game.Account.Bounces.Models exposing (..)


type alias UpdateResponse msg =
    ( Model, Cmd msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    ( model, Cmd.none )
