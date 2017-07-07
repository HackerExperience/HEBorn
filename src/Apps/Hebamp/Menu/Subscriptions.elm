module Apps.Hebamp.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.Hebamp.Menu.Models exposing (Model)
import Apps.Hebamp.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
