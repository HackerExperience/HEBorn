module Game.Storyline.Requests.Reply exposing (Data, Error, replyRequest)

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
import Utils.Json.Decode exposing (message, commonError)
import Requests.Requests as Requests exposing (report)
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Game.Storyline.Shared exposing (ContactId, Reply(..))


type alias Data =
    Result Error ()


type Error
    = WrongStep
    | ReplyNotFound
    | Unknown



-- TODO: check if passing two replies is needed


replyRequest :
    ContactId
    -> Reply
    -> ContactId
    -> Reply
    -> FlagsSource a
    -> Cmd Data
replyRequest contactId reply1 accountId reply2 flagsSrc =
    flagsSrc
        |> Requests.request (Topics.emailReply accountId)
            (encoder contactId reply1)
        |> Cmd.map (uncurry <| receiver flagsSrc)



-- internals


encoder : ContactId -> Reply -> Value
encoder contactId reply =
    Encode.object
        [ ( "reply_id", Encode.string <| getReplyId reply )
        , ( "contact_id", Encode.string contactId )
        ]


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

        NastyVirus2 ->
            "nasty_virus2"

        Punks1 ->
            "punks1"

        Punks2 ->
            "punks2"

        Punks3 _ ->
            "punks3"

        DlaydMuch1 ->
            "dlayd_much1"


receiver : FlagsSource a -> Code -> Value -> Data
receiver flagsSrc code json =
    case code of
        OkCode ->
            Ok ()

        ErrorCode ->
            json
                |> decodeValue errorMessage
                |> report "Storyline.Reply" code flagsSrc
                |> Result.mapError (always Unknown)
                |> Result.andThen Err

        _ ->
            Err Unknown


errorMessage : Decoder Error
errorMessage =
    message <|
        \str ->
            case str of
                "not_in_step" ->
                    succeed WrongStep

                "reply_not_found" ->
                    succeed ReplyNotFound

                value ->
                    fail <| commonError "email reply error message" value
