module Apps.LogViewer.Models exposing (..)

import Dict
import Game.Shared exposing (..)
import Game.Models exposing (GameModel)
import Game.Servers.Models exposing (ServerID, Server(..), getServerByID)
import Game.Servers.Logs.Models as NetModel exposing (..)
import Apps.Instances.Models as Instance
    exposing
        ( Instances
        , InstanceID
        , initialState
        )
import Apps.Context as Context exposing (ContextApp)
import Apps.LogViewer.Context.Models as Menu
import Date exposing (Date, fromTime)


type alias LogViewer =
    { filtering : String
    , entries : Entries
    }


type alias ContextLogViewer =
    ContextApp LogViewer


type alias Model =
    { instances : Instances ContextLogViewer
    , menu : Menu.Model
    }


type alias LogID =
    NetModel.LogID


type LogEventMsg
    = LogIn IP ServerUser
    | Connetion IP IP IP
    | ExternalAcess ServerUser ServerUser
    | WrongA
    | WrongB


type alias Entries =
    Dict.Dict LogID LogViewerEntry


type alias LogViewerEntry =
    { timestamp : Date.Date
    , visibility : Bool
    , message : LogEventMsg
    }


initialLogViewer : LogViewer
initialLogViewer =
    { filtering = ""
    , entries = Dict.empty
    }


initialModel : Model
initialModel =
    { instances = initialState
    , menu = Menu.initialContext
    }


initialLogViewerContext : ContextLogViewer
initialLogViewerContext =
    Context.initialContext initialLogViewer


getLogViewerInstance : Instances ContextLogViewer -> InstanceID -> ContextLogViewer
getLogViewerInstance model id =
    case (Instance.get model id) of
        Just instance ->
            instance

        Nothing ->
            initialLogViewerContext


getLogViewerContext : ContextApp LogViewer -> LogViewer
getLogViewerContext instance =
    case (Context.state instance) of
        Just context ->
            context

        Nothing ->
            initialLogViewer


getState : Model -> InstanceID -> LogViewer
getState model id =
    getLogViewerContext
        (getLogViewerInstance model.instances id)


logToEntry : NetModel.Log -> LogViewerEntry
logToEntry log =
    { timestamp =
        case log of
            LogEntry x ->
                Date.fromTime x.timestamp

            NoLog ->
                Date.fromTime 0
    , visibility =
        False
    , message =
        WrongA
    }


logsToEntries : NetModel.Logs -> Entries
logsToEntries logs =
    Dict.map (\id oValue -> logToEntry oValue) logs


findLogs : ServerID -> GameModel -> NetModel.Logs
findLogs serverID game =
    case (getServerByID game.servers serverID) of
        StdServer server ->
            server.logs

        NoServer ->
            Dict.empty
