module OS.Header.View exposing (view)

import Dict
import Html exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Utils.Html exposing (spacer)
import OS.Style as Css
import OS.Header.Messages exposing (..)
import OS.Header.Models exposing (..)
import Game.Models as Game
import Game.Meta.Models exposing (Context(..))
import UI.Widgets.CustomSelect exposing (customSelect)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "os"


view : Game.Model -> Model -> Html Msg
view game model =
    div [ class [ Css.Header ] ]
        [ customSelect
            ( MouseEnterItem, MouseLeaveItem )
            (ToggleMenus OpenGateway)
            SelectGateway
            1
            (Dict.fromList
                [ ( 0, text "::1" )
                , ( 1, text "::2" )
                , ( 2, text "::3" )
                ]
            )
            (model.openMenu == OpenGateway)
        , contextToggler (game.meta.context == Gateway) (ContextTo Gateway)
        , spacer
        , div []
            [ text "Bounce: "
            , customSelect
                ( MouseEnterItem, MouseLeaveItem )
                (ToggleMenus OpenBounce)
                SelectBounce
                0
                (Dict.fromList
                    [ ( 0, text "TODO 1" )
                    , ( 1, text "TODO 2" )
                    , ( 2, text "TODO 3" )
                    ]
                )
                (model.openMenu == OpenBounce)
            ]
        , spacer
        , contextToggler (game.meta.context == Endpoint) (ContextTo Endpoint)
        , customSelect
            ( MouseEnterItem, MouseLeaveItem )
            (ToggleMenus OpenEndpoint)
            SelectEndpoint
            0
            Dict.empty
            (model.openMenu == OpenEndpoint)
        , button
            [ onClick Logout
            ]
            [ text "logout" ]
        ]


contextToggler : Bool -> Msg -> Html Msg
contextToggler active handler =
    span
        [ onClick handler ]
        [ text <|
            if active then
                "X"
            else
                "O"
        ]
