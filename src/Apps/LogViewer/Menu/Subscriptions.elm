module Apps.LogViewer.Context.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.LogViewer.Context.Models exposing (Model)
import Apps.LogViewer.Context.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
