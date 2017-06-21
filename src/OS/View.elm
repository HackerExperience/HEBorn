module OS.View exposing (view)

import OS.Models exposing (..)
import OS.Messages exposing (..)
import OS.Style as Css
import Html exposing (..)
import Html.CssHelpers
import Core.Models as Core
import Core.Messages as Core
import Game.Models as Game
import OS.Header.View as Header
import OS.Menu.View exposing (menuView, menuEmpty)
import OS.SessionManager.View as SessionManager


-- this module should return OS.Msgs instead of Core.Msg, but let's deffer it


{ id, class, classList } =
    Html.CssHelpers.withNamespace "os"


view : Core.Model -> Html Core.Msg
view model =
    div
        [ id Css.Dashboard
        , menuEmpty
        ]
        [ viewHeader model.game model.os
        , viewMain model.game model.os
        , displayVersion model.game.meta.config.version
        , menuView model.os
        ]


viewHeader : Game.Model -> Model -> Html Core.Msg
viewHeader game model =
    header []
        [ (Header.view game model.header) ]


viewMain : Game.Model -> Model -> Html Core.Msg
viewMain game model =
    model.session
        |> SessionManager.view game
        |> Html.map SessionManagerMsg
        |> Html.map Core.OSMsg


displayVersion : String -> Html Core.Msg
displayVersion version =
    div [ id Css.DesktopVersion ]
        [ text version ]
