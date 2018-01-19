module Game.Meta.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Meta.Config exposing (..)
import Game.Meta.Messages exposing (..)
import Game.Meta.Models exposing (..)


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        Tick time ->
            let
                model_ =
                    { model | lastTick = time }
            in
                ( model_, Cmd.none, Dispatch.none )
