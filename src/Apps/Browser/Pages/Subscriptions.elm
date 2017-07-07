module Apps.Browser.Pages.Subscriptions exposing (subscriptions)

import Game.Data as GameData
import Apps.Browser.Pages.Models exposing (..)
import Apps.Browser.Pages.Messages exposing (..)


subscriptions : GameData.Data -> Model -> Sub Msg
subscriptions data model =
    Sub.none
