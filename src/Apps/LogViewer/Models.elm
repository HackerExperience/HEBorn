module Apps.LogViewer.Models exposing (..)

import Dict
import Game.Models exposing (GameModel)
import Game.Servers.Filesystem.Models
    exposing
        ( FilePath
        , rootPath
        , pathExists
        )
import Apps.Instances.Models as Instance
    exposing
        ( Instances
        , InstanceID
        , initialState
        )
import Apps.Context as Context exposing (ContextApp)
import Apps.LogViewer.Context.Models as Menu


type alias LogViewer =
    {}


type alias ContextLogViewer =
    ContextApp LogViewer


type alias Model =
    { instances : Instances ContextLogViewer
    , menu : Menu.Model
    }


initialLogViewer : LogViewer
initialLogViewer =
    {}


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
