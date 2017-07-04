module Apps.BounceManager.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.BounceManager.Menu.Models exposing (Model)
import Apps.BounceManager.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
