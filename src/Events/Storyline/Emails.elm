module Events.Storyline.Emails exposing (Event(..), handler, decoder)

import Dict
import Json.Decode
    exposing
        ( Decoder
        , decodeValue
        , andThen
        , dict
        , list
        , string
        , float
        , succeed
        , fail
        , maybe
        )
import Json.Decode.Pipeline exposing (decode, required, optional)
import Utils.Events exposing (Handler, notify, commonError)
import Game.Storyline.Emails.Models exposing (..)


type Event
    = Changed Model
    | Receive ReceiveData


handler : String -> Handler Event
handler event json =
    case event of
        "receive" ->
            onReceive json

        _ ->
            Nothing



-- internals


onReceive : Handler Event
onReceive json =
    decodeValue receive json
        |> Result.map Receive
        |> notify


decoder : Decoder Model
decoder =
    dict person
        |> andThen (Dict.map initAbout >> succeed)


person : Decoder Person
person =
    decode Person
        |> optional "about" (maybe about) Nothing
        |> optional "messages" messages Dict.empty
        |> optional "responses" responses []


initAbout : PersonID -> Person -> Person
initAbout id person =
    case person.about of
        Nothing ->
            { person | about = (personMetadata id) }

        _ ->
            person


about : Decoder About
about =
    decode About
        |> required "email" string
        |> required "name" string
        |> required "picture" string


messages : Decoder Messages
messages =
    list message
        |> andThen (Dict.fromList >> succeed)


messageGuess : ( Float, String, String ) -> Decoder ( Float, Message )
messageGuess ( time, direction, phrase ) =
    case direction of
        "sended" ->
            succeed ( time, Sended phrase )

        "received" ->
            succeed ( time, Received phrase )

        _ ->
            fail "Unrecgonized direction"


message : Decoder ( Float, Message )
message =
    decode (,,)
        |> required "time" float
        |> required "direction" string
        |> required "phrase" string
        |> andThen messageGuess


responses : Decoder Responses
responses =
    list string


receive : Decoder ReceiveData
receive =
    decode (,,)
        |> required "from" string
        |> required "messages" messages
        |> optional "responses" responses []
