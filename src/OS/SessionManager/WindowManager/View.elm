module OS.SessionManager.WindowManager.View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes as Attributes exposing (style, attribute)
import Html.Events exposing (onMouseDown)
import Html.CssHelpers
import Html.Keyed
import Css exposing (left, top, asPairs, px, height, width, int, zIndex)
import Draggable
import Utils.Html.Attributes exposing (decoratedAttr, appAttr, iconAttr, activeContextAttr)
import Utils.Html.Events exposing (onClickMe, onKeyDown)
import Apps.Models as Apps
import Apps.View as Apps
import Game.Data as Game
import Game.Meta.Types exposing (..)
import OS.SessionManager.WindowManager.Messages exposing (..)
import OS.SessionManager.WindowManager.Models exposing (..)
import OS.SessionManager.WindowManager.Resources as Res


{ id, class, classList } =
    Html.CssHelpers.withNamespace Res.prefix


view : Game.Data -> Model -> Html Msg
view data ({ windows, visible } as model) =
    let
        mapper id =
            case Dict.get id windows of
                Just window ->
                    window
                        |> getAppModelFromWindow
                        |> Apps.view (windowData data Nothing id window model)
                        |> Html.map (AppMsg Active id)
                        |> windowWrapper id window
                        |> (,) id
                        |> Just

                Nothing ->
                    Nothing
    in
        Html.Keyed.node Res.workspaceNode
            [ class [ Res.Super ] ]
            (List.filterMap mapper visible)


styles : List Css.Style -> Attribute Msg
styles =
    Css.asPairs >> style


windowClasses : Window -> Attribute Msg
windowClasses window =
    if (window.maximized) then
        class
            [ Res.Window
            , Res.Maximizeme
            ]
    else
        class [ Res.Window ]


windowWrapper : ID -> Window -> Html Msg -> Html Msg
windowWrapper id window view =
    let
        windowStaticAttrs =
            [ windowClasses window
            , windowStyle window
            , decoratedAttr <| isDecorated window
            , appAttr window.app
            , activeContextAttr <| windowContext window
            , onMouseDown (UpdateFocusTo (Just id))
            ]

        windowKeyDownListener =
            Apps.keyLogger window.app

        windowAttrs =
            case windowKeyDownListener of
                Just msg ->
                    msg
                        >> AppMsg Active id
                        |> onKeyDown
                        |> flip (::) windowStaticAttrs

                Nothing ->
                    windowStaticAttrs
    in
        div
            windowAttrs
            [ header id window
            , div
                [ class [ Res.WindowBody ] ]
                [ view ]
            ]


isDecorated : Window -> Bool
isDecorated window =
    window
        |> .app
        |> Apps.isDecorated


header : ID -> Window -> Html Msg
header id window =
    let
        windowBody =
            if (isDecorated window) then
                [ headerTitle (title window) (Apps.icon window.app)
                , headerContext id <| realContext window
                , headerButtons id
                ]
            else
                []
    in
        div
            [ Draggable.mouseTrigger id DragMsg
            , class [ Res.HeaderSuper ]
            ]
            [ div
                [ class [ Res.WindowHeader ]
                , onMouseDown (UpdateFocusTo (Just id))
                ]
                windowBody
            ]


headerContext : ID -> Maybe Context -> Html Msg
headerContext id context =
    div [] <|
        case context of
            Just context ->
                [ span
                    [ class [ Res.HeaderContextSw ]
                    , onClickMe <|
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


headerTitle : String -> String -> Html Msg
headerTitle title icon =
    div
        [ class [ Res.HeaderTitle ]
        , iconAttr icon
        ]
        [ text title ]


headerButtons : ID -> Html Msg
headerButtons id =
    div [ class [ Res.HeaderButtons ] ]
        [ span
            [ class [ Res.HeaderButton, Res.HeaderBtnMinimize ]
            , onClickMe (Minimize id)
            ]
            []
        , span
            [ class [ Res.HeaderButton, Res.HeaderBtnMaximize ]
            , onClickMe (ToggleMaximize id)
            ]
            []
        , span
            [ class [ Res.HeaderButton, Res.HeaderBtnClose ]
            , onClickMe (Close id)
            ]
            []
        ]


windowStyle : Window -> Html.Attribute Msg
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
