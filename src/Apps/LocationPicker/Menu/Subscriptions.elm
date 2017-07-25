module Apps.LocationPicker.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.LocationPicker.Menu.Models exposing (Model)
import Apps.LocationPicker.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
