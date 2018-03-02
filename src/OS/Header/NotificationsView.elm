module OS.Header.NotificationsView exposing (view, notifications)

import Dict
import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Utils.Html exposing (spacer)
import Game.Meta.Types.Notifications as Notifications
import OS.Header.Models exposing (..)
import OS.Header.Messages exposing (..)
import OS.Header.Resources exposing (..)


type alias Renderer a =
    a -> ( String, String )


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view :
    Renderer a
    -> OpenMenu
    -> OpenMenu
    -> Class
    -> String
    -> Msg
    -> Notifications.Notifications a
    -> Html Msg
view render current activator uniqueClass title readAllMsg itens =
    if (current == activator) then
        visibleNotifications
            render
            title
            readAllMsg
            itens
            uniqueClass
    else
        emptyNotifications uniqueClass activator



-- internals


emptyNotifications : Class -> OpenMenu -> Html Msg
emptyNotifications uniqueClass activator =
    indicator
        [ class [ uniqueClass ]
        , onClick <| ToggleMenus activator
        , onMouseEnter MouseEnterDropdown
        , onMouseLeave MouseLeavesDropdown
        ]
        []


visibleNotifications :
    Renderer a
    -> String
    -> Msg
    -> Notifications.Notifications a
    -> Class
    -> Html Msg
visibleNotifications render title readAllMsg itens uniqueClass =
    notifications render title readAllMsg itens
        |> List.singleton
        |> indicator
            [ class [ uniqueClass ]
            , onMouseEnter MouseEnterDropdown
            , onMouseLeave MouseLeavesDropdown
            ]


{-| Gen a div with an ul with an header, all notifications and a footer
-}
notifications :
    Renderer a
    -> String
    -> Msg
    -> Notifications.Notifications a
    -> Html Msg
notifications render title readAllMsg itens =
    footer
        |> List.singleton
        |> (++) (Dict.foldl (notificationReduce render) [] itens)
        |> (::) (header title readAllMsg)
        |> ul []
        |> List.singleton
        |> div [ class [ Notification ] ]


indicator : List (Attribute a) -> List (Html a) -> Html a
indicator =
    node indicatorNode


header : String -> Msg -> Html Msg
header title readAllMsg =
    li []
        [ div [] [ text (title ++ " notifications") ]
        , spacer
        , div [ onClick readAllMsg ] [ text "Mark All as Read" ]
        ]


footer : Html Msg
footer =
    li [] [ text "..." ]


notificationReduce :
    Renderer a
    -> Notifications.Id
    -> Notifications.Notification a
    -> List (Html Msg)
    -> List (Html Msg)
notificationReduce renderer id { content } acu =
    renderer content
        |> notification id
        |> flip (::) acu


notification : Notifications.Id -> ( String, String ) -> Html Msg
notification id ( title, body ) =
    li []
        [ text title
        , br [] []
        , text body
        ]
