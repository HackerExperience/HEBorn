module Apps.TaskManager.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import UI.Common exposing (flexContainerHorz, flexContainerVert, internalPadding)
import Apps.TaskManager.Resources exposing (Classes(..), prefix)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
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
            [ flex (int 1)
            , marginBottom (px -4)
            ]
        , class TaskTable
            [ flex (int 1)
            , overflowY auto
            ]
        ]
