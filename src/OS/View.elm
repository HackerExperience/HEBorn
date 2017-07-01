module OS.View exposing (view)

import OS.Models exposing (..)
import OS.Messages exposing (..)
import OS.Style as Css
import Html exposing (..)
import Html.CssHelpers
import Core.Models as Core
import Game.Data as GameData
import OS.Header.View as Header
import OS.Menu.View exposing (menuView, menuEmpty)
import OS.SessionManager.View as SessionManager


{ id, class, classList } =
    Html.CssHelpers.withNamespace "os"


view : GameData.Data -> Core.PlayModel -> Html Msg
view data model =
    div
        [ id Css.Dashboard
        , menuEmpty
        ]
        [ viewHeader data model.os
        , viewMain data model.os
        , displayVersion model.game.config.version
        , menuView model.os
        ]


viewHeader : GameData.Data -> Model -> Html Msg
viewHeader game model =
    header []
        [ (Header.view game model.header) ]
        |> Html.map HeaderMsg


viewMain : GameData.Data -> Model -> Html Msg
viewMain game model =
    model.session
        |> SessionManager.view game
        |> Html.map SessionManagerMsg


displayVersion : String -> Html Msg
displayVersion version =
    div [ id Css.DesktopVersion ]
        [ text version ]
