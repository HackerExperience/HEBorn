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
import Game.Storyline.Emails.Contents exposing (..)


type alias Data =
    { personId : String
    , responses : List Content
    }


handler : Handler Data event
handler event =
    decodeValue newEmail >> Result.map event



-- internals


newEmail : Decoder Data
newEmail =
    decode Data
        |> required "contact_id" string
        |> required "responses" responses


responses : Decoder (List Content)
responses =
    field "id" string
        |> andThen contentFromId
        |> list
