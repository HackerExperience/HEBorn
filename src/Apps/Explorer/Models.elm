module Apps.Explorer.Models exposing (..)

import Dict
import Game.Models exposing (GameModel)
import Game.Software.Models
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


getPath : Explorer -> FilePath
getPath explorer =
    explorer.path


setPath : Explorer -> FilePath -> Explorer
setPath explorer path =
    { explorer | path = path }


changePath : Explorer -> GameModel -> FilePath -> Explorer
changePath explorer game path =
    if not (pathExists game.software path) then
        explorer
    else
        setPath explorer path
