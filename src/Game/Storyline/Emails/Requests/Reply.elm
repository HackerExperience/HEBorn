module Game.Storyline.Emails.Requests.Reply
    exposing
        ( Response(..)
        , request
        , receive
        )

import Json.Decode as Decode
    exposing
        ( Decoder
        , Value
        , decodeValue
        , map
        , succeed
        , fail
        , string
        )
import Json.Encode as Encode
import Utils.Json.Decode exposing (commonError)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Game.Storyline.Emails.Messages exposing (..)


type Response
    = Okay
    | WrongStep
    | ReplyNotFound


request :
    String
    -> String
    -> FlagsSource a
    -> Cmd Msg
request accountId replyId =
    Requests.request
        (Topics.emailReply accountId)
        (ReplyRequest >> Request)
        (encoder replyId)


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            Just Okay

        ErrorCode ->
            Requests.decodeGenericError
                json
                decodeErrorMessage

        _ ->
            Nothing



-- INTERNALS


encoder : String -> Value
encoder replyId =
    Encode.object
        [ ( "reply_id", Encode.string replyId )
        ]


decodeErrorMessage : String -> Decoder Response
decodeErrorMessage str =
    case str of
        "not_in_step" ->
            succeed WrongStep

        "reply_not_found" ->
            succeed ReplyNotFound

        value ->
            fail <| commonError "email reply error message" value
