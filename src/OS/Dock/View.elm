module OS.Dock.View exposing (view)

import Html exposing (Html, div, text, button, ul, li, hr)
import Html.Events exposing (onClick)
import Html.Attributes exposing (attribute)
import Html.CssHelpers
import Core.Messages exposing (CoreMsg(..))
import Core.Models exposing (CoreModel)
import OS.Messages exposing (OSMsg(..))
import OS.WindowManager.Messages exposing (Msg(..))
import OS.Dock.Style as Css
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


renderApplication : CoreModel -> Application -> Html CoreMsg
renderApplication model application =
    div
        [ class [ Css.Item ]
        , attribute "data-hasinst" (hasInstanceString application.instancesNum)
        ]
        ([ div
            [ class [ Css.ItemIco ]
            , onClick (MsgOS (MsgWM (OpenOrRestore application.window)))
            , attribute "data-icon" application.icon
            ]
            []
         ]
            ++ (if application.instancesNum > 0 then
                    [ div
                        [ class [ Css.DockAppContext ]
                        , onClick (MsgOS OS.Messages.NoOp)
                        ]
                        [ ul []
                            ([ li [] [ text "JAN. ABERTAS" ] ]
                                ++ (List.indexedMap
                                        (\i o -> li [ class [ Css.ClickableWindow ], attribute "data-id" o ] [ text (toString i) ])
                                        application.openWindows
                                   )
                                ++ [ hr [] []
                                   , li [] [ text "JAN. MINIMIZADAS" ]
                                   ]
                                ++ (List.indexedMap
                                        (\i o -> li [ class [ Css.ClickableWindow ], attribute "data-id" o ] [ text (toString i) ])
                                        application.minimizedWindows
                                   )
                                ++ [ hr [] []
                                   , li
                                        [ class [ Css.ClickableWindow ]
                                        , onClick (MsgOS (MsgWM (Open application.window)))
                                        ]
                                        [ text "Nova janela" ]
                                   , li
                                        [ class [ Css.ClickableWindow ]
                                        , onClick (MsgOS (MsgWM (MinimizeAll application.window)))
                                        ]
                                        [ text "Minimizar tudo" ]
                                   , li
                                        [ class [ Css.ClickableWindow ]
                                        , onClick (MsgOS (MsgWM (CloseAll application.window)))
                                        ]
                                        [ text "Fechar tudo" ]
                                   ]
                            )
                        ]
                    ]
                else
                    []
               )
        )
