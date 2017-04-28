module Apps.Browser.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Css exposing (pct, width, asPairs)
import Game.Models exposing (GameModel)
import Game.Servers.Filesystem.Models exposing (FilePath)
import Apps.Instances.Models as Instance exposing (InstanceID)
import Apps.Context as Context
import Apps.Browser.Messages exposing (Msg(..))
import Apps.Browser.Models exposing (Model, Browser, getState)
import Apps.Browser.Context.Models exposing (Context(..))
import Apps.Browser.Context.View exposing (contextView, contextNav, contextContent)
import Apps.Browser.Style exposing (Classes(..))


{ id, class, classList } =
    Html.CssHelpers.withNamespace "browser"


styles : List Css.Mixin -> Attribute Msg
styles =
    Css.asPairs >> style


view : Model -> InstanceID -> GameModel -> Html Msg
view model id game =
    let
        browser =
            getState model id
    in
        div [ class [ Window ] ]
            [ viewBrowserMain browser game
            , contextView model id
            ]


viewBrowserMain : Browser -> GameModel -> Html Msg
viewBrowserMain browser game =
    div
        [ contextContent
        , class
            [ Content ]
        ]
        []
