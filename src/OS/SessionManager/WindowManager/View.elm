module OS.SessionManager.WindowManager.View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes as Attributes exposing (style, attribute, tabindex)
import Html.Events exposing (onMouseDown)
import Html.CssHelpers
import Html.Keyed
import Css exposing (left, top, asPairs, px, height, width, int, zIndex)
import Draggable
import Utils.Html.Attributes exposing (appAttr, boolAttr, activeContextAttr)
import Utils.Html.Events exposing (onClickMe, onKeyDown)
import Apps.Models as Apps
import Apps.View as Apps
import Game.Meta.Types.Context exposing (..)
import OS.SessionManager.WindowManager.Config exposing (..)
import OS.SessionManager.WindowManager.Messages exposing (..)
import OS.SessionManager.WindowManager.Models exposing (..)
import OS.SessionManager.WindowManager.Resources as Res


{ id, class, classList } =
    Html.CssHelpers.withNamespace Res.prefix


view : Config msg -> Model -> Html msg
view config ({ windows, visible } as model) =
    let
        context window =
            Just (windowContext window)

        config_ id window =
            appsConfig (context window) id Active config

        mapper id =
            case Dict.get id windows of
                Just window ->
                    window
                        |> getAppModelFromWindow
                        |> Apps.view (config_ id window)
                        |> windowWrapper config id window
                        |> (,) id
                        |> Just

                Nothing ->
                    Nothing
    in
        Html.Keyed.node Res.workspaceNode
            [ class [ Res.Super ] ]
            (List.filterMap mapper visible)


styles : List Css.Style -> Attribute msg
styles =
    Css.asPairs >> style


windowClasses : Window -> Attribute msg
windowClasses window =
    if (window.maximized) then
        class
            [ Res.Window
            , Res.Maximizeme
            ]
    else
        class [ Res.Window ]


windowWrapper : Config msg -> ID -> Window -> Html msg -> Html msg
windowWrapper config id window view =
    let
        windowStaticAttrs =
            [ windowClasses window
            , windowStyle window
            , boolAttr Res.decoratedAttrTag <| isDecorated window
            , appAttr window.app
            , activeContextAttr <| windowContext window
            , onMouseDown ((UpdateFocusTo (Just id)) |> config.toMsg)
            ]

        windowKeyDownListener =
            Apps.keyLogger window.app

        windowAttrs =
            case windowKeyDownListener of
                Just msg ->
                    (msg >> AppMsg Active id >> config.toMsg)
                        |> onKeyDown
                        |> flip (::) windowStaticAttrs

                Nothing ->
                    windowStaticAttrs
    in
        div
            windowAttrs
            [ header config id window
            , div
                [ class [ Res.WindowBody ] ]
                [ view ]
            ]


isDecorated : Window -> Bool
isDecorated window =
    window
        |> .app
        |> Apps.isDecorated


isResizable : Window -> Bool
isResizable window =
    window
        |> .app
        |> Apps.isResizable


header : Config msg -> ID -> Window -> Html msg
header config id window =
    let
        windowBody =
            if (isDecorated window) then
                [ headerTitle config (title window) (Apps.icon window.app)
                , headerContext config id <| realContext window
                , headerButtons config id window
                ]
            else
                []
    in
        div
            [ Draggable.mouseTrigger id (DragMsg >> config.toMsg)
            , class [ Res.HeaderSuper ]
            ]
            [ div
                [ class [ Res.WindowHeader ]
                , (UpdateFocusTo (Just id))
                    |> config.toMsg
                    |> onMouseDown
                ]
                windowBody
            ]


headerContext : Config msg -> ID -> Maybe Context -> Html msg
headerContext config id context =
    div [] <|
        case context of
            Just context ->
                [ span
                    [ class [ Res.HeaderContextSw ]
                    , onClickMe <|
                        config.toMsg <|
                            SetContext id <|
                                case context of
                                    Gateway ->
                                        Endpoint

                                    Endpoint ->
                                        Gateway
                    ]
                    [ text <| contextToString context ]
                ]

            Nothing ->
                []


headerTitle : Config msg -> String -> String -> Html msg
headerTitle config title icon =
    div
        [ class [ Res.HeaderTitle ]
        , attribute Res.appIconAttrTag icon
        ]
        [ text title ]


headerButtons : Config msg -> ID -> Window -> Html msg
headerButtons config id window =
    let
        maximize =
            if (isResizable window) then
                span
                    [ class [ Res.HeaderButton, Res.HeaderBtnMaximize ]
                    , onClickMe <| config.toMsg (ToggleMaximize id)
                    ]
                    []
            else
                span [] [ text "" ]
    in
        div [ class [ Res.HeaderButtons ] ]
            [ span
                [ class [ Res.HeaderButton, Res.HeaderBtnMinimize ]
                , onClickMe <| config.toMsg (Minimize id)
                ]
                []
            , maximize
            , span
                [ class [ Res.HeaderButton, Res.HeaderBtnClose ]
                , onClickMe <| config.toMsg (Close id)
                ]
                []
            ]


windowStyle : Window -> Html.Attribute msg
windowStyle window =
    let
        position =
            [ left (px window.position.x)
            , top (px window.position.y)
            ]

        size =
            [ width (px window.size.width)
            , height (px window.size.height)
            ]

        attrs =
            if isDecorated window then
                position ++ size
            else
                position
    in
        styles attrs


contextToString : Context -> String
contextToString context =
    case context of
        Gateway ->
            "Gateway"

        Endpoint ->
            "Endpoint"
