module Events.Account.Story.ReplyUnlocked exposing (Data, handler)

import Json.Decode
    exposing
        ( Decoder
        , decodeValue
        , map
        , andThen
        , field
        , list
        , string
        )
import Json.Decode.Pipeline exposing (decode, required, optional)
import Events.Types exposing (Handler)
import Decoders.Emails exposing (contentFromId)
import Game.Storyline.Emails.Models exposing (Replies)


type alias Data =
    { personId : String
    , replies : Replies
    }


handler : Handler Data event
handler event =
    decodeValue newEmail >> Result.map event



-- internals


newEmail : Decoder Data
newEmail =
    decode Data
        |> required "contact_id" string
        |> required "replies" replies


replies : Decoder Replies
replies =
    field "id" string
        |> andThen contentFromId
        |> list
