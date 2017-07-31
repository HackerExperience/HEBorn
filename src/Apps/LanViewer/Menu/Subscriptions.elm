module Apps.LanViewer.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.LanViewer.Menu.Models exposing (Model)
import Apps.LanViewer.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
