module Apps.LogFlix.Menu.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.LogFlix.Menu.Models exposing (Model)
import Apps.LogFlix.Menu.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
