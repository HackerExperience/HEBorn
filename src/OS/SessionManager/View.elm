module OS.SessionManager.View exposing (..)

import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import Html exposing (..)
import Game.Models as Game
import Game.Data as Game
import OS.SessionManager.WindowManager.View as WindowManager
import OS.SessionManager.WindowManager.Models as WindowManager
import OS.SessionManager.Dock.View as Dock


view : Game.Model -> Model -> Html Msg
view game model =
    node "sess"
        []
        [ viewWM game model
        , viewDock game model
        ]



-- internals


viewDock : Game.Model -> Model -> Html Msg
viewDock game model =
    model
        |> Dock.view game
        |> Html.map DockMsg


viewWM : Game.Model -> Model -> Html Msg
viewWM game model =
    case (Game.toContext game) of
        Just data ->
            model
                |> windows
                |> List.filterMap (maybeViewWindow data model)
                |> node "wmCanvas" []

        Nothing ->
            Html.div [] []


maybeViewWindow :
    Game.Data
    -> Model
    -> WindowRef
    -> Maybe (Html Msg)
maybeViewWindow data model ( wmID, id ) =
    case getWindowManager wmID model of
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
