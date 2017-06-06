module Game.Servers.Logs.Models exposing (..)

import Dict
import Utils
import Time exposing (Time)
import Game.Shared as Game exposing (IP, ID, ServerUser)


type alias ID =
    Game.ID


type alias RawContent =
    String


type alias Data =
    { id : ID
    , status : Status
    , timestamp : Time
    , raw : RawContent
    , smart : SmartContent
    , event : Event
    }


type Log
    = StdLog Data
    | NoLog


type alias Logs =
    Dict.Dict ID Log


type alias FileName =
    String


type SmartContent
    = LoginLocal IP ServerUser
    | LoginRemote IP
    | Connection IP IP IP
    | DownloadBy FileName IP
    | DownloadFrom FileName IP
    | Invalid String


type Event
    = NoEvent
    | EventRecentlyFound
    | EventRecentlyCreated


type Status
    = StatusNormal
    | Cryptographed


initialLogs : Logs
initialLogs =
    Dict.empty


getByID : ID -> Logs -> Log
getByID id logs =
    case Dict.get id logs of
        Just log ->
            log

        Nothing ->
            NoLog


exists : ID -> Logs -> Bool
exists id logs =
    Dict.member id logs


getTimestamp : Log -> Maybe Time
getTimestamp log =
    case log of
        StdLog l ->
            Just l.timestamp

        NoLog ->
            Nothing


getRawContent : Log -> Maybe RawContent
getRawContent log =
    case log of
        StdLog l ->
            Just l.raw

        NoLog ->
            Nothing


getSmartContent : Log -> Maybe SmartContent
getSmartContent log =
    case log of
        StdLog l ->
            Just l.smart

        NoLog ->
            Nothing


getID : Log -> Maybe ID
getID log =
    case log of
        StdLog l ->
            Just l.id

        NoLog ->
            Nothing


add : Log -> Logs -> Logs
add log logs =
    case (getID log) of
        Just id ->
            Dict.insert id log logs

        Nothing ->
            logs


remove : Log -> Logs -> Logs
remove log logs =
    case (getID log) of
        Just id ->
            Dict.remove id logs

        Nothing ->
            logs


update : Log -> Logs -> Logs
update log logs =
    case log of
        StdLog entry ->
            Utils.safeUpdateDict logs entry.id log

        NoLog ->
            logs


interpretRawContent : RawContent -> SmartContent
interpretRawContent src =
    let
        splitten =
            String.split " " src
    in
        case splitten of
            [ addr, "logged", "in", "as", user ] ->
                LoginLocal addr user

            [ actor, "bounced", "connection", "from", src, "to", dest ] ->
                Connection actor src dest

            [ "File", fileName, "downloaded", "by", destIP ] ->
                DownloadBy fileName destIP

            [ "File", fileName, "downloaded", "from", srcIP ] ->
                DownloadFrom fileName srcIP

            [ "Logged", "into", destinationIP ] ->
                LoginRemote destinationIP

            _ ->
                Invalid src
