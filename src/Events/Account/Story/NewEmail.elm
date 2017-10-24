module Events.Account.Story.NewEmail exposing (Data, handler)

import Json.Decode
    exposing
        ( Decoder
        , decodeValue
        , field
        , map
        , andThen
        , list
        , string
        , float
        , bool
        )
import Json.Decode.Pipeline exposing (decode, required, custom, optional)
import Events.Types exposing (Handler)
import Decoders.Emails exposing (contentFromId)
import Game.Storyline.Emails.Models exposing (..)
import Game.Storyline.Emails.Contents exposing (..)


type alias Data =
    { personId : String
    , messageNode : ( Float, Message )
    , replies : Replies
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
        |> optional "replies" replies []
        |> optional "notification" bool True


messageNode : Decoder ( Float, Message )
messageNode =
    decode (,)
        |> required "timestamp" float
        |> custom message


replies : Decoder (List Content)
replies =
    string
        |> andThen contentFromId
        |> list


message : Decoder Message
message =
    field "email_id" string
        |> andThen
            contentFromId
        |> map Received
