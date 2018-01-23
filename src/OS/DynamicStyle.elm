module OS.DynamicStyle exposing (..)

import Html exposing (Html, node, text)
import Html.Attributes exposing (property, id)
import Html.Lazy exposing (lazy)
import Json.Encode as Json
import Css exposing (Stylesheet)
import Css.File
import OS.Config exposing (..)
import Game.Storyline.DynamicStyle as Storyline
import Game.Storyline.Missions.DynamicStyle as Missions


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
view { story, isCampaign } =
    let
        missions_ =
            Missions.dynCss
                >> styleNode "missions"

        story_ =
            Storyline.dynCss
                >> styleNode "storyline"

        ( storyStyles, missionsStyles ) =
            if isCampaign then
                ( lazy story_ story
                , lazy missions_ story.missions
                )
            else
                ( text "", text "" )
    in
        storyStyles
