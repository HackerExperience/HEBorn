module Apps.Browser.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.Browser.Menu.Models exposing (Model)
import Apps.Browser.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
