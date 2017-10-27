module Decoders.Emails exposing (..)

import Dict
import Json.Decode as Decode
    exposing
        ( Decoder
        , succeed
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
    email
        |> map toPerson
        |> list
        |> map Dict.fromList


toPerson : ( ID, Messages, Replies ) -> ( ID, Person )
toPerson ( id, messages, replies ) =
    { about =
        personMetadata id
    , messages =
        messages
    , replies =
        replies
    }
        |> (,) id


email : Decoder ( ID, Messages, Replies )
email =
    decode (,,)
        |> required "contact_id" string
        |> custom messages
        |> custom replies


replies : Decoder Replies
replies =
    string
        |> andThen contentFromId
        |> list
        |> field "replies"


messages : Decoder Messages
messages =
    messageNode
        |> list
        |> map Dict.fromList
        |> field "messages"


messageNode : Decoder ( Float, Message )
messageNode =
    decode (,)
        |> required "timestamp" float
        |> custom message


message : Decoder Message
message =
    andThen direction content


direction : Content -> Decoder Message
direction content =
    let
        decodeSender sender =
            case sender of
                "player" ->
                    Sent content

                _ ->
                    Received content
    in
        string
            |> field "sender"
            |> map decodeSender


content : Decoder Content
content =
    field "id" string
        |> andThen contentFromId


contentFromId : String -> Decoder Content
contentFromId id =
    case id of
        "helloworld" ->
            decode HelloWorld
                |> required "something" string
                |> field "meta"

        "welcome_pc_setup" ->
            succeed WelcomePCSetup

        "back_thanks" ->
            succeed WelcomeBackThanks

        error ->
            fail <| commonError "email_type" error
