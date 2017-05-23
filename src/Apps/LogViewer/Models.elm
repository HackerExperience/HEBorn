module Apps.LogViewer.Models exposing (..)

import Dict
import Utils exposing (filterMapDict)
import Game.Shared exposing (..)
import Game.Servers.Models exposing (ServerID, Server(..), getServerByID, localhostServerID)
import Game.Servers.Logs.Models as NetModel exposing (..)
import Apps.LogViewer.Menu.Models as Menu
import Date exposing (Date, fromTime)


type alias LogViewer =
    { filtering : String
    , entries : Entries
    }


type alias Model =
    { app : LogViewer
    , menu : Menu.Model
    }


type alias LogID =
    NetModel.LogID


type alias FileName =
    String


type LogEventMsg
    = LogIn IP ServerUser
    | LogInto IP
    | Connection IP IP IP
    | ExternalAcess ServerUser ServerUser
    | DownloadBy FileName IP
    | DownloadFrom FileName IP
    | Invalid


type LogEventStatus
    = Normal Bool
    | Editing
    | Cryptographed Bool
    | Hidden


type alias Entries =
    Dict.Dict LogID LogViewerEntry


type alias LogViewerEntry =
    { timestamp : Date.Date
    , status : LogEventStatus
    , message : LogEventMsg
    , srcID : LogID
    , src : String
    }


name : String
name =
    "Log Viewer"


title : Model -> String
title model =
    "Log Viewer"


icon : String
icon =
    "logvw"


isEntryExpanded : LogViewerEntry -> Bool
isEntryExpanded entry =
    case entry.status of
        Normal True ->
            True

        Cryptographed True ->
            True

        Editing ->
            True

        _ ->
            False


toggleExpanded : LogEventStatus -> LogEventStatus
toggleExpanded status =
    case status of
        Normal x ->
            Normal (not x)

        Cryptographed x ->
            Normal (not x)

        _ ->
            status


initialModel : Model
initialModel =
    { app = initialLogViewer
    , menu = Menu.initialMenu
    }


initialLogViewer : LogViewer
initialLogViewer =
    { filtering = ""
    , entries = Dict.empty
    }


logContentInterpret : String -> LogEventMsg
logContentInterpret src =
    let
        splitten =
            String.split " " src
    in
        case splitten of
            [ addr, "logged", "in", "as", user ] ->
                LogIn addr user

            [ actor, "bounced", "connection", "from", src, "to", dest ] ->
                Connection actor src dest

            [ "File", fileName, "downloaded", "by", destIP ] ->
                DownloadBy fileName destIP

            [ "File", fileName, "downloaded", "from", srcIP ] ->
                DownloadFrom fileName srcIP

            [ "Logged", "into", destinationIP ] ->
                LogInto destinationIP

            _ ->
                Invalid


logToEntry : NetModel.Log -> Maybe LogViewerEntry
logToEntry log =
    case log of
        LogEntry x ->
            Just
                { timestamp =
                    Date.fromTime x.timestamp
                , status =
                    Normal False
                , message =
                    logContentInterpret x.content
                , srcID =
                    x.id
                , src =
                    x.content
                }

        NoLog ->
            Nothing


logsToEntries : NetModel.Logs -> Entries
logsToEntries logs =
    filterMapDict (\id oValue -> logToEntry oValue) logs


findLogs serverID game =
    case (getServerByID game.servers serverID) of
        StdServer server ->
            server.logs

        NoServer ->
            Dict.empty
