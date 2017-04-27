module Apps.Explorer.Models exposing (..)

import Dict
import Game.Models exposing (GameModel)
import Game.Servers.Models
    exposing
        ( ServerID
        , getFilesystem
        , getServerByID
        )
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
import Apps.Explorer.Context.Models as Menu


type alias Explorer =
    { serverID : ServerID
    , path : FilePath
    }


type alias ContextExplorer =
    ContextApp Explorer


type alias Model =
    { instances : Instances ContextExplorer
    , menu : Menu.Model
    }


initialExplorer : Explorer
initialExplorer =
    { serverID = "invalid"
    , path = rootPath
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
    let
        server =
            getServerByID game.servers explorer.serverID

        filesystem =
            getFilesystem server

        explorer_ =
            case filesystem of
                Just fs ->
                    if pathExists path fs then
                        setPath explorer path
                    else
                        explorer

                Nothing ->
                    explorer
    in
        explorer_
