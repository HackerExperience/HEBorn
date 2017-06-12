module OS.SessionManager.WindowManager.MenuHandler.View exposing (menuForCreator, menuViewCreator)

import Html exposing (Html)
import Html.Attributes
import ContextMenu exposing (ContextMenu)


menuViewCreator sourceMsg model context msg menu =
    Html.map sourceMsg
        (ContextMenu.view
            context.config
            msg
            (menu model)
            context.menu
        )


menuForCreator sourceMsg msg context =
    Html.Attributes.map sourceMsg
        (ContextMenu.open msg context)
