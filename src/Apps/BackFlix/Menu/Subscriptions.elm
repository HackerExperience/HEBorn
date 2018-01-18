module Apps.BackFlix.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.BackFlix.Menu.Models exposing (Model)
import Apps.BackFlix.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
