module Apps.FloatingHeads.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.FloatingHeads.Menu.Models exposing (Model)
import Apps.FloatingHeads.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
