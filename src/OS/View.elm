module OS.View exposing (view)

import Html exposing (Html, div, text)
import Html.Lazy exposing (lazy)
import Html.CssHelpers
import Game.Data as Game
import Game.Models as Game
import OS.Models exposing (Model)
import OS.Messages exposing (Msg(..))
import OS.Resources as Res
import OS.DynamicStyle as DynamicStyle
import OS.Header.View as Header
import OS.Header.Models as Header
import OS.Menu.View exposing (menuView, menuEmpty)
import OS.SessionManager.View as SessionManager
import OS.Toasts.View as Toasts


{ id, class, classList } =
    Html.CssHelpers.withNamespace Res.prefix


view : Game.Data -> Model -> Html Msg
view data model =
    let
        osContent =
            viewOS data model

        dynStyle =
            viewDynStyle data.game
    in
        div
            [ id Res.Dashboard
            , menuEmpty
            ]
            (osContent ++ dynStyle)


viewDynStyle : Game.Model -> List (Html Msg)
viewDynStyle { story } =
    if story.enabled then
        [ lazy DynamicStyle.view story.missions ]
    else
        []


viewOS : Game.Data -> Model -> List (Html Msg)
viewOS data model =
    [ viewHeader
        data
        model.header
    , viewMain data model
    , toasts data model
    , lazy displayVersion
        data.game.config.version
    , menuView model
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


toasts : Game.Data -> Model -> Html Msg
toasts data model =
    model.toasts
        |> Toasts.view data
        |> Html.map ToastsMsg
