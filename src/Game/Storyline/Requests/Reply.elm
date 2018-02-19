module Game.Storyline.Requests.Reply
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
import Game.Storyline.Messages exposing (..)
import Game.Storyline.Shared exposing (ContactId, Reply(..))


type Response
    = Okay
    | WrongStep
    | ReplyNotFound


request :
    ( ContactId, Reply )
    -> ContactId
    -> Reply
    -> FlagsSource a
    -> Cmd Msg
request (( contactId, _ ) as src) accountId reply =
    Requests.request
        (Topics.emailReply accountId)
        (ReplyRequest src >> Request)
        (encoder contactId reply)


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


encoder : ContactId -> Reply -> Value
encoder contactId reply =
    Encode.object
        [ ( "reply_id", Encode.string <| getReplyId reply )
        , ( "contact_id", Encode.string contactId )
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


getReplyId : Reply -> String
getReplyId reply =
    case reply of
        AboutThat ->
            "about_that"

        BackThanks ->
            "back_thanks"

        DownloadCracker1 _ ->
            "download_cracker1"

        Downloaded ->
            "downloaded"

        HellYeah ->
            "hell_yeah"

        NothingNow ->
            "nothing_now"

        WatchIADoing ->
            "watchiadoing"

        Welcome ->
            "welcome"

        YeahRight ->
            "yeah_right"

        NastyVirus1 ->
            "nasty_virus1"
