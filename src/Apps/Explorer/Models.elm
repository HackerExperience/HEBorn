module Apps.Explorer.Models exposing (..)

import Game.Software.Models exposing (FilePath, rootPath)
import Apps.Explorer.Context.Models as Context


type alias Model =
    { path : FilePath
    , context : Context.Model
    }


initialModel : Model
initialModel =
    { path = rootPath
    , context = Context.initialContext
    }
