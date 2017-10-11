module Decoders.Emails exposing (..)

import Dict
import Json.Decode as Decode
    exposing
        ( Decoder
        , andThen
        , map
        , field
        , fail
        , float
        , string
        , list
        )
import Json.Decode.Pipeline exposing (decode, required, optional, custom)
import Utils.Json.Decode exposing (optionalMaybe, commonError)
import Game.Storyline.Emails.Models exposing (..)
import Game.Storyline.Emails.Contents exposing (..)


emails : Decoder Model
emails =
    decode (,)
        |> required "contact_id" string
        |> custom person
        |> map initAbout
        |> list
        |> map Dict.fromList


person : Decoder Person
person =
    decode Person
        |> optionalMaybe "about" about
        |> optional "messages" messages Dict.empty
        |> optional "responses" (list content) []


initAbout : ( ID, Person ) -> ( ID, Person )
initAbout (( id, person ) as data) =
    case person.about of
        Nothing ->
            ( id, { person | about = (personMetadata id) } )

        _ ->
            data


about : Decoder About
about =
    decode About
        |> required "email" string
        |> required "name" string
        |> required "picture" string


messages : Decoder Messages
messages =
    decode (,)
        |> required "timestamp" float
        |> custom message
        |> list
        |> map Dict.fromList


message : Decoder Message
message =
    content
        |> andThen direction


directionFromString : Content -> String -> Message
directionFromString content str =
    case str of
        "player" ->
            Sent content

        _ ->
            Received content


direction : Content -> Decoder Message
direction msg =
    field "sender" string
        |> map (directionFromString msg)


contentFromId : String -> Decoder Content
contentFromId id =
    case id of
        "helloworld" ->
            decode HelloWorld
                |> required "something" string
                |> field "meta"

        error ->
            fail <| commonError "email_type" error


content : Decoder Content
content =
    field "id" string
        |> andThen contentFromId
