module Setup.Models
    exposing
        ( Model
        , initialModel
        , setPos
        )

import Game.Models as Game
import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Ports.Map exposing (Coordinates)
import Utils.Ports.Geolocation exposing (geoReq)
import Setup.Messages exposing (..)


type alias Model =
    { coordinates : Maybe Coordinates
    }


initialModel : Game.Model -> ( Model, Cmd Msg, Dispatch )
initialModel game =
    let
        model =
            { coordinates = Nothing
            }

        cmd =
            geoReq "setup"
    in
        ( model, cmd, Dispatch.none )


setPos : Maybe Coordinates -> Model -> Model
setPos coordinates model =
    let
        model_ =
            { model | coordinates = coordinates }
    in
        model_
