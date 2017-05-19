module OS.WindowManager.MenuHandler.Models exposing (..)

import ContextMenu exposing (ContextMenu)
import OS.WindowManager.MenuHandler.Config exposing (clientConfig)


type alias Model context =
    { menu : ContextMenu context
    , config : ContextMenu.Config
    }


initialModel : Model context
initialModel =
    let
        ( menu_, _ ) =
            ContextMenu.init
    in
        { menu = menu_
        , config = clientConfig
        }
