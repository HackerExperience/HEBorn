module OS.WindowManager.Sidebar.Update exposing (update)

import Utils.React as React exposing (React)
import OS.WindowManager.Sidebar.Config exposing (Config)
import OS.WindowManager.Sidebar.Messages exposing (Msg(..), WidgetMsg(..))
import OS.WindowManager.Sidebar.Models exposing (..)
import OS.WindowManager.Sidebar.Shared exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        ToggleVisibility ->
            model
                |> getVisibility
                |> not
                |> flip setVisibility model
                |> React.update

        NewWidget _ _ ->
            -- TODO
            React.update model

        Remove id ->
            model
                |> remove id
                |> React.update

        Prioritize id ->
            model
                |> prioritize id
                |> React.update

        Deprioritize id ->
            model
                |> deprioritize id
                |> React.update

        WidgetMsg widgetID msg ->
            onWidgetMsg widgetID msg model


onWidgetMsg : WidgetID -> WidgetMsg -> Model -> UpdateResponse msg
onWidgetMsg widgetID msg model =
    case get widgetID model of
        Just widget ->
            -- TODO
            React.update model

        Nothing ->
            React.update model
