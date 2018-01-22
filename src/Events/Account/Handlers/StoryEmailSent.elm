module Events.Account.Handlers.StoryEmailSent exposing (Data, handler, notify)

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
import Events.Shared exposing (Handler)
import Decoders.Emails exposing (contentFromId)
import Game.Storyline.Emails.Models exposing (..)
import Game.Storyline.Emails.Contents exposing (..)


type alias Data =
    { personId : String
    , messageNode : ( Float, Message )
    , replies : Replies
    , createNotification : Bool
    }


handler : Handler Data msg
handler toMsg =
    decodeValue newEmail >> Result.map toMsg


notify : (String -> value) -> (Maybe Float -> value -> msg) -> Data -> msg
notify toContent toMsg { personId, messageNode } =
    let
        ( time, _ ) =
            messageNode
    in
        toMsg (Just time) <| toContent personId



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
