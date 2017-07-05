module Apps.Finance.Subscriptions exposing (..)

import Game.Data as Game
import Apps.Finance.Models exposing (Model)
import Apps.Finance.Messages exposing (Msg(..))
import Apps.Finance.Menu.Subscriptions as Menu


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    Sub.map MenuMsg (Menu.subscriptions model.menu)
