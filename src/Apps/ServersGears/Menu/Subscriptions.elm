module Apps.ServersGears.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.ServersGears.Menu.Models exposing (Model)
import Apps.ServersGears.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
