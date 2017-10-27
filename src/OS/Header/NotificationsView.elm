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


{-| Gen a div with an ul with an header, all notifications and a footer
-}
visibleNotifications :
    Class
    -> OpenMenu
    -> String
    -> Msg
    -> Notifications.Model
    -> Html Msg
visibleNotifications uniqueClass activator title readAll itens =
    footer
        |> List.singleton
        |> (++) (Dict.foldl notificationReduce [] itens)
        |> (::) (header title readAll)
        |> ul []
        |> List.singleton
        |> div
            [ onMouseEnter MouseEnterDropdown
            , onMouseLeave MouseLeavesDropdown
            ]
        |> List.singleton
        |> indicator [ class [ Notification, uniqueClass ] ]


indicator : List (Attribute a) -> List (Html a) -> Html a
indicator =
    node indicatorNode


header : String -> Msg -> Html Msg
header title readAll =
    li []
        [ div [] [ text (title ++ " notifications") ]
        , spacer
        , div [ onClick readAll ] [ text "Mark All as Read" ]
        ]


footer : Html Msg
footer =
    li [] [ text "..." ]


notificationReduce :
    Notifications.ID
    -> Notifications.Notification
    -> List (Html Msg)
    -> List (Html Msg)
notificationReduce id { content } acu =
    renderContent content
        |> notification id
        |> flip (::) acu


renderContent : Content -> ( String, String )
renderContent content =
    case content of
        Simple title body ->
            ( title, body )

        NewEmail from body ->
            ( "New email from: " ++ from, body )

        DownloadStarted origin file ->
            ( "New download started"
            , (file.name ++ " download started!")
            )


notification : Notifications.ID -> ( String, String ) -> Html Msg
notification id ( title, body ) =
    li []
        [ text title
        , br [] []
        , text body
        ]
