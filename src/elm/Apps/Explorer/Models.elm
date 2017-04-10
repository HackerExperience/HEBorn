module Apps.Explorer.Models exposing (..)

import ContextMenu exposing (ContextMenu)
import Game.Software.Models exposing (FilePath, rootPath)
import Apps.Explorer.Context.Models exposing (Context, ContextModel, initialContext)


type alias Model =
    { path : FilePath
    , context : ContextModel
    }


initialModel : Model
initialModel =
    { path = rootPath
    , context = initialContext
    }
