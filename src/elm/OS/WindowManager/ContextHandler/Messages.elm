module OS.WindowManager.ContextHandler.Messages exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.Explorer.Context.Models as Explorer
import Apps.SignUp.Context.Models as SignUp


type ContextMsg
    = SignUpContext (ContextMenu.Msg SignUp.Context)
    | ExplorerContext (ContextMenu.Msg Explorer.Context)
