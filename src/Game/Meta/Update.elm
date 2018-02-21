module Game.Meta.Update exposing (update)

import Utils.React as React exposing (React)
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

        Focused what ->
            onFocused what model


onFocused : Maybe ( String, String ) -> Model -> UpdateResponse msg
onFocused what model =
    let
        focus_ =
            case Maybe.map Tuple.second what of
                Just "INPUT" ->
                    InsertMode

                Just "TEXTAREA" ->
                    InsertMode

                _ ->
                    NormalMode

        model_ =
            { model | keyFocus = focus_ }
    in
        ( model_, React.none )
