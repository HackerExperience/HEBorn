module Game.Meta.Update exposing (update)

import Utils.React as React exposing (React)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Meta.Config exposing (..)
import Game.Meta.Messages exposing (..)
import Game.Meta.Models exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        Tick time ->
            ( { model | lastTick = time }, React.none )
