module Apps.ConnManager.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.ConnManager.Menu.Models exposing (Model)
import Apps.ConnManager.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
