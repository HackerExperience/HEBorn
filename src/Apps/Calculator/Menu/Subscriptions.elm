module Apps.Calculator.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.Calculator.Menu.Models exposing (Model)
import Apps.Calculator.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
