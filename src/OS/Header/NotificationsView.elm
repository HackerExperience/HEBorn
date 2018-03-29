module OS.Header.NotificationsView exposing (view, notifications)

import Dict
import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Utils.Html exposing (spacer)
import Game.Meta.Types.Notifications as Notifications
import OS.Header.Config exposing (..)
import OS.Header.Models exposing (..)
import OS.Header.Messages exposing (..)
import OS.Header.Resources exposing (..)


type alias Renderer a =
    a -> ( String, String )


type alias Actioner a msg =
    a -> msg


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view :
    Config msg
    -> Renderer a
    -> Actioner a msg
    -> OpenMenu
    -> OpenMenu
    -> Class
    -> String
    -> msg
    -> Notifications.Notifications a
    -> Html msg
view config render actioner current activator uniqueClass title readAllMsg itens =
    if (current == activator) then
        visibleNotifications config
            render
            actioner
            title
            readAllMsg
            itens
            uniqueClass
    else
        emptyNotifications config uniqueClass activator



-- internals


emptyNotifications : Config msg -> Class -> OpenMenu -> Html msg
emptyNotifications { toMsg } uniqueClass activator =
    indicator
        [ class [ uniqueClass ]
        , onClick <| toMsg <| ToggleMenus activator
        , onMouseEnter <| toMsg <| MouseEnterDropdown
        , onMouseLeave <| toMsg MouseLeavesDropdown
        ]
        []


visibleNotifications :
    Config msg
    -> Renderer a
    -> Actioner a msg
    -> String
    -> msg
    -> Notifications.Notifications a
    -> Class
    -> Html msg
visibleNotifications config render actioner title readAllMsg itens uniqueClass =
    itens
        |> notifications config render actioner title readAllMsg
        |> List.singleton
        |> indicator
            [ class [ uniqueClass ]
            , onMouseEnter <| config.toMsg MouseEnterDropdown
            , onMouseLeave <| config.toMsg MouseLeavesDropdown
            ]


{-| Gen a div with an ul with an header, all notifications and a footer
-}
notifications :
    Config msg
    -> Renderer a
    -> Actioner a msg
    -> String
    -> msg
    -> Notifications.Notifications a
    -> Html msg
notifications config render actioner title readAllMsg itens =
    footer
        |> List.singleton
        |> (++)
            (Dict.foldl
                (notificationReduce config render actioner)
                []
                itens
            )
        |> (::) (header title readAllMsg)
        |> ul []
        |> List.singleton
        |> div [ class [ Notification ] ]


indicator : List (Attribute a) -> List (Html a) -> Html a
indicator =
    node indicatorNode


header : String -> msg -> Html msg
header title readAllMsg =
    li []
        [ div [] [ text (title ++ " notifications") ]
        , spacer
        , div [ onClick readAllMsg ] [ text "Mark All as Read" ]
        ]


footer : Html msg
footer =
    li [] [ text "..." ]


notificationReduce :
    Config msg
    -> Renderer a
    -> Actioner a msg
    -> Notifications.Id
    -> Notifications.Notification a
    -> List (Html msg)
    -> List (Html msg)
notificationReduce config renderer actioner id { content } acu =
    renderer content
        |> notification (actioner content) id
        |> flip (::) acu


notification : msg -> Notifications.Id -> ( String, String ) -> Html msg
notification clickMsg id ( title, body ) =
    li [ onClick clickMsg ]
        [ text title
        , br [] []
        , text body
        ]
