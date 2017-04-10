module Apps.SignUp.Context.Models exposing (..)

import ContextMenu exposing (ContextMenu)
import ContextMenu exposing (Overflow(..), Cursor(..), Direction(..), defaultConfig)
import Color exposing (Color)


type Context
    = ContextOnly


type alias ContextModel =
    { menu : ContextMenu Context
    , config : ContextMenu.Config
    }


winChrome : ContextMenu.Config
winChrome =
    { defaultConfig
        | direction = RightBottom
        , overflowX = Mirror
        , overflowY = Mirror
        , containerColor = white
        , hoverColor = lightGray
        , invertText = False
        , cursor = Arrow
        , rounded = False
    }


white : Color
white =
    Color.rgb 255 255 255


lightGray : Color
lightGray =
    Color.rgb 238 238 238


initialContext =
    let
        ( contextMenu, _ ) =
            ContextMenu.init
    in
        { menu = contextMenu
        , config = winChrome
        }
