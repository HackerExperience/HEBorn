module OS.WindowManager.ContextHandler.Subscriptions exposing (subscriptions)

import ContextMenu exposing (ContextMenu)
import OS.WindowManager.Messages exposing (Msg(..))
import OS.WindowManager.ContextHandler.Messages exposing (ContextMsg(..))


subscriptions model =
    Sub.map ContextHandlerMsg
        (Sub.map ExplorerContext (ContextMenu.subscriptions model.explorer.menu))
