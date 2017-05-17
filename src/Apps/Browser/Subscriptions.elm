module Apps.Browser.Subscriptions exposing (..)

import Apps.Browser.Models exposing (Model)
import Apps.Browser.Messages exposing (Msg(..))
import Apps.Browser.Context.Subscriptions as Context


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map ContextMsg (Context.subscriptions model.menu)
