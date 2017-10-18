module Events.Account.Story.NewEmail exposing (Data, handler)

import Json.Decode
    exposing
        ( Decoder
        , decodeValue
        , field
        , map
        , andThen
        , string
        , float
        , bool
        )
import Json.Decode.Pipeline exposing (decode, required, custom, optional)
import Events.Types exposing (Handler)
import Decoders.Emails
import Game.Storyline.Emails.Models exposing (..)
import Game.Storyline.Emails.Contents exposing (..)


type alias Data =
    { personId : String
    , messageNode : ( Float, Message )
    , responses : List Content
    , createNotification : Bool
    }


handler : Handler Data event
handler event =
    decodeValue newEmail >> Result.map event



-- internals


newEmail : Decoder Data
newEmail =
    decode Data
        |> required "contact_id" string
        |> custom messageNode
        |> optional "responses" (list string) []
        |> optional "notification" bool True


messageNode : Decoder ( Float, Message )
messageNode =
    decode (,)
        |> required "timestamp" float
        |> custom message


message : Decoder Message
message =
    field "email_id" string
        |> andThen Decoders.Emails.contentFromId
        |> map Received
