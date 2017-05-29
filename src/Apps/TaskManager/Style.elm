module Apps.TaskManager.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Common exposing (flexContainerHorz, flexContainerVert, internalPadding)


type Classes
    = EntryDivision
    | MainLayout
    | TaskTable
    | BottomGraphsRow
    | Graph


css : Stylesheet
css =
    (stylesheet << namespace "taskmngr")
        [ class EntryDivision
            [ flexContainerHorz
            , children
                [ everything
                    [ nthChild "1"
                        [ flex (int 3)
                        , borderRight3 (px 1) solid (rgb 0 0 0)
                        ]
                    , nthChild "2"
                        [ flex (int 1)
                        , borderRight3 (px 1) solid (rgb 0 0 0)
                        ]
                    , nthChild "3"
                        [ flex (int 2) ]
                    , borderBottom3 (px 1) solid (rgb 0 0 0)
                    , internalPadding
                    ]
                ]
            ]
        , class MainLayout
            [ flexContainerVert
            , height (pct 100)
            ]
        , class BottomGraphsRow
            [ flex (int 0)
            , flexContainerHorz
            ]
        , class Graph
            [ flex (int 1) ]
        , class TaskTable
            [ flex (int 1) ]
        , selector "progressbar"
            -- TODO: Make this one into "UI.Widgets"
            [ display inlineBlock
            , borderRadius (vw 100)
            , overflow hidden
            , backgroundColor (hex "444")
            , position relative
            , zIndex (int 0)
            , width (px 80)
            , textAlign center
            , children
                [ selector "fill"
                    [ position absolute
                    , display block
                    , zIndex (int 0)
                    , backgroundColor (hex "11B")
                    , height (pct 100)
                    ]
                , selector "label"
                    [ position relative
                    , margin2 (px 0) auto
                    , zIndex (int 1)
                    , color (hex "EEE")
                    ]
                ]
            ]
        ]
