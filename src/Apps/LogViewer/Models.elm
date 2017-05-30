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
    | DownloadBy FileName IP
    | DownloadFrom FileName IP
    | Invalid String


type LogEventStatus
    = Normal Bool
    | Editing String
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
title ({ app } as model) =
    if (String.length app.filtering) > 12 then
        "Log Viewer: \"" ++ (String.left 10 app.filtering) ++ "[...]\""
    else if (String.length app.filtering) > 0 then
        "Log Viewer: \"" ++ app.filtering ++ "\""
    else
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

        Editing _ ->
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
                Invalid src


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


entriesUpdate : (LogViewerEntry -> Maybe LogViewerEntry) -> LogID -> Entries -> Entries
entriesUpdate fn logID entries =
    Dict.update logID (Maybe.andThen fn) entries


entryToggle : LogID -> Entries -> Entries
entryToggle =
    entriesUpdate (\x -> Just { x | status = (toggleExpanded x.status) })


entryEnterEditing : LogID -> Entries -> Entries
entryEnterEditing =
    entriesUpdate (\x -> Just { x | status = Editing x.src })


entryLeaveEditing : LogID -> Entries -> Entries
entryLeaveEditing =
    entriesUpdate (\x -> Just { x | status = Normal True })


entryApplyEditing : LogID -> Entries -> Entries
entryApplyEditing =
    -- TODO: Send update do Game Models && refresh logs
    entriesUpdate
        (\x ->
            case x.status of
                Editing input ->
                    Just
                        { x
                            | status =
                                Normal True
                            , message =
                                logContentInterpret input
                            , src =
                                input
                        }

                _ ->
                    Nothing
        )


entryUpdateEditing : String -> LogID -> Entries -> Entries
entryUpdateEditing input =
    entriesUpdate (\x -> Just { x | status = Editing input })
