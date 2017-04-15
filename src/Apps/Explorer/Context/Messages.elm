module Apps.Explorer.Context.Messages exposing (Msg(..), MenuAction(..))

import ContextMenu exposing (ContextMenu)
import Apps.Explorer.Context.Models exposing (Context)


type MenuAction
    = DoA
    | DoB


type Msg
    = MenuMsg (ContextMenu.Msg Context)
    | MenuClick MenuAction
