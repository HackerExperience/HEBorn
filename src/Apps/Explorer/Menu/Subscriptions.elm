module Apps.Explorer.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.Explorer.Menu.Models exposing (Model)
import Apps.Explorer.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
