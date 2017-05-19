module OS.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import OS.Menu.Models exposing (Model)
import OS.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
