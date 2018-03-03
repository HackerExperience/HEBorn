module Apps.Explorer.Style exposing (..)

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Utils.Css exposing (transition, easingToString, Easing(..), pseudoContent, selectableText)
import UI.Common exposing (flexContainerVert, flexContainerHorz, internalPadding, internalPaddingSz)
import UI.Icons as Icons
import Apps.Explorer.Resources exposing (..)


css : Stylesheet
css =
    (stylesheet << namespace prefix)
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
            , internalPadding
            , lineHeight (px 22)
            , minHeight (px 24) -- CHROME HACK
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
            , overflowY auto
            , children
                [ everything
                    [ nthChild "2n+0"
                        [ backgroundColor (hex "DDD") ]
                    ]
                ]
            ]
        , class BreadcrumbItem
            [ before
                [ pseudoContent "\" / \""
                , cursor default
                ]
            , firstOfType [ before [ pseudoContent "\"\"" ] ]
            , cursor pointer
            ]
        , class ActBtns
            [ children
                [ everything
                    [ textAlign center
                    , color (hex "000")
                    , Icons.fontFamily
                    , fontSize (px 22)
                    , cursor pointer
                    , paddingLeft internalPaddingSz
                    ]
                ]
            ]
        , class NewBtn
            [ position relative
            , after
                [ Icons.add
                , fontSize (px 14)
                , position absolute
                , lineHeight (int 1)
                , minHeight (px 14) --CHROME HACK
                , marginLeft (px -14)
                , color (rgba 0 0 255 0.6)
                ]
            ]
        , class DirBtn
            [ before
                [ Icons.directory ]
            ]
        , class DocBtn
            [ before
                [ Icons.fileGeneric ]
            ]
        , class GoUpBtn
            [ before
                [ Icons.dirUp ]
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
                        , Icons.fontFamily
                        ]
                    , nthChild "0n+2"
                        [ flex (int 1)
                        , selectableText
                        ]
                    ]
                ]
            ]
        , class CntListChilds
            [ paddingLeft (px 32)
            , cursor pointer
            , children
                [ everything
                    [ flexContainerHorz
                    , children
                        [ everything
                            [ firstChild
                                [ minWidth (px 32)
                                , display inlineBlock
                                , flex (int 0)
                                , textAlign center
                                , Icons.fontFamily
                                ]
                            , lastChild
                                [ width (px 92) ]
                            , nthChild "0n+3"
                                [ width (px 46)
                                , textAlign center
                                , selectableText
                                ]
                            , nthChild "0n+2"
                                [ flex (int 5) ]
                            ]
                        ]
                    , nthChild "2n+0"
                        [ backgroundColor (hex "DDF") ]
                    ]
                ]
            ]
        , class DirIcon
            [ before
                [ Icons.directoryUntouched
                , color (hex "000")
                ]
            ]
        , class VirusIcon
            [ before
                [ Icons.virus
                , color (hex "D00")
                ]
            ]
        , class FirewallIcon
            [ before
                [ Icons.firewall
                , color (hex "D00")
                ]
            ]
        , class ActiveIcon
            [ before
                [ Icons.modeActive
                , color (hex "D00")
                ]
            ]
        , class PassiveIcon
            [ before
                [ Icons.modePassive
                , color (hex "000")
                ]
            ]
        , class EntryArchive
            [ children
                [ everything
                    [ lastChild
                        [ textAlign center
                        , selectableText
                        , width (px 92)
                        ]
                    , nthChild "0n+3"
                        [ width (px 46)
                        , textAlign center
                        , selectableText
                        ]
                    , nthChild "0n+2"
                        [ flex (int 5) ]
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
            , internalPadding
            ]
        , class NavData
            [ flex (int 0)
            , textAlign center
            , internalPadding
            ]
        , class NavEntry
            [ margin3 (px 8) (px 0) (px 0)
            , cursor pointer
            ]
        , class NavIcon
            [ marginRight (px 8)
            , Icons.fontFamily
            ]
        , class EntryChilds
            [ paddingLeft (px 12)
            , display none
            ]
        , class CasedDirIcon
            [ before [ Icons.directoryUntouched ] ]
        , class CasedOpIcon
            [ before [ Icons.branchUntouched ] ]
        , class GenericArchiveIcon
            [ before [ Icons.fileGeneric ] ]
        , class StorageIcon
            [ before [ Icons.storage ] ]
        , class EntryExpanded
            [ children
                [ class EntryChilds
                    [ display inlineBlock ]
                , class EntryView
                    [ children
                        [ class CasedDirIcon
                            [ before [ Icons.directoryExpanded ] ]
                        , class CasedOpIcon
                            [ before [ Icons.branchExpanded ] ]
                        ]
                    ]
                ]
            ]
        ]
