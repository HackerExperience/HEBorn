module Events.Storyline.Emails exposing (Event(..), ReceiveData, handler)

import Json.Decode
    exposing
        ( Decoder
        , decodeValue
        , map
        , andThen
        , field
        , string
        , float
        )
import Json.Decode.Pipeline exposing (decode, required, custom)
import Utils.Events exposing (Handler, notify)
import Decoders.Emails exposing (decodeContent)
import Game.Storyline.Emails.Models exposing (..)
import Game.Storyline.Emails.Contents exposing (..)


type Event
    = NewEmail ( String, ( Float, Message ), List Content )


type alias ReceiveData =
    ( ID, Messages, Responses )


handler : String -> Handler Event
handler event json =
    case event of
        "story_email_sent" ->
            onNewEmail json

        _ ->
            Nothing



-- internals


onNewEmail : Handler Event
onNewEmail json =
    decodeValue newEmail json
        |> Result.map (\msg -> NewEmail ( "TODO", msg, [] ))
        |> notify


newEmail : Decoder ( Float, Message )
newEmail =
    decode (,)
        |> required "timestamp" float
        |> custom message


message : Decoder Message
message =
    field "email_id" string
        |> andThen decodeContent
        |> map Received
