module Game.Storyline.Emails.Update exposing (update)

import Dict
import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Models as Game
import Game.Storyline.Emails.Models exposing (..)
import Game.Storyline.Emails.Messages exposing (..)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        Changed newModel ->
            onChanged newModel model

        Receive appendData ->
            onReceive appendData model


onChanged : Model -> Model -> UpdateResponse
onChanged newModel oldModel =
    Update.fromModel newModel


onReceive : ReceiveData -> Model -> UpdateResponse
onReceive ( from, messages, responses ) model =
    let
        apply person =
            let
                newMessages =
                    getMessages person
                        |> Dict.union messages

                newPerson =
                    { person
                        | messages = newMessages
                        , responses = responses
                    }
            in
                setPerson from newPerson model

        model_ =
            model
                |> getPerson from
                |> Maybe.map apply
                |> Maybe.withDefault model
    in
        Update.fromModel model_
