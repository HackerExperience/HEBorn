module UI.DynStyles.Highlight.Explorer exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Utils.Css as Css exposing (withAttribute)
import Apps.Explorer.Resources as Explorer


highlighFileId : String -> Stylesheet
highlighFileId fId =
    (stylesheet << namespace Explorer.prefix)
        [ class Explorer.CntListEntry
            [ withAttribute (Css.EQ Explorer.idAttrKey fId)
                [ backgroundColor (hex "D3D")
                ]
            ]
        ]
