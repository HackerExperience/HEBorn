module Apps.Explorer.Models exposing (..)

import Dict
import Game.Software.Models exposing (FilePath, rootPath)
import Apps.Instances.Models exposing (Instances, initialState)
import Apps.Explorer.Context.Models as Context


type alias Explorer =
    { path : FilePath
    }


type alias Model =
    { instances : Instances Explorer
    , context : Context.Model
    }


initialExplorer : Explorer
initialExplorer =
    { path = rootPath
    }


initialModel : Model
initialModel =
    { instances = initialState
    , context = Context.initialContext
    }
