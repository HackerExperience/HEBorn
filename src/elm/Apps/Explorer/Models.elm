module Apps.Explorer.Models exposing (..)

import Game.Software.Models exposing (FilePath, rootPath)


type alias Model =
    { path : FilePath
    }


initialModel : Model
initialModel =
    { path = rootPath }
