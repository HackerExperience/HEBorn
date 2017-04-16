module OS.Context.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import OS.Context.Models exposing (Model)
import OS.Context.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (ContextMenu.subscriptions model.menu)
