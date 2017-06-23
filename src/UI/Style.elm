module UI.Style exposing (css)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Elements exposing (input, span)
import Css.Common exposing (internalPadding, internalPaddingSz, flexContainerHorz)
import Css.Utils exposing (attrSelector)
import Css.Icons as Icon exposing (locationTarget)
import UI.Colors as Colors exposing (hyperlink, localhost)


-- Utils


ico : Mixin
ico =
    mixin
        [ before
            [ Icon.fontFamily
            , textAlign center
            ]
        ]



-- Entries


entries : List Snippet
entries =
    filterHeader


filterHeader : List Snippet
filterHeader =
    [ selector "filterHeader"
        [ flexContainerHorz
        , borderBottom3 (px 1) solid (hex "000")
        , internalPadding
        , lineHeight (px 32)
        , minHeight (px 33) --CHROME HACK
        ]
    , selector "flagsFilterPanel"
        [ flex (int 1)
        , fontSize (px 32)
        ]
    , selector "filterText"
        [ children
            [ input
                [ flex (int 1)
                , marginLeft (px 18)
                , padding (px 3)
                , borderRadius (px 12)
                , border3 (px 1) solid (hex "000")
                ]
            ]
        ]
    ]



-- Inlines


inlines : List Snippet
inlines =
    linkAddr


linkAddr : List Snippet
linkAddr =
    [ selector "linkAddr"
        [ Colors.hyperlink
        , children
            [ selector "ico"
                [ ico
                , before [ Icon.locationTarget ]
                ]
            , selector "addr"
                [ textDecoration underline ]
            ]
        ]
    , attrSelector "linkAddr"
        "data-localhost"
        "="
        "\"1\""
        [ Colors.localhost
        , fontWeight bold
        , children
            [ selector "ico"
                [ ico
                , before [ Icon.home ]
                ]
            , selector "addr"
                [ textDecoration none ]
            ]
        ]
    ]



-- Layouts


layouts : List Snippet
layouts =
    [ verticalList ]


verticalList : Snippet
verticalList =
    selector "verticallist"
        [ overflowY scroll
        , flex (int 1)
        ]



-- Widgets


widgets : List Snippet
widgets =
    [ progressBar ]


progressBar : Snippet
progressBar =
    selector "progressBar"
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



-- MAIN CSS


css : Stylesheet
css =
    (stylesheet << namespace "ui")
        (entries ++ inlines ++ layouts ++ widgets)
