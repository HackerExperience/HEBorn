module Apps.DBAdmin.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.DBAdmin.Menu.Models exposing (Model)
import Apps.DBAdmin.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
