module Game.Account.Bounces.Update exposing (update)

import Utils.React as React exposing (React)
import Game.Account.Bounces.Config exposing (..)
import Game.Account.Bounces.Messages exposing (..)
import Game.Account.Bounces.Models exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    ( model, React.none )
