module OS.Map.Update exposing (update)

import Utils.React as React exposing (React)
import OS.Map.Config exposing (..)
import OS.Map.Messages exposing (..)
import OS.Map.Models exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    ( model, React.none )
