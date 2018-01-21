module Apps.Browser.Subscriptions exposing (..)

import Apps.Browser.Config exposing (..)
import Apps.Browser.Models exposing (Model)
import Apps.Browser.Messages exposing (Msg(..))
import Apps.Browser.Menu.Subscriptions as Menu


subscriptions : Config msg -> Model -> Sub Msg
subscriptions config model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
