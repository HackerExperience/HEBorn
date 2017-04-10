module OS.WindowManager.ContextHandler.View exposing (contextForCreator, contextViewCreator)

import Html exposing (Html)
import Html.Attributes
import ContextMenu exposing (ContextMenu)


contextViewCreator sourceMsg model context msg menu =
    Html.map sourceMsg
        (ContextMenu.view
            context.config
            msg
            (menu model)
            context.menu
        )


contextForCreator sourceMsg msg context =
    Html.Attributes.map sourceMsg
        (ContextMenu.open msg context)
