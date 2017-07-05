module Apps.Finance.View exposing (view)

import Dict
import Html exposing (..)
import Html.CssHelpers
import Game.Data as Game
import UI.Layouts.VerticalList exposing (verticalList)
import Apps.Finance.Messages exposing (Msg(..))
import Apps.Finance.Models exposing (..)
import Apps.Finance.Resources exposing (Classes(..), prefix)
import Apps.Finance.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    verticalList
        [ div [] [ text "BTC", text "8,351", text "ACCOUNT 8153" ]
        , div [] [ text "R$", text "89,00", text "ACCOUNT 8153" ]
        , div [] [ text "R$", text "12,85", text "ACCOUNT 8153" ]
        , div [] [ text "BTC", text "50,1", text "ACCOUNT 8153" ]
        , div [] [ text "BTC", text "7,657", text "ACCOUNT 8153" ]
        ]
