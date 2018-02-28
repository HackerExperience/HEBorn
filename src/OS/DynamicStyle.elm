module OS.DynamicStyle exposing (..)

import Html exposing (Html, node, text)
import Html.Attributes exposing (property, id)
import Html.Lazy exposing (lazy)
import Json.Encode as Json
import Css exposing (Stylesheet)
import Css.File
import Game.Models as Game
import Game.Storyline.DynamicStyle as Storyline
import Game.Storyline.StepActions.DynamicStyle as StepActions
import OS.Config exposing (..)


styleNode : String -> List Stylesheet -> Html msg
styleNode id_ stylesheet =
    node "style"
        [ id (id_ ++ "DynStyle")
        , stylesheet
            |> Css.File.compile
            |> (.css)
            |> Json.string
            |> property "innerHTML"
        ]
        []


view : Config msg -> Html msg
view config =
    let
        story =
            Game.getStory config.game

        missions_ =
            StepActions.dynCss
                >> styleNode "missions"

        story_ =
            Storyline.dynCss
                >> styleNode "storyline"

        ( storyStyles, missionsStyles ) =
            if isCampaignFromConfig config then
                ( lazy story_ story
                , lazy missions_ story
                )
            else
                ( text "", text "" )
    in
        storyStyles
