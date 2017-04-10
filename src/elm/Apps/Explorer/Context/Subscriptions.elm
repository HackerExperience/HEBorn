module Apps.Explorer.Context.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.Explorer.Context.Models exposing (Model)
import Apps.Explorer.Context.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
