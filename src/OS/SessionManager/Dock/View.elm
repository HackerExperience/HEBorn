module OS.SessionManager.Dock.View exposing (view)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (title)
import Utils.Html.Attributes exposing (..)
import Html.CssHelpers
import OS.Resources as OsRes
import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Helpers exposing (..)
import OS.SessionManager.Dock.Messages exposing (..)
import OS.SessionManager.Dock.Resources as Res
import OS.SessionManager.WindowManager.Models as WM
import Apps.Models as Apps
import Apps.Apps as Apps
import Game.Data as GameData


-- this module still needs a refactor to make its code more maintainable


{ id, class, classList } =
    Html.CssHelpers.withNamespace Res.prefix


osClass : List class -> Attribute msg
osClass =
    .class <| Html.CssHelpers.withNamespace OsRes.prefix


view : GameData.Data -> Model -> Html Msg
view game model =
    div [ osClass [ OsRes.Dock ] ]
        [ dock game model ]



-- internals


dock : GameData.Data -> Model -> Html Msg
dock data ({ sessions } as model) =
    let
        id =
            toSessionID data

        wm =
            sessions
                |> Dict.get id
                |> Maybe.withDefault WM.initialModel

        content =
            icons data.game.account.dock wm
    in
        div [ class [ Res.Container ] ]
            [ div [ class [ Res.Main ] ] [ content ] ]


icons : List Apps.App -> WM.Model -> Html Msg
icons apps wm =
    let
        group =
            WM.group wm

        reducer app acc =
            let
                isNotEmpty =
                    hasAppOpened app group

                item =
                    icon app group wm

                content =
                    if isNotEmpty then
                        let
                            menu =
                                options app group
                        in
                            [ item, menu ]
                    else
                        [ item ]

                result =
                    div
                        [ class [ Res.Item ]
                        , hasInstance isNotEmpty
                        ]
                        content
            in
                result :: acc

        content =
            apps
                |> List.foldl reducer []
                |> List.reverse
    in
        div [ class [ Res.Main ] ] content


icon : Apps.App -> WM.GroupedWindows -> WM.Model -> Html Msg
icon app group wm =
    div
        [ class [ Res.ItemIco ]
        , onClick (AppButton app)
        , iconAttr (Apps.icon app)
        , title (Apps.name app)
        ]
        []


options : Apps.App -> WM.GroupedWindows -> Html Msg
options app { visible, hidden } =
    let
        appName =
            Apps.name app

        separator =
            hr [] []

        defaultToEmptyList =
            Maybe.withDefault []

        visible_ =
            visible
                |> Dict.get appName
                |> defaultToEmptyList
                |> windowList FocusWindow "OPEN WINDOWS"

        hidden_ =
            hidden
                |> Dict.get appName
                |> defaultToEmptyList
                |> windowList RestoreWindow "HIDDEN LINUXES"

        batchActions =
            [ subMenuAction "New window" (OpenApp app)
            , subMenuAction "Minimize all" (MinimizeApps app)
            , subMenuAction "Close all" (CloseApps app)
            ]

        menu_ =
            batchActions
                |> (++) hidden_
                |> (::) separator
                |> (++) visible_
    in
        div [ class [ Res.AppContext ] ]
            [ ul [] menu_ ]


hasAppOpened : Apps.App -> WM.GroupedWindows -> Bool
hasAppOpened app { hidden, visible } =
    let
        name =
            Apps.name app

        notEmpty =
            List.isEmpty >> (not)

        hidden_ =
            hidden
                |> Dict.get name
                |> Maybe.map notEmpty
                |> Maybe.withDefault False

        visible_ =
            visible
                |> Dict.get name
                |> Maybe.map notEmpty
                |> Maybe.withDefault False

        result =
            hidden_ || visible_
    in
        result


subMenuAction : String -> msg -> Html msg
subMenuAction label event =
    li
        [ class [ Res.ClickableWindow ], onClick event ]
        [ text label ]


windowList :
    (String -> Msg)
    -> String
    -> List ( String, WM.Window )
    -> List (Html Msg)
windowList event label list =
    let
        titleAndID ( id, window ) =
            (WM.title window) ++ id
    in
        list
            |> List.sortBy titleAndID
            |> List.indexedMap (listItem event)
            |> (::) (hr [] [])
            |> (::) (li [] [ text label ])


listItem : (String -> Msg) -> Int -> ( String, WM.Window ) -> Html Msg
listItem event index ( id, window ) =
    li
        [ class [ Res.ClickableWindow ]
        , idAttr (toString index)
        , onClick (event id)
        ]
        [ (windowLabel index window) ]


windowLabel : Int -> WM.Window -> Html Msg
windowLabel index window =
    let
        andThen =
            flip (++)
    in
        index
            |> toString
            |> andThen ": "
            |> andThen (WM.title window)
            |> text
