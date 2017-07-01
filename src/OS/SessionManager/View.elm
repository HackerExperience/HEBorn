module OS.SessionManager.View exposing (..)

import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import Html exposing (..)
import Game.Data as GameData
import OS.SessionManager.WindowManager.View as WindowManager
import OS.SessionManager.WindowManager.Models as WindowManager
import OS.SessionManager.Dock.View as Dock


view : GameData.Data -> Model -> Html Msg
view game model =
    node "sess"
        []
        [ viewWM game model
        , viewDock game model
        ]



-- internals


viewDock : GameData.Data -> Model -> Html Msg
viewDock game model =
    model
        |> Dock.view game
        |> Html.map DockMsg


viewWM : GameData.Data -> Model -> Html Msg
viewWM data model =
    model
        |> windows data.id
        |> List.filterMap (maybeViewWindow data model)
        |> node "wmCanvas" []


maybeViewWindow :
    GameData.Data
    -> Model
    -> WindowRef
    -> Maybe (Html Msg)
maybeViewWindow data model ( wmID, id ) =
    case get wmID model of
        Just wm ->
            model
                |> getWindow ( wmID, id )
                |> Maybe.andThen
                    (\window ->
                        case window.state of
                            WindowManager.NormalState ->
                                wm
                                    |> WindowManager.view id data
                                    |> Html.map WindowManagerMsg
                                    |> Just

                            _ ->
                                Nothing
                    )

        Nothing ->
            Nothing
