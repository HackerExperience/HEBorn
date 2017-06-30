module UI.Style exposing (css)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Elements exposing (input, span)
import Css.Common exposing (internalPadding, flexContainerHorz, flexContainerVert)
import Css.Utils exposing (attrSelector)
import Css.Icons as Icon exposing (locationTarget)
import UI.Colors as Colors exposing (hyperlink, localhost)


-- Utils


ico : Style
ico =
    before
        [ Icon.fontFamily
        , textAlign center
        ]



-- Entries


entries : List Snippet
entries =
    filterHeader ++ toogable


filterHeader : List Snippet
filterHeader =
    [ selector "filterHeader"
        [ flexContainerHorz
        , borderBottom3 (px 1) solid Colors.black
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
                , border3 (px 1) solid Colors.black
                ]
            ]
        ]
    ]


toogable : List Snippet
toogable =
    [ selector "toogableEntry"
        [ fontSize (px 12)
        , borderBottom3 (px 1) solid Colors.black
        , internalPadding
        , display block
        , children
            [ selector "btn"
                [ ico
                , width (pct 100)
                , display block
                , textAlign center
                , minHeight (px 16)
                , before [ Icon.divExpand ]
                , cursor pointer
                ]
            ]
        ]
    , attrSelector "toogableEntry > btn"
        "expanded"
        "="
        "\"1\""
        [ before [ Icon.divContract ] ]
    ]



-- Inlines


inlines : List Snippet
inlines =
    linkAddr


linkAddr : List Snippet
linkAddr =
    [ selector "linkAddr"
        [ color Colors.hyperlink
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
        "localhost"
        "="
        "\"1\""
        [ color Colors.localhost
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
    , selector "linkUser"
        [ color Colors.hyperlink
        , children
            [ selector "ico"
                [ ico
                , before [ Icon.person ]
                ]
            , selector "addr"
                [ textDecoration underline ]
            ]
        ]
    , attrSelector "linkUser"
        "root"
        "="
        "\"1\""
        [ color Colors.root
        , fontWeight bold
        , children
            [ selector "addr"
                [ textDecoration none ]
            ]
        ]
    ]



-- Layouts


layouts : List Snippet
layouts =
    [ verticalList, horizontalTabs ]


horizontalTabs : Snippet
horizontalTabs =
    selector "panel"
        [ fontSize (px 12)
        , borderBottom3 (px 1) solid Colors.black
        , display block
        , children
            [ selector "tab"
                [ display inlineBlock
                , padding3 (px 8) (px 16) (px 4)
                , borderTop3 (px 1) solid Colors.black
                , borderLeft3 (px 1) solid Colors.black
                , borderRight3 (px 1) solid Colors.black
                , borderTopLeftRadius (px 12)
                , borderTopRightRadius (px 12)
                ]
            , attrSelector "tab"
                "data-selected"
                "="
                "\"1\""
                [ backgroundColor Colors.bgSelected
                ]
            ]
        ]


verticalList : Snippet
verticalList =
    selector "verticallist"
        [ overflowY scroll
        , flex (int 1)
        ]


verticalSticked : Snippet
verticalSticked =
    selector "verticalSticked"
        [ flex (int 1)
        , flexContainerVert
        , children
            [ selector "headerStick, footerStick"
                [ flex (int 0) ]
            , selector "mainCont"
                [ flex (int 1)
                , flexContainerVert
                ]
            ]
        ]



-- Widgets


widgets : List Snippet
widgets =
    [ progressBar, horizontalBtnPanel ] ++ customSelect


customSelect : List Snippet
customSelect =
    [ selector "customSelect"
        [ children [ selector "selector" [ display none ] ] ]
    , attrSelector "customSelect"
        "data-open"
        "="
        "open"
        [ children [ selector "selector" [ display block ] ] ]
    ]


horizontalBtnPanel : Snippet
horizontalBtnPanel =
    selector "horizontalBtnPanel"
        [ width (pct 100)
        , fontSize (px 24)
        , textAlign center
        ]


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
        , fontSize (px 12)
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
