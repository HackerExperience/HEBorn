module Apps.Browser.Models exposing (..)

import Dict exposing (Dict)
import Utils.List as List
import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Filesystem.Models as Filesystem
import Apps.Config exposing (..)
import Apps.Browser.Menu.Models as Menu
import Apps.Browser.Pages.Models as Pages


type alias URL =
    String


type alias BrowserHistory =
    List ( URL, Pages.Model )


type alias Tab =
    { addressBar : URL
    , lastURL : URL
    , page : Pages.Model
    , previousPages : BrowserHistory
    , nextPages : BrowserHistory
    , modal : Maybe ModalAction
    }


type alias Tabs =
    Dict Int Tab


type alias Model =
    { me : Config
    , tabs : Tabs
    , nowTab : Int
    , leftTabs : List Int
    , rightTabs : List Int
    , lastTab : Int
    , menu : Menu.Model
    }


type ModalAction
    = ForDownload NIP Filesystem.FileEntry


name : String
name =
    "Browser"


title : Model -> String
title model =
    let
        app =
            getNowTab model

        pgTitle =
            Pages.getTitle (getPage app)

        posfix =
            if (String.length pgTitle) > 12 then
                Just (": \"" ++ (String.left 10 pgTitle) ++ "[...]\"")
            else if (String.length pgTitle) > 0 then
                Just (": \"" ++ pgTitle ++ "\"")
            else
                Nothing
    in
        posfix
            |> Maybe.map ((++) name)
            |> Maybe.withDefault name


icon : String
icon =
    "browser"


windowInitSize : ( Float, Float )
windowInitSize =
    ( 900, 550 )


initTab : Tab
initTab =
    { addressBar = "about:home"
    , lastURL = "about:home"
    , page = Pages.HomeModel
    , previousPages = []
    , nextPages = []
    , modal = Nothing
    }


emptyTab : Tab
emptyTab =
    { addressBar = ""
    , lastURL = "about:blank"
    , page = Pages.BlankModel
    , previousPages = []
    , nextPages = []
    , modal = Nothing
    }


initialModel : Config -> Model
initialModel me =
    { me = me
    , tabs =
        Dict.fromList
            [ ( 0, initTab ) ]
    , nowTab = 0
    , lastTab = 0
    , leftTabs = []
    , rightTabs = []
    , menu = Menu.initialMenu
    }


getPage : Tab -> Pages.Model
getPage browser =
    browser.page


getURL : Tab -> URL
getURL browser =
    browser.lastURL


getPreviousPages : Tab -> BrowserHistory
getPreviousPages browser =
    browser.previousPages


getNextPages : Tab -> BrowserHistory
getNextPages browser =
    browser.nextPages


gotoPage : String -> Pages.Model -> Tab -> Tab
gotoPage url page tab =
    if page /= getPage tab then
        let
            previousPages =
                -- Loading pages should not be added to history
                if (Pages.isLoading tab.page) then
                    getPreviousPages tab
                else
                    ( tab.lastURL, tab.page )
                        :: (getPreviousPages tab)
        in
            { tab
                | addressBar = url
                , lastURL = url
                , page = page
                , previousPages = previousPages
                , nextPages = []
            }
    else
        tab


gotoPreviousPage : Tab -> Tab
gotoPreviousPage tab =
    tab
        |> reorderHistory getPreviousPages getNextPages
        |> Maybe.map
            (\( ( url, page ), prev, next ) ->
                { tab
                    | page = page
                    , previousPages = prev
                    , nextPages = next
                    , lastURL = url
                    , addressBar = url
                }
            )
        |> Maybe.withDefault
            tab


gotoNextPage : Tab -> Tab
gotoNextPage tab =
    tab
        |> reorderHistory getNextPages getPreviousPages
        |> Maybe.map
            (\( ( url, page ), next, prev ) ->
                { tab
                    | page = page
                    , previousPages = prev
                    , nextPages = next
                    , lastURL = url
                    , addressBar = url
                }
            )
        |> Maybe.withDefault
            tab


reorderHistory :
    (Tab -> BrowserHistory)
    -> (Tab -> BrowserHistory)
    -> Tab
    -> Maybe ( ( URL, Pages.Model ), BrowserHistory, BrowserHistory )
reorderHistory getFromList getToList tab =
    let
        from =
            getFromList tab

        to =
            getToList tab

        oldPage =
            getPage tab

        oldURL =
            getURL tab
    in
        from
            |> List.head
            |> Maybe.map
                (\newPage ->
                    let
                        from_ =
                            from
                                |> List.tail
                                |> Maybe.withDefault ([])

                        to_ =
                            ( oldURL, oldPage ) :: to
                    in
                        ( newPage, from_, to_ )
                )


getTab : Int -> Tabs -> Tab
getTab id src =
    Dict.get id src
        |> Maybe.withDefault
            initTab


setTab : Int -> Tab -> Tabs -> Tabs
setTab id value src =
    Dict.insert id value src


getNowTab : Model -> Tab
getNowTab model =
    getTab model.nowTab model.tabs


setNowTab : Tab -> Model -> Model
setNowTab tab model =
    let
        newTabs =
            setTab model.nowTab tab model.tabs
    in
        { model | tabs = newTabs }


goTab : Int -> Model -> Model
goTab nTab model =
    if nTab == model.nowTab then
        model
    else if List.member nTab model.rightTabs then
        let
            ( wL, newRight ) =
                List.splitOut
                    (model.rightTabs
                        |> List.memberIndex nTab
                        |> Maybe.withDefault 0
                    )
                    model.rightTabs

            newLeft =
                model.leftTabs ++ [ model.nowTab ] ++ wL
        in
            { model
                | leftTabs = newLeft
                , rightTabs = newRight
                , nowTab = nTab
            }
    else
        let
            ( newLeft, wR ) =
                List.splitOut
                    (model.leftTabs
                        |> List.memberIndex nTab
                        |> Maybe.withDefault 0
                    )
                    model.leftTabs

            newRight =
                wR ++ [ model.nowTab ] ++ model.rightTabs
        in
            { model
                | leftTabs = newLeft
                , rightTabs = newRight
                , nowTab = nTab
            }


addTab : Model -> Model
addTab model =
    let
        newN =
            model.lastTab + 1

        tabs =
            Dict.insert newN emptyTab model.tabs

        rightTabs =
            newN :: model.rightTabs
    in
        { model | tabs = tabs, lastTab = newN, rightTabs = rightTabs }


deleteTab : Int -> Model -> Model
deleteTab nTab model =
    if nTab == model.nowTab then
        case model.rightTabs of
            [] ->
                case List.reverse model.leftTabs of
                    [] ->
                        initialModel model.me

                    [ unique ] ->
                        { model | nowTab = unique, leftTabs = [] }

                    head :: tail ->
                        { model | nowTab = head, leftTabs = List.reverse tail }

            [ unique ] ->
                { model | nowTab = unique, rightTabs = [] }

            head :: tail ->
                { model | nowTab = head, rightTabs = tail }
    else if List.member nTab model.leftTabs then
        let
            ( wL, wR ) =
                List.splitOut
                    (model.leftTabs
                        |> List.memberIndex nTab
                        |> Maybe.withDefault 0
                    )
                    model.leftTabs
        in
            { model | leftTabs = wL ++ wR }
    else
        let
            ( wL, wR ) =
                List.splitOut
                    (model.rightTabs
                        |> List.memberIndex nTab
                        |> Maybe.withDefault 0
                    )
                    model.rightTabs
        in
            { model | rightTabs = wL ++ wR }


leaveModal : Tab -> Tab
leaveModal tab =
    { tab | modal = Nothing }
