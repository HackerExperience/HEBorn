module Apps.Subscriptions exposing (subscriptions)

import Apps.Models exposing (AppModel)
import Apps.Messages exposing (AppMsg(..))
import Apps.Explorer.Subscriptions
import Apps.SignUp.Context.Subscriptions


subscriptions : AppModel -> Sub AppMsg
subscriptions model =
    Sub.none
