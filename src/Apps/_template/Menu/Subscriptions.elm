module Apps.Template.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.Template.Menu.Models exposing (Model)
import Apps.Template.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
