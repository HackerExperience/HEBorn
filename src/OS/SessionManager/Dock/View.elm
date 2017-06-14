module OS.SessionManager.Dock.View exposing (view)

import Utils exposing (andThenWithDefault)
import Dict exposing (Dict)
import Html exposing (Html, div, text, button, ul, li, hr, footer)
import Html.Events exposing (onClick)
import Html.Attributes exposing (attribute)
import Html.CssHelpers
import OS.SessionManager.Models as SessionManager exposing (..)
import OS.SessionManager.Dock.Messages exposing (..)
import OS.SessionManager.Dock.Style as Css
import OS.SessionManager.WindowManager.Models as WindowManager
import OS.SessionManager.WindowManager.View exposing (windowTitle)
import Apps.Models as Apps
import Game.Models exposing (GameModel)


-- this module still needs a refactor to make its code more maintainable


{ id, class, classList } =
    Html.CssHelpers.withNamespace "dock"


view : GameModel -> SessionManager.Model -> Html Msg
view game model =
    footer []
        [ dock game model
        ]



-- internals


{-| this is messy until elm compiler issue 1008 gets fixed
-}
type alias Applications =
    Dict String ( Apps.App, List WindowRef )


getApplications : GameModel -> SessionManager.Model -> Applications
getApplications game model =
    -- This function should create an app list from the current
    -- server "list of apps" and also from session windows
    [ Apps.BrowserApp
    , Apps.ExplorerApp
    , Apps.LogViewerApp
    , Apps.TaskManagerApp
    ]
        |> List.foldl
            (\app dict ->
                let
                    refs =
                        windows app model
                in
                    Dict.insert (Apps.name app) ( app, refs ) dict
            )
            Dict.empty


windows : Apps.App -> Model -> List WindowRef
windows app model =
    case (current model) of
        Just wm ->
            let
                active =
                    unsafeGetActive model
            in
                wm.windows
                    |> WindowManager.filterAppWindows app
                    |> Dict.toList
                    |> List.map (\( id, win ) -> ( active, id ))

        Nothing ->
            []


hasInstance : List a -> String
hasInstance list =
    if ((List.length list) > 0) then
        "Y"
    else
        "N"


apps : GameModel -> Model -> List ( String, ( Apps.App, List WindowRef ) )
apps game model =
    model
        |> getApplications game
        |> Dict.toList


dock : GameModel -> Model -> Html Msg
dock game model =
    div [ id Css.DockContainer ]
        [ div
            [ id Css.DockMain ]
            (model |> apps game |> List.map (format >> icon model))
        ]


format : ( a, ( b, c ) ) -> ( a, b, c )
format ( name, ( app, list ) ) =
    ( name, app, list )


icon : Model -> ( a, Apps.App, List WindowRef ) -> Html Msg
icon model ( name, app, list ) =
    div
        [ class [ Css.Item ]
        , attribute "data-hasinst" (hasInstance list)
        ]
        ([ div
            [ class [ Css.ItemIco ]
            , onClick (openOrRestore app list)
            , attribute "data-icon" (Apps.icon app)
            ]
            []
         ]
            ++ (if not (List.isEmpty list) then
                    [ subMenu app list model ]
                else
                    []
               )
        )


openOrRestore : Apps.App -> a -> Msg
openOrRestore app list =
    -- FIXME pls
    OpenApp app


subMenu : Apps.App -> List WindowRef -> Model -> Html Msg
subMenu app refs model =
    div
        [ class [ Css.DockAppContext ]
        ]
        [ ul []
            ((openedWindows app refs model)
                ++ [ hr [] [] ]
                ++ (minimizedWindows app refs model)
                ++ [ hr [] [] ]
                ++ [ subMenuAction "New window" (OpenApp app)
                   , subMenuAction "Minimize all" (MinimizeApps app)
                   , subMenuAction "Close all" (CloseApps app)
                   ]
            )
        ]


subMenuAction : String -> msg -> Html msg
subMenuAction label event =
    li
        [ class [ Css.ClickableWindow ], onClick event ]
        [ text label ]


openedWindows : a -> List WindowRef -> Model -> List (Html Msg)
openedWindows app refs model =
    let
        -- this function only exists because unions are'nt composable
        filter =
            \state ->
                case state of
                    WindowManager.NormalState ->
                        True

                    _ ->
                        False

        wins =
            refs
                |> filterWinState filter app model
                |> windowList model FocusWindow
    in
        (li [] [ text "OPEN WINDOWS" ]) :: wins


minimizedWindows : a -> List WindowRef -> Model -> List (Html Msg)
minimizedWindows app refs model =
    let
        -- this function only exists because unions are'nt composable
        filter =
            \state ->
                case state of
                    WindowManager.MinimizedState ->
                        True

                    _ ->
                        False

        wins =
            refs
                |> filterWinState filter app model
                |> windowList model RestoreWindow
    in
        (li [] [ text "MINIMIZED LINUXES" ]) :: wins


windowLabel : Int -> WindowRef -> Model -> String
windowLabel i refs model =
    (toString i)
        ++ ": "
        ++ (andThenWithDefault
                windowTitle
                "404"
                (getWindow refs model)
           )


windowList : Model -> (WindowRef -> msg) -> List WindowRef -> List (Html msg)
windowList model event =
    List.indexedMap
        (\i (( sID, id ) as refs) ->
            li
                [ class [ Css.ClickableWindow ]
                , attribute "data-id" id
                , onClick (event refs)
                ]
                [ text (windowLabel i refs model) ]
        )


filterWinState :
    (WindowManager.WindowState -> Bool)
    -> a
    -> Model
    -> List WindowRef
    -> List ( String, String )
filterWinState filter app model =
    List.filter
        (\ref ->
            case getWindow ref model of
                Just win ->
                    filter win.state

                Nothing ->
                    False
        )
