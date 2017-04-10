module Apps.Explorer.Subscriptions exposing (..)

import Apps.Explorer.Models exposing (Model)
import Apps.Explorer.Messages exposing (Msg(..))
import Apps.Explorer.Context.Subscriptions as Context


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map ContextMsg (Context.subscriptions model.context)
