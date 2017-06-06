module Apps.TaskManager.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.TaskManager.Menu.Models exposing (Model)
import Apps.TaskManager.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
