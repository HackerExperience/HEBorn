module OS.WindowManager.Dock.View exposing (view)

import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (title, attribute)
import Html.Events exposing (onClick)
import Html.CssHelpers
import Utils.Html.Attributes exposing (..)
import Apps.Shared as Apps
import Game.Meta.Types.Apps.Desktop as DesktopApp exposing (DesktopApp)
import OS.Resources as OsRes
import Game.Servers.Models as Servers
import OS.WindowManager.Models exposing (..)
import OS.WindowManager.Shared exposing (..)
import OS.WindowManager.Dock.Config exposing (..)
import OS.WindowManager.Dock.Resources as Res


-- we're taking liberties concerning leaking implementation
-- details here to keep the codebase simple


type alias AppName =
    String


type alias WindowTitle =
    String


type alias WindowGroups =
    ( WindowGroup, WindowGroup )


type alias WindowGroup =
    Dict AppName (List ( WindowId, Window ))


view : Config msg -> Model -> Bool -> Session -> Html msg
view config model isFreeplay session =
    let
        groups =
            group config model isFreeplay session

        icons =
            config.accountDock
                |> List.foldl (viewIcons config model isFreeplay groups) []
                |> List.reverse
                |> div [ class [ Res.Main ] ]

        dock =
            div [ class [ Res.Container ] ]
                [ div [ class [ Res.Main ] ] [ icons ] ]
    in
        div [ osClass [ OsRes.Dock ] ]
            [ dock ]



-- internals


{ id, class, classList } =
    Html.CssHelpers.withNamespace Res.prefix


osClass : List class -> Attribute msg
osClass =
    .class <| Html.CssHelpers.withNamespace OsRes.prefix


viewIcons :
    Config msg
    -> Model
    -> Bool
    -> WindowGroups
    -> DesktopApp
    -> List (Html msg)
    -> List (Html msg)
viewIcons config model isFreeplay groupedWindows app list =
    let
        icon =
            viewIcon config app

        isNotEmpty =
            hasWindowOpened app groupedWindows

        content =
            if isNotEmpty then
                [ icon, options config model app groupedWindows ]
            else
                [ icon ]

        result =
            div
                [ class [ Res.Item ]
                , appAttr <| Apps.name app
                , boolAttr Res.appHasInstanceAttrTag isNotEmpty
                ]
                content
    in
        result :: list


viewIcon : Config msg -> DesktopApp -> Html msg
viewIcon config app =
    div
        [ class [ Res.ItemIco ]
        , onClick (config.onClickIcon app)
        , attribute Res.appIconAttrTag (Apps.icon app)
        , title (Apps.name app)
        ]
        []


options : Config msg -> Model -> DesktopApp -> WindowGroups -> Html msg
options config model app ( visible, hidden ) =
    let
        appName =
            Apps.name app

        visible_ =
            visible
                |> Dict.get appName
                |> Maybe.withDefault []
                |> windowList config.onRestoreWindow model "OPEN WINDOWS"

        hidden_ =
            hidden
                |> Dict.get appName
                |> Maybe.withDefault []
                |> windowList config.onRestoreWindow model "HIDDEN LINUXES"

        batchActions =
            [ subMenuAction "New window" (config.onNewApp app)
            , subMenuAction "Minimize all" (config.onMinimizeAll app)
            , subMenuAction "Close all" (config.onCloseAll app)
            ]

        menu_ =
            batchActions
                |> (++) hidden_
                |> (::) (hr [] [])
                |> (++) visible_
    in
        div [ class [ Res.AppContext ] ]
            [ ul [] menu_ ]


subMenuAction : String -> msg -> Html msg
subMenuAction label event =
    li
        [ class [ Res.ClickableWindow ], onClick event ]
        [ text label ]


windowList :
    (WindowId -> msg)
    -> Model
    -> String
    -> List ( WindowId, Window )
    -> List (Html msg)
windowList onClick model label list =
    let
        titleAndId ( windowId, window ) =
            case getWindowTitle model window of
                Just appModel ->
                    appModel ++ windowId

                Nothing ->
                    windowId
    in
        list
            |> List.sortBy titleAndId
            |> List.indexedMap (listItem onClick model)
            |> (::) (hr [] [])
            |> (::) (li [] [ text label ])


listItem : (WindowId -> msg) -> Model -> Int -> ( String, Window ) -> Html msg
listItem event model index ( windowId, window ) =
    li
        [ class [ Res.ClickableWindow ]
        , idAttr (toString index)
        , onClick (event windowId)
        ]
        [ (windowLabel model index window) ]


windowLabel : Model -> Int -> Window -> Html msg
windowLabel model index window =
    case getWindowTitle model window of
        Just title ->
            text (toString index ++ " : " ++ title)

        Nothing ->
            text "Untitled window."



-- helpers


getWindowTitle : Model -> Window -> Maybe WindowTitle
getWindowTitle model window =
    model
        |> getApp (getActiveAppId window)
        |> Maybe.map (getModel >> getTitle)


group : Config msg -> Model -> Bool -> Session -> WindowGroups
group =
    let
        shouldInsert config model isFreeplay windowId =
            model
                |> getSessionOfWindow windowId
                |> Maybe.andThen (flip Servers.get config.servers)
                |> Maybe.map (Servers.isFreeplay >> (==) isFreeplay)
                |> Maybe.withDefault False

        getWindowAppName model window =
            window
                |> getActiveAppId
                |> (flip getApp model)
                |> Maybe.map (getModel >> toDesktopApp >> Apps.name)

        reducer config model isFreeplay windowId dict =
            if shouldInsert config model isFreeplay windowId then
                case getWindow windowId model of
                    Just window ->
                        case getWindowAppName model window of
                            Just appName ->
                                dict
                                    |> Dict.get appName
                                    |> Maybe.withDefault []
                                    |> (::) ( windowId, window )
                                    |> flip (Dict.insert appName) dict

                            Nothing ->
                                dict

                    Nothing ->
                        dict
            else
                dict
    in
        \config model isFreeplay { visible, hidden } ->
            let
                reducer_ =
                    reducer config model isFreeplay
            in
                ( List.foldl reducer_ Dict.empty visible
                , List.foldl reducer_ Dict.empty hidden
                )


hasWindowOpened : DesktopApp -> WindowGroups -> Bool
hasWindowOpened app ( hidden, visible ) =
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
    in
        hidden_ || visible_
