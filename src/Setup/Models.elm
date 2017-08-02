module Setup.Models exposing (..)

import Game.Models as Game
import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Ports.Map exposing (Coordinates)
import Setup.Types exposing (..)
import Setup.Messages exposing (Msg)


type alias Model =
    { step : Step
    , coordinates : Maybe Coordinates
    , areaLabel : Maybe String
    }


mapId : String
mapId =
    "map-setup"


geoInstance : String
geoInstance =
    "setup"


initialModel : Game.Model -> ( Model, Cmd Msg, Dispatch )
initialModel game =
    let
        model =
            { step = Welcome
            , coordinates = Nothing
            , areaLabel = Nothing
            }
    in
        ( model, Cmd.none, Dispatch.none )


setCoords : Maybe Coordinates -> Model -> Model
setCoords coordinates model =
    let
        model_ =
            { model | coordinates = coordinates }
    in
        model_


setAreaLabel : Maybe String -> Model -> Model
setAreaLabel areaLabel model =
    let
        model_ =
            { model | areaLabel = areaLabel }
    in
        model_


setStep : Step -> Model -> Model
setStep step model =
    let
        model_ =
            { model | step = step }
    in
        model_
