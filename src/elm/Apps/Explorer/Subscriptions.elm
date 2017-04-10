module Apps.Explorer.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.Explorer.Models exposing (Model)
import Apps.Explorer.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map ContextMenuMsg (ContextMenu.subscriptions model.context.menu)
