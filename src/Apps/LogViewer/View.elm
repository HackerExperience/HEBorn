module Apps.LogViewer.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Css exposing (asPairs)
import Game.Models exposing (GameModel)
import Apps.Instances.Models as Instance exposing (InstanceID)
import Apps.Context as Context
import Apps.LogViewer.Messages exposing (Msg(..))
import Apps.LogViewer.Models exposing (Model, LogViewer, getState)
import Apps.LogViewer.Context.Models exposing (Context(..))
import Apps.LogViewer.Style exposing (Classes(..))


{ id, class, classList } =
    Html.CssHelpers.withNamespace "logvw"


styles : List Css.Mixin -> Attribute Msg
styles =
    Css.asPairs >> style


view : Model -> InstanceID -> GameModel -> Html Msg
view model id game =
    let
        logvw =
            getState model id
    in
        div []
            [ div []
                [ div []
                    [ span [] [ text "I" ]
                    , span [] [ text "E" ]
                    , span [] [ text "V" ]
                    ]
                , div []
                    [ span [] [ text "O" ]
                    , input [ placeholder "Search..." ] []
                    ]
                ]
            , div []
                [ div []
                    [ div [] [ text "15/03/2016 - 20:24:33.105" ]
                    , div []
                        [ span [] [ text "E" ]
                        ]
                    ]
                , div []
                    [ span [] [ text "L" ]
                    , span [] [ text "174.57.204.104" ]
                    , span [] [ text "logged in as" ]
                    , span [] [ text "U" ]
                    , span [] [ text "root" ]
                    ]
                , div [] [ text "^" ]
                ]
            , div []
                [ div []
                    [ div [] [ text "15/03/2016 - 20:24:33.105" ]
                    , div []
                        [ span [] [ text "I" ]
                        , span [] [ text "E" ]
                        ]
                    ]
                , div []
                    [ span [] [ text "H" ]
                    , span [] [ text "localhost" ]
                    , span [] [ text "bounced connection from" ]
                    , span [] [ text "L" ]
                    , span [] [ text "174.57.204.104" ]
                    , span [] [ text "to" ]
                    , span [] [ text "D" ]
                    , span [] [ text "209.43.107.189" ]
                    ]
                , div []
                    [ span [] [ text "L" ]
                    , span [] [ text "V" ]
                    , span [] [ text "E" ]
                    , span [] [ text "T" ]
                    ]
                , div [] [ text "^" ]
                ]
            , div []
                [ div []
                    [ div [] []
                    , div []
                        [ span [] [ text "L" ]
                        ]
                    ]
                , div [] [ text "^" ]
                ]
            , div []
                [ div []
                    [ div [] []
                    , div []
                        [ span [] [ text "L" ]
                        ]
                    ]
                , div []
                    [ span [] [ text "V" ]
                    , span [] [ text "T" ]
                    ]
                ]
            , div []
                [ div [] [ text "15/03/2016 - 20:24:33.105" ]
                , div []
                    [ span [] [ text "S" ]
                    , span [] [ text "NOTME" ]
                    , span [] [ text "logged in as" ]
                    , span [] [ text "U" ]
                    , span [] [ text "root" ]
                    ]
                , div []
                    [ span [] [ text "C" ]
                    , span [] [ text "W" ]
                    ]
                ]
            ]
