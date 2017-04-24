module Apps.LogViewer.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Css exposing (asPairs)
import Game.Models exposing (GameModel)
import Game.Servers.Filesystem.Models exposing (FilePath)
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
            [ div [ class [ HeaderBar ] ]
                [ div []
                    [ span [ class [ BtnUser ] ] []
                    , span [ class [ BtnEdit ] ] []
                    , span [ class [ BtnView ] ] []
                    ]
                , div [ class [ ETAct ] ]
                    [ span [ class [ BtnFilter ] ] []
                    , input [ placeholder "Search..." ] []
                    ]
                ]
            , div [ class [ Entry ] ]
                [ div [ class [ ETop ] ]
                    [ div [] [ text "15/03/2016 - 20:24:33.105" ]
                    , div [ class [ ETAct ] ]
                        [ span [ class [ BtnEdit ] ] []
                        ]
                    ]
                , div [ class [ EData ] ]
                    [ span [ class [ IcoCrosshair ] ] []
                    , span [] [ text "174.57.204.104" ]
                    , span [] [ text "logged in as" ]
                    , span [ class [ IcoUser ] ] []
                    , span [] [ text "root" ]
                    ]
                , div [ class [ CasedBtnExpand, EToggler ] ] []
                ]
            , div [ class [ Entry ] ]
                [ div [ class [ ETop ] ]
                    [ div [] [ text "15/03/2016 - 20:24:33.105" ]
                    , div []
                        [ span [ class [ BtnUser ] ] []
                        , span [ class [ BtnEdit ] ] []
                        ]
                    ]
                , div [ class [ EData ] ]
                    [ span [] [ text "H" ]
                    , span [] [ text "localhost" ]
                    , span [] [ text "bounced connection from" ]
                    , span [ class [ IcoCrosshair ] ] []
                    , span [] [ text "174.57.204.104" ]
                    , span [] [ text "to" ]
                    , span [] [ text "D" ]
                    , span [] [ text "209.43.107.189" ]
                    ]
                , div [ class [ EAct ] ]
                    [ span [ class [ IcoUser ] ] []
                    , span [ class [ BtnView ] ] []
                    , span [ class [ BtnEdit ] ] []
                    , span [] [ text "T" ]
                    ]
                , div [ class [ CasedBtnExpand, EToggler ] ] []
                ]
            , div [ class [ Entry ] ]
                [ div [ class [ ETop ] ]
                    [ div [ class [ ETAct ] ]
                        [ span [ class [ BtnLock ] ] []
                        ]
                    ]
                , div [ class [ CasedBtnExpand, EToggler ] ] []
                ]
            , div [ class [ Entry ] ]
                [ div [ class [ ETop ] ]
                    [ div [ class [ ETAct ] ]
                        [ span [ class [ BtnLock ] ] []
                        ]
                    ]
                , div [ class [ EAct ] ]
                    [ span [ class [ BtnView ] ] []
                    , span [ class [ BtnUnlock ] ] []
                    ]
                ]
            , div [ class [ Entry ] ]
                [ div [ class [ ETop ] ] [ text "15/03/2016 - 20:24:33.105" ]
                , div [ class [ EData ] ]
                    [ span [] [ text "NOTME" ]
                    , span [] [ text "logged in as" ]
                    , span [ class [ IcoUser ] ] []
                    , span [] [ text "root" ]
                    ]
                , div [ class [ EAct ] ]
                    [ span [ class [ BtnApply ] ] []
                    , span [ class [ BtnCancel ] ] []
                    ]
                ]
            ]
