module Apps.Explorer.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Utils exposing (transition, easingToString, Easing(..), pseudoContent, selectableText)
import Css.Common exposing (flexContainerVert, flexContainerHorz, internalPadding, internalPaddingSz)
import Css.Icons as Icon


type Classes
    = Window
    | Nav
    | Content
    | ContentHeader
    | ContentList
    | LocBar
    | ActBtns
    | DirBtn
    | DocBtn
    | NewBtn
    | GoUpBtn
    | BreadcrumbItem
    | CntListEntry
    | EntryDir
    | EntryArchive
    | EntryExpanded
    | VirusIcon
    | FirewallIcon
    | DirIcon
    | GenericArchiveIcon
    | CasedDirIcon
    | CasedOpIcon
    | NavEntry
    | NavTree
    | NavData
    | NavIcon
    | EntryView
    | EntryChilds
    | ProgBar
    | ProgFill


css : Stylesheet
css =
    (stylesheet << namespace "explorer")
        [ class Window
            [ flexContainerHorz
            , height (pct 100)
            ]
        , class Content
            [ flex (int 1)
            , flexContainerVert
            ]
        , class ContentHeader
            [ flex (int 0)
            , flexContainerHorz
            , paddingLeft internalPaddingSz
            , lineHeight (px 22)
            ]
        , class LocBar
            [ flex (int 1)
            , fontSize (px 12)
            ]
        , class ActBtns
            [ flex (int 0) ]
        , class ContentList
            [ flex (int 1)
            , internalPadding
            , paddingRight zero
            , backgroundColor (hex "DDD")
            , overflowY auto
            ]
        , class BreadcrumbItem
            [ before
                [ pseudoContent "\"/ \"" ]
            , after
                [ pseudoContent "\" \"" ]
            ]
        , class ActBtns
            [ children
                [ everything
                    [ textAlign center
                    , color (hex "000")
                    , Icon.fontFamily
                    , fontSize (px 22)
                    , cursor pointer
                    , paddingLeft internalPaddingSz
                    ]
                ]
            ]
        , class NewBtn
            [ after
                [ Icon.add
                , fontSize (px 14)
                , position absolute
                , lineHeight (int 1)
                , marginLeft (px -14)
                , color (rgba 0 0 255 0.6)
                ]
            ]
        , class DirBtn
            [ before
                [ Icon.directory ]
            ]
        , class DocBtn
            [ before
                [ Icon.fileGeneric ]
            ]
        , class GoUpBtn
            [ before
                [ Icon.dirUp ]
            ]
        , class CntListEntry
            [ flexContainerHorz
            , cursor pointer
            , children
                [ everything
                    [ firstChild
                        [ minWidth (px 32)
                        , display inlineBlock
                        , flex (int 0)
                        , textAlign center
                        , Icon.fontFamily
                        ]
                    , nthChild "0n+2"
                        [ flex (int 1)
                        , selectableText
                        ]
                    ]
                ]
            ]
        , class DirIcon
            [ before
                [ Icon.directoryUntouched
                , color (hex "000")
                ]
            ]
        , class VirusIcon
            [ before
                [ Icon.virus
                , color (hex "D00")
                ]
            ]
        , class FirewallIcon
            [ before
                [ Icon.firewall
                , color (hex "D00")
                ]
            ]
        , class EntryArchive
            [ children
                [ everything
                    [ lastChild
                        [ flex (int 2)
                        , textAlign center
                        , selectableText
                        ]
                    , nthChild "0n+3"
                        [ flex (int 1)
                        , textAlign center
                        , selectableText
                        ]
                    , nthChild "0n+2"
                        [ flex (int 5)
                        ]
                    ]
                ]
            ]
        , class Nav
            [ margin zero
            , padding zero
            , flex (int 0)
            , minWidth (px 180)
            , flexContainerVert
            , fontSize (px 12)
            ]
        , class NavTree
            [ flex (int 1)
            , overflowY auto
            ]
        , class NavData
            [ flex (int 0)
            , textAlign center
            ]
        , class NavEntry
            [ margin3 (px 8) (px 0) (px 0) ]
        , class NavIcon
            [ marginRight (px 8)
            , Icon.fontFamily
            ]
        , class EntryChilds
            [ paddingLeft (px 12)
            , display none
            ]
        , class CasedDirIcon
            [ before [ Icon.directoryUntouched ] ]
        , class CasedOpIcon
            [ before [ Icon.branchUntouched ] ]
        , class GenericArchiveIcon
            [ before [ Icon.fileGeneric ] ]
        , class EntryExpanded
            [ children
                [ class EntryChilds
                    [ display inlineBlock ]
                , class EntryView
                    [ children
                        [ class CasedDirIcon
                            [ before [ Icon.directoryExpanded ] ]
                        , class CasedOpIcon
                            [ before [ Icon.branchExpanded ] ]
                        ]
                    ]
                ]
            ]
        , class ProgBar
            [ borderRadius (px 8)
            , border3 (px 1) solid (hex "000")
            , display inlineBlock
            , width (pct 80)
            , height (px 8)
            ]
        , class ProgFill
            [ width (pct 100)
            , height (pct 100)
            , backgroundColor (hex "555")
            ]
        ]
