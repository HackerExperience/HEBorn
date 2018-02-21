module Events.Account.Handlers.StoryEmailReplyUnlocked exposing (Data, handler)

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
import Events.Shared exposing (Handler)
import Decoders.Storyline exposing (replyFromId, replies)
import Game.Storyline.Shared exposing (Reply)


type alias Data =
    { contactId : String
    , replies : List Reply
    }


handler : Handler Data msg
handler toMsg =
    decodeValue newEmail >> Result.map toMsg



-- internals


newEmail : Decoder Data
newEmail =
    decode Data
        |> required "contact_id" string
        |> required "replies" replies
