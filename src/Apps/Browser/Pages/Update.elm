module Apps.Browser.Pages.Subscriptions exposing (subscriptions)

import Game.Data as GameData
import Apps.Browser.Pages.Models exposing (..)
import Apps.Browser.Pages.Messages exposing (..)


update : GameData.Data -> Msg -> Model -> Sub Msg
update data msg model =
    ( model, Cmd.none )
