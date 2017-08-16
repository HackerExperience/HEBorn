module OS.View exposing (view)

import Html exposing (Html, div, text)
import Html.Lazy exposing (lazy)
import Html.CssHelpers
import Game.Data as Game
import OS.Models exposing (Model)
import OS.Messages exposing (Msg(HeaderMsg, SessionManagerMsg))
import OS.Resources as Res
import OS.DynamicStyle as DynamicStyle
import OS.Header.View as Header
import OS.Header.Models as Header
import OS.Menu.View exposing (menuView, menuEmpty)
import OS.SessionManager.View as SessionManager


{ id, class, classList } =
    Html.CssHelpers.withNamespace Res.prefix


view : Game.Data -> Model -> Html Msg
view data model =
    div
        [ id Res.Dashboard
        , menuEmpty
        ]
        [ viewHeader
            data
            model.header
        , viewMain data model
        , lazy displayVersion
            data.game.config.version
        , menuView model
        , lazy DynamicStyle.view
            data.game.story
        ]


viewHeader : Game.Data -> Header.Model -> Html Msg
viewHeader game header =
    Header.view game header
        |> Html.map HeaderMsg


viewMain : Game.Data -> Model -> Html Msg
viewMain game model =
    model.session
        |> SessionManager.view game
        |> Html.map SessionManagerMsg


displayVersion : String -> Html Msg
displayVersion version =
    div
        [ class [ Res.Version ] ]
        [ text version ]
