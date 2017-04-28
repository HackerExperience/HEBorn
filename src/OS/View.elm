module OS.View exposing (view)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.CssHelpers
import Router.Router exposing (Route(..))
import Core.Models exposing (CoreModel)
import Core.Messages exposing (CoreMsg(..))
import OS.Style as Css
import OS.WindowManager.View
import OS.Header.View
import OS.Dock.View
import OS.Context.View exposing (contextView, contextEmpty)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "os"


view : CoreModel -> Html CoreMsg
view model =
    case model.route of
        RouteNotFound ->
            viewNotFound

        _ ->
            viewDashboard model


viewDashboard : CoreModel -> Html CoreMsg
viewDashboard model =
    div
        [ id Css.Dashboard
        , contextEmpty
        ]
        [ viewHeader model
        , viewMain model
        , viewFooter model
        , contextView model.os
        ]


viewHeader : CoreModel -> Html CoreMsg
viewHeader model =
    header []
        [ (OS.Header.View.view model) ]


viewMain : CoreModel -> Html CoreMsg
viewMain model =
    main_ [] (OS.WindowManager.View.renderWindows model)


viewFooter : CoreModel -> Html CoreMsg
viewFooter model =
    footer []
        [ OS.Dock.View.view model
        , displayVersion model.config.version
        ]


displayVersion : String -> Html CoreMsg
displayVersion version =
    div [ id Css.DesktopVersion ]
        [ text version ]


viewNotFound : Html CoreMsg
viewNotFound =
    div []
        [ text "Not found"
        ]
