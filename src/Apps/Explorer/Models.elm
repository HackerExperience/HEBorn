module Apps.Explorer.Models exposing (..)

import Dict
import Game.Software.Models exposing (FilePath, rootPath)
import Apps.Instances.Models as Instance
    exposing
        ( Instances
        , InstanceID
        , initialState
        )
import Apps.Context as Context exposing (ContextApp)
import Apps.Explorer.Context.Models as Menu


type alias Explorer =
    { path : FilePath
    }


type alias ContextExplorer =
    ContextApp Explorer


type alias Model =
    { instances : Instances ContextExplorer
    , menu : Menu.Model
    }


initialExplorer : Explorer
initialExplorer =
    { path = rootPath
    }


initialModel : Model
initialModel =
    { instances = initialState
    , menu = Menu.initialContext
    }


initialExplorerContext : ContextExplorer
initialExplorerContext =
    Context.initialContext initialExplorer


getExplorerInstance : Instances ContextExplorer -> InstanceID -> ContextExplorer
getExplorerInstance model id =
    case (Instance.get model id) of
        Just instance ->
            instance

        Nothing ->
            initialExplorerContext


getExplorerContext : ContextApp Explorer -> Explorer
getExplorerContext instance =
    case (Context.state instance) of
        Just context ->
            context

        Nothing ->
            initialExplorer


getState : Model -> InstanceID -> Explorer
getState model id =
    getExplorerContext
        (getExplorerInstance model.instances id)


getCurrentPath explorer =
    explorer.path
