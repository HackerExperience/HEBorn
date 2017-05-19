module Apps.Explorer.Subscriptions exposing (..)

import Apps.Explorer.Models exposing (Model)
import Apps.Explorer.Messages exposing (Msg(..))
import Apps.Explorer.Menu.Subscriptions as Menu


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
