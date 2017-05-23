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
import Apps.Browser.Menu.Models exposing (Menu(..))
import Apps.Browser.Menu.View exposing (menuView, menuNav, menuContent)
import Apps.Browser.Style exposing (Classes(..))
import Utils exposing (onKeyDown)


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
            [ viewBrowserMain id browser
            , menuView model id
            ]


viewToolbar : InstanceID -> Browser -> Html Msg
viewToolbar instanceID browser =
    div [ class [ Toolbar ] ]
        [ div
            [ class
                (if (List.length browser.previousPages) > 0 then
                    []
                 else
                    []
                )
            , onClick (GoPrevious instanceID)
            ]
            [ text "<" ]
        , div
            [ class
                (if (List.length browser.nextPages) > 0 then
                    []
                 else
                    []
                )
            , onClick (GoNext instanceID)
            ]
            [ text ">" ]
        , div
            [ class
                (if (String.length browser.addressBar) > 0 then
                    []
                 else
                    []
                )
            ]
            [ text "%" ]
        , div
            [ class [ AddressBar ] ]
            [ input
                [ value browser.addressBar
                , onInput (UpdateAddress instanceID)
                , Utils.onKeyDown (AddressKeyDown instanceID)
                ]
                []
            ]
        ]


viewStaticContent : Html Msg
viewStaticContent =
    div [ class [ PageContent ] ]
        [ div [ class [ LoginPageHeader ] ] [ text "No web server running" ]
        , div [ class [ LoginPageForm ] ] [ div [] [ input [ placeholder "Password" ] [], text "E" ] ]
        , div [ class [ LoginPageFooter ] ]
            [ div []
                [ text "C"
                , br [] []
                , text "Crack"
                ]
            , div []
                [ text "M"
                , br [] []
                , text "AnyMap"
                ]
            ]
        ]


viewBrowserMain : InstanceID -> Browser -> Html Msg
viewBrowserMain instanceID browser =
    div
        [ menuContent
        , class
            [ Content, Client ]
        ]
        [ viewToolbar instanceID browser
        , viewStaticContent
        ]
