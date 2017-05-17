module Apps.Browser.Context.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.Browser.Context.Models exposing (Model)
import Apps.Browser.Context.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
