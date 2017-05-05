module Apps.LogViewer.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.LogViewer.Menu.Models exposing (Model)
import Apps.LogViewer.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
