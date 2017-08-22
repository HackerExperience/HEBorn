module Apps.Email.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.Email.Menu.Models exposing (Model)
import Apps.Email.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
