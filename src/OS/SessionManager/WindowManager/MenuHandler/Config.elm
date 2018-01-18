module OS.SessionManager.WindowManager.MenuHandler.Config exposing (clientConfig)

import ContextMenu exposing (..)
import Color exposing (Color)


clientConfig : ContextMenu.Config
clientConfig =
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
