module Apps.Bug.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.Bug.Menu.Models exposing (Model)
import Apps.Bug.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
