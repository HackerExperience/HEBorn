module Apps.Explorer.Subscriptions exposing (..)

import Apps.Explorer.Config exposing (..)
import Apps.Explorer.Models exposing (Model)
import Apps.Explorer.Messages exposing (Msg(..))
import Apps.Explorer.Menu.Subscriptions as Menu


subscriptions : Config msg -> Model -> Sub Msg
subscriptions config model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
