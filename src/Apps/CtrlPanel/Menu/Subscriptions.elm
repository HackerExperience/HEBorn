module Apps.CtrlPanel.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.CtrlPanel.Menu.Models exposing (Model)
import Apps.CtrlPanel.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
