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


toMegaValues : Float -> String
toMegaValues x =
    -- TODO: Move this function to a better place
    -- TODO: Use "round 2" from elm-round
    if (x > (10 ^ 9)) then
        toString (x / (10 ^ 9)) ++ " G"
    else if (x > (10 ^ 6)) then
        toString (x / (10 ^ 6)) ++ " M"
    else if (x > (10 ^ 3)) then
        toString (x / (10 ^ 3)) ++ " K"
    else
        toString (x) ++ " "


viewTaskRowUsage : ResourceUsage -> List (Html Msg)
viewTaskRowUsage usage =
    [ div [] [ text ((toMegaValues usage.cpu) ++ "Hz") ]
    , div [] [ text ((toMegaValues usage.mem) ++ "iB") ]
    , div [] [ text ((toMegaValues usage.down) ++ "bps") ]
    , div [] [ text ((toMegaValues usage.up) ++ "bps") ]
    ]


viewTaskRow : TaskEntry -> Html Msg
viewTaskRow entry =
    div [ class [ EntryDivision ] ]
        [ div []
            [ div [] [ text entry.title ]
            , div [] [ text "Target: ", text entry.target ]
            , div []
                [ text "File: "
                , text entry.appFile
                , span [] [ text (toString entry.appVer) ]
                ]
            ]
        , div [] [ text (toString entry.eta) ]
        , div [] (viewTaskRowUsage entry.usage)
        ]


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
