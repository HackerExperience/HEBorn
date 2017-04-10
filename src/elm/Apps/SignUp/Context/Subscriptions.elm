module Apps.SignUp.Context.Subscriptions exposing (..)

import ContextMenu exposing (ContextMenu)
import Apps.SignUp.Models exposing (Model)
import Apps.SignUp.Messages exposing (Msg(..))


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map ContextMenuMsgS (ContextMenu.subscriptions model.context.menu)
