module OS.Context.Messages exposing (Msg(..), MenuAction(..))

import ContextMenu exposing (ContextMenu)
import OS.Context.Models exposing (Context)


type MenuAction
    = NoOp


type Msg
    = MenuMsg (ContextMenu.Msg Context)
    | MenuClick MenuAction
