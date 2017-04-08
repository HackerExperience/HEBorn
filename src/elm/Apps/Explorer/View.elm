module Apps.Explorer.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Game.Models exposing (GameModel)
import Apps.Explorer.Messages exposing (Msg(..))
import Apps.Explorer.Models exposing (Model)
import Apps.Explorer.Style exposing (Classes(..))


{ id, class, classList } =
    Html.CssHelpers.withNamespace "explorer"


view : Model -> GameModel -> Html Msg
view model game =
    div [ class [ Window ] ]
        [ viewExplorerColumn model game
        , viewExplorerMain model game
        ]


viewExplorerColumn : Model -> GameModel -> Html Msg
viewExplorerColumn model game =
    div [ class [ Nav ] ] [ text "col" ]


viewExplorerMain : Model -> GameModel -> Html Msg
viewExplorerMain model game =
    div [ class [ Content ] ] [ text "main" ]
