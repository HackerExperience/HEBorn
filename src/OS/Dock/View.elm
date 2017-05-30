module OS.Dock.View exposing (view)

import Html exposing (Html, div, text, button, ul, li, hr)
import Html.Events exposing (onClick)
import Html.Attributes exposing (attribute)
import Html.CssHelpers
import Core.Messages exposing (CoreMsg(..))
import Core.Models exposing (CoreModel)
import OS.Messages exposing (OSMsg(..))
import OS.WindowManager.Messages exposing (Msg(..))
import OS.WindowManager.Models exposing (getWindow, WindowID)
import OS.WindowManager.View exposing (windowTitle)
import OS.Dock.Style as Css
import Apps.Models as Apps
import OS.Dock.Models
    exposing
        ( Application
        , getApplications
        )


{ id, class, classList } =
    Html.CssHelpers.withNamespace "dock"


view : CoreModel -> Html CoreMsg
view model =
    renderApplications model


renderApplications : CoreModel -> Html CoreMsg
renderApplications model =
    let
        applications =
            getApplications model.os.dock

        html =
            List.foldr (\app acc -> [ renderApplication model app ] ++ acc) [] applications
    in
        div [ id Css.DockContainer ]
            [ div
                [ id Css.DockMain ]
                html
            ]


hasInstanceString : Int -> String
hasInstanceString num =
    if (num > 0) then
        "Y"
    else
        "N"


andThenWithDefault : (a -> b) -> b -> Maybe a -> b
andThenWithDefault callback default maybe =
    case maybe of
        Just value ->
            callback value

        Nothing ->
            default


filteredTile : Int -> WindowID -> CoreModel -> String
filteredTile i windowID model =
    (toString i)
        ++ ": "
        ++ (andThenWithDefault
                windowTitle
                "404"
                (getWindow windowID model.os.wm)
           )


renderApplicationSubmenu : CoreModel -> Application -> Html CoreMsg
renderApplicationSubmenu model application =
    div
        [ class [ Css.DockAppContext ]
        , onClick (MsgOS OS.Messages.NoOp)
        ]
        [ ul []
            ([ li [] [ text "OPEN WINDOWS" ] ]
                ++ (List.indexedMap
                        (\i windowID ->
                            li
                                [ class [ Css.ClickableWindow ]
                                , attribute "data-id" windowID
                                , onClick (MsgOS (MsgWM (UpdateFocusTo (Just windowID))))
                                ]
                                [ text (filteredTile i windowID model) ]
                        )
                        application.openWindows
                   )
                ++ [ hr [] []
                   , li [] [ text "MINIMIZED LINUXES" ]
                   ]
                ++ (List.indexedMap
                        (\i windowID ->
                            li
                                [ class [ Css.ClickableWindow ]
                                , attribute "data-id" windowID
                                , onClick (MsgOS (MsgWM (Restore windowID)))
                                ]
                                [ text (filteredTile i windowID model) ]
                        )
                        application.minimizedWindows
                   )
                ++ [ hr [] []
                   , li
                        [ class [ Css.ClickableWindow ]
                        , onClick (MsgOS (MsgWM (Open application.app)))
                        ]
                        [ text "New window" ]
                   , li
                        [ class [ Css.ClickableWindow ]
                        , onClick (MsgOS (MsgWM (MinimizeAll application.app)))
                        ]
                        [ text "Minimize all" ]
                   , li
                        [ class [ Css.ClickableWindow ]
                        , onClick (MsgOS (MsgWM (CloseAll application.app)))
                        ]
                        [ text "Close all" ]
                   ]
            )
        ]


renderApplication : CoreModel -> Application -> Html CoreMsg
renderApplication model application =
    div
        [ class [ Css.Item ]
        , attribute "data-hasinst" (hasInstanceString application.instancesNum)
        ]
        ([ div
            [ class [ Css.ItemIco ]
            , onClick (MsgOS (MsgWM (OpenOrRestore application.app)))
            , attribute "data-icon" (Apps.icon application.app)
            ]
            []
         ]
            ++ (if application.instancesNum > 0 then
                    [ renderApplicationSubmenu model application ]
                else
                    []
               )
        )
