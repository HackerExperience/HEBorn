module OS.View exposing (view)

import OS.Models exposing (..)
import OS.Messages exposing (..)
import OS.Resources as Res
import Html exposing (..)
import Html.CssHelpers
import Core.Models as Core
import Game.Data as GameData
import OS.Header.View as Header
import OS.Menu.View exposing (menuView, menuEmpty)
import OS.SessionManager.View as SessionManager


{ id, class, classList } =
    Html.CssHelpers.withNamespace Res.prefix


view : GameData.Data -> Core.PlayModel -> Html Msg
view data model =
    div
        [ id Res.Dashboard
        , menuEmpty
        ]
        [ viewHeader data model.os
        , viewMain data model.os
        , displayVersion model.game.config.version
        , menuView model.os
        ]


viewHeader : GameData.Data -> Model -> Html Msg
viewHeader game model =
    model.header
        |> Header.view game
        |> Html.map HeaderMsg


viewMain : GameData.Data -> Model -> Html Msg
viewMain game model =
    model.session
        |> SessionManager.view game
        |> Html.map SessionManagerMsg


displayVersion : String -> Html Msg
displayVersion version =
    div
        [ class [ Res.Version ] ]
        [ text version ]
