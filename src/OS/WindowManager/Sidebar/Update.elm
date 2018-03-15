module OS.WindowManager.Sidebar.Update exposing (update)

import Utils.React as React exposing (React)
import OS.WindowManager.Sidebar.Config exposing (..)
import OS.WindowManager.Sidebar.Messages exposing (..)
import OS.WindowManager.Sidebar.Models exposing (..)


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
