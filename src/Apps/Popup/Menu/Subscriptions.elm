module Apps.Popup.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.Popup.Menu.Models exposing (Model)
import Apps.Popup.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
