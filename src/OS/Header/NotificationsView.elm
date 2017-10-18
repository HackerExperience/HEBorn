module OS.Header.NotificationsView exposing (view)

import Dict
import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Utils.Html exposing (spacer)
import Game.Notifications.Models as Notifications exposing (Content(..))
import OS.Header.Models exposing (..)
import OS.Header.Messages exposing (..)
import OS.Resources exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view :
    OpenMenu
    -> OpenMenu
    -> Class
    -> String
    -> Msg
    -> Notifications.Model
    -> Html Msg
view current activator uniqueClass title readAll itens =
    if (current == activator) then
        visibleNotifications uniqueClass activator title readAll itens
    else
        emptyNotifications uniqueClass activator



-- internals


emptyNotifications : Class -> OpenMenu -> Html Msg
emptyNotifications uniqueClass activator =
    indicator
        [ class [ Notification, uniqueClass ]
        , onClick <| ToggleMenus activator
        ]
        []


visibleNotifications :
    Class
    -> OpenMenu
    -> String
    -> Msg
    -> Notifications.Model
    -> Html Msg
visibleNotifications uniqueClass activator title readAll itens =
    let
        firstItem =
            li []
                [ div [] [ text (title ++ " notifications") ]
                , spacer
                , div [ onClick readAll ] [ text "Mark All as Read" ]
                ]

        lastItem =
            li [] [ text "..." ]

        itens_ =
            itens
                |> Dict.foldl
                    (\id { content } acu ->
                        renderContent content
                            |> notification id
                            |> flip (::) acu
                    )
                    []

        contents =
            (firstItem :: (itens_ ++ [ lastItem ]))
                |> ul []
                |> List.singleton
                |> div
                    [ onMouseEnter MouseEnterDropdown
                    , onMouseLeave MouseLeavesDropdown
                    ]
                |> List.singleton

        attrs =
            [ class [ Notification, uniqueClass ]
            ]
    in
        indicator attrs contents


indicator : List (Attribute a) -> List (Html a) -> Html a
indicator =
    node indicatorNode


renderContent : Content -> ( String, String )
renderContent content =
    case content of
        Simple title body ->
            ( title, body )

        NewEmail from body ->
            ( "New email from: " ++ from, body )

        DownloadStarted ->
            ( "New download started", "Check your task manager" )


notification : Notifications.ID -> ( String, String ) -> Html Msg
notification id ( title, body ) =
    li []
        [ text title
        , br [] []
        , text body
        ]
