module Setup.Pages.SetHostname.Update exposing (update)

import Json.Decode exposing (Value)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Models as Game
import Utils.Update as Update
import Utils.Ports.Map as Map
import Utils.Ports.Geolocation exposing (geoLocReq, geoRevReq, decodeLabel)
import Setup.Pages.SetHostname.Models exposing (..)
import Setup.Pages.SetHostname.Messages exposing (..)


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse msg
update game msg model =
    case msg of
        SetHostname str ->
            onSetHostname str model

        Validate ->
            onValidate model

        ValidateOkay ->
            onValidateOkay model


onSetHostname : String -> Model -> UpdateResponse msg
onSetHostname str model =
    Update.fromModel <| setHostname str model


onValidate : Model -> UpdateResponse msg
onValidate model =
    Update.fromModel model


onValidateOkay : Model -> UpdateResponse msg
onValidateOkay model =
    Update.fromModel <| setOkay model
