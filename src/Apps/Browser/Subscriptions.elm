module Apps.Browser.Subscriptions exposing (..)

import Apps.Browser.Models exposing (Model)
import Apps.Browser.Messages exposing (Msg(..))
import Apps.Browser.Menu.Subscriptions as Menu


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
