module Apps.TaskManager.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.CssHelpers
import Css exposing (asPairs)
import Game.Models exposing (GameModel)
import Apps.TaskManager.Messages exposing (Msg(..))
import Apps.TaskManager.Models exposing (..)
import Apps.TaskManager.Menu.View exposing (menuView)
import Apps.TaskManager.Style exposing (Classes(..))


{ id, class, classList } =
    Html.CssHelpers.withNamespace "taskmngr"


styles : List Css.Mixin -> Attribute Msg
styles =
    Css.asPairs >> style


viewTaskRow : TaskEntry -> Html Msg
viewTaskRow entry =
    div [] []


viewTasksTable : Entries -> Html Msg
viewTasksTable entries =
    div []
        ([ div [ class [ EntryDivision ] ]
            -- TODO: Hide when too small (responsive design)
            [ div [] [ text "Process" ]
            , div [] [ text "ETA" ]
            , div [] [ text "Resources" ]
            ]
         ]
            ++ (List.map viewTaskRow entries)
        )


viewTotalResources : ResourceUsage -> Html Msg
viewTotalResources usage =
    div [] []


view : GameModel -> Model -> Html Msg
view game ({ app } as model) =
    div []
        [ viewTasksTable app.tasks
        , viewTotalResources app.usage
        ]
