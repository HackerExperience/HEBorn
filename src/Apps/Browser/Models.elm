module Apps.Browser.Models exposing (..)

import Dict exposing (Dict)
import Utils.List as List
import Game.Meta.Types.Apps.Desktop exposing (Reference)
import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Meta.Types.Network.Site as Site exposing (Site)
import Apps.Browser.Shared exposing (..)
import Apps.Browser.Pages.NotFound.Models as PageNotFound
import Apps.Browser.Pages.Webserver.Models as PageWebserver
import Apps.Browser.Pages.DownloadCenter.Models as DownloadCenter
import Apps.Browser.Pages.Bank.Models as PageBank


type alias Model =
    { me : Reference
    , tabs : Tabs
    , nowTab : Int
    , leftTabs : List Int
    , rightTabs : List Int
    , lastTab : Int
    }


type alias Tabs =
    Dict Int Tab


type alias Tab =
    { addressBar : URL
    , lastURL : URL
    , page : Page
    , previousPages : BrowserHistory
    , nextPages : BrowserHistory
    , modal : Maybe ModalAction
    }


type Page
    = NotFoundModel PageNotFound.Model
    | HomeModel
    | WebserverModel PageWebserver.Model
    | ProfileModel
    | WhoisModel
    | DownloadCenterModel DownloadCenter.Model
    | ISPModel
    | BankModel PageBank.Model
    | StoreModel
    | BTCModel
    | FBIModel
    | NewsModel
    | BithubModel
    | MissionCenterModel
      -- Virtual ones
    | LoadingModel String
    | BlankModel


type alias BrowserHistory =
    List ( URL, Page )


type ModalAction
    = ForDownload NIP Filesystem.FileEntry
    | ImpossibleToLogin


name : String
name =
    "Browser"


title : Model -> String
title model =
    let
        app =
            getNowTab model

        pgTitle =
            getTitle (getPage app)

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


windowInitSize : ( Int, Int )
windowInitSize =
    ( 900, 550 )


initTab : Tab
initTab =
    { addressBar = "about:home"
    , lastURL = "about:home"
    , page = HomeModel
    , previousPages = []
    , nextPages = []
    , modal = Nothing
    }


emptyTab : Tab
emptyTab =
    { addressBar = ""
    , lastURL = "about:blank"
    , page = BlankModel
    , previousPages = []
    , nextPages = []
    , modal = Nothing
    }


initialModel : Reference -> Model
initialModel me =
    { me = me
    , tabs =
        Dict.fromList
            [ ( 0, initTab ) ]
    , nowTab = 0
    , lastTab = 0
    , leftTabs = []
    , rightTabs = []
    }


getPage : Tab -> Page
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


gotoPage : String -> Page -> Tab -> Tab
gotoPage url page tab =
    if page /= getPage tab then
        let
            previousPages =
                -- Loading pages should not be added to history
                if (isLoading tab.page) then
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
    -> Maybe ( ( URL, Page ), BrowserHistory, BrowserHistory )
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
                model.leftTabs ++ (model.nowTab :: wL)
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
                wR ++ (model.nowTab :: model.rightTabs)
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


initialPage : Site -> Page
initialPage ({ url, type_, meta } as site) =
    case type_ of
        Site.NotFound ->
            NotFoundModel <| PageNotFound.initialModel url

        Site.Home ->
            HomeModel

        Site.Webserver content ->
            WebserverModel <| PageWebserver.initialModel content meta

        Site.Profile ->
            ProfileModel

        Site.Whois ->
            WhoisModel

        Site.DownloadCenter content ->
            DownloadCenterModel <| DownloadCenter.initialModel content meta

        Site.ISP ->
            ISPModel

        Site.Bank content ->
            BankModel <| PageBank.initialModel url content

        Site.Store ->
            StoreModel

        Site.BTC ->
            BTCModel

        Site.FBI ->
            FBIModel

        Site.News ->
            NewsModel

        Site.Bithub ->
            BithubModel

        Site.MissionCenter ->
            MissionCenterModel


getTitle : Page -> String
getTitle page =
    case page of
        NotFoundModel page ->
            PageNotFound.getTitle page

        HomeModel ->
            "Home"

        WebserverModel page ->
            PageWebserver.getTitle page

        ProfileModel ->
            "Your Profile"

        WhoisModel ->
            "Whois"

        DownloadCenterModel _ ->
            "Download Center"

        ISPModel ->
            "Internet Provider"

        BankModel page ->
            PageBank.getTitle page

        StoreModel ->
            "Store"

        BTCModel ->
            "BTV"

        FBIModel ->
            "Federal Bureal Intelligence"

        NewsModel ->
            "News"

        BithubModel ->
            "Software Reasearch"

        MissionCenterModel ->
            "Head Quarters"

        LoadingModel _ ->
            "Loading..."

        BlankModel ->
            "New Tab"


isLoading : Page -> Bool
isLoading page =
    case page of
        LoadingModel _ ->
            True

        _ ->
            False
