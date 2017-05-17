module Apps.Browser.Models
    exposing
        ( Browser
        , BrowserTab
        , BrowserHistory
        , BrowserPage
        , PageContent
        , PageTitle
        , PageURL
        , Model
        , ContextBrowser
        , initialBrowser
        , initialModel
        , initialBrowserContext
        , getBrowserInstance
        , getBrowserContext
        , getState
        , isSingleTabbed
        , getTabList
        , getTitle
        , getTab
        , getTabTitle
        , getPage
        , getPageURL
        , getPageTitle
        , getPageContent
        , getPreviousPages
        , getNextPages
        , newTab
        , openTab
        , openTabBackground
        , focusTab
        , gotoPage
        , gotoPreviousPage
        , gotoNextPage
        , closeTab
        )

import Maybe as Maybe exposing (andThen, withDefault)
import Utils exposing (andJust)
import Apps.Instances.Models as Instance
    exposing
        ( Instances
        , InstanceID
        , initialState
        )
import Apps.Browser.Messages exposing (Msg(..))
import Apps.Context as Context exposing (ContextApp)
import Apps.Browser.Context.Models as Menu
import Utils.SlidingList as SlidingList exposing (SlidingList)


type alias PageURL =
    String


type alias PageTitle =
    String


type alias PageContent =
    String


type alias BrowserPage =
    { url : PageURL
    , content : PageContent
    , title : PageTitle
    }


type alias BrowserHistory =
    SlidingList BrowserPage


type alias BrowserTab =
    { addressBar : String
    , history : BrowserHistory
    }


type alias Browser =
    SlidingList BrowserTab


type alias ContextBrowser =
    ContextApp Browser


type alias Model =
    { instances : Instances ContextBrowser
    , menu : Menu.Model
    }


initialModel : Model
initialModel =
    { instances = initialState
    , menu = Menu.initialContext
    }


initialBrowserContext : ContextBrowser
initialBrowserContext =
    Context.initialContext initialBrowser


getBrowserInstance : Instances ContextBrowser -> InstanceID -> ContextBrowser
getBrowserInstance model id =
    case (Instance.get model id) of
        Just instance ->
            instance

        Nothing ->
            initialBrowserContext


getBrowserContext : ContextApp Browser -> Browser
getBrowserContext instance =
    case (Context.state instance) of
        Just context ->
            context

        Nothing ->
            initialBrowser


getState : Model -> InstanceID -> Browser
getState model id =
    getBrowserContext
        (getBrowserInstance model.instances id)


isSingleTabbed : Browser -> Bool
isSingleTabbed browser =
    let
        emptyOrSingleFront =
            case List.tail (SlidingList.getFront browser) of
                Just [] ->
                    True

                Just _ ->
                    False

                Nothing ->
                    True

        emptyRear =
            List.isEmpty (SlidingList.getRear browser)
    in
        emptyOrSingleFront && emptyRear


getTabList : Browser -> List BrowserTab
getTabList browser =
    SlidingList.toList browser


getTab : Browser -> BrowserTab
getTab browser =
    browser
        |> SlidingList.current
        |> withDefault initialTab


getTitle : Browser -> PageTitle
getTitle browser =
    browser
        |> getTab
        |> getTabTitle


getTabTitle : BrowserTab -> PageTitle
getTabTitle tab =
    tab
        |> getPage
        |> getPageTitle


getPage : BrowserTab -> BrowserPage
getPage tab =
    tab.history
        |> SlidingList.current
        |> withDefault initialPage


getPageURL : BrowserPage -> PageURL
getPageURL page =
    page.url


getPageTitle : BrowserPage -> PageTitle
getPageTitle page =
    page.title


getPageContent : BrowserPage -> PageContent
getPageContent page =
    page.content


getPreviousPages : BrowserTab -> List BrowserPage
getPreviousPages tab =
    SlidingList.getRear tab.history


getNextPages : BrowserTab -> List BrowserPage
getNextPages tab =
    SlidingList.getFront tab.history


newTab : Browser -> Browser
newTab browser =
    SlidingList.cons initialTab browser


openTab : BrowserPage -> Browser -> Browser
openTab page browser =
    let
        tab =
            { addressBar = getPageURL page
            , history = SlidingList.singleton page
            }
    in
        SlidingList.consAside tab browser


openTabBackground : BrowserPage -> Browser -> Browser
openTabBackground page browser =
    let
        tab =
            { addressBar = getPageURL page
            , history = SlidingList.singleton page
            }
    in
        browser
            |> SlidingList.consAside tab
            |> SlidingList.rollBackward


focusTab : Int -> Browser -> Browser
focusTab nth browser =
    SlidingList.focusNth nth browser


gotoPage : BrowserPage -> Browser -> Browser
gotoPage newPage browser =
    let
        tab =
            getTab browser

        page =
            getPage tab

        history =
            if newPage /= page then
                tab.history
                    |> SlidingList.consAside newPage
                    |> SlidingList.clearFront
            else
                tab.history

        tab_ =
            { tab | addressBar = getPageURL newPage, history = history }
    in
        SlidingList.replace tab_ browser


gotoPreviousPage : Browser -> Browser
gotoPreviousPage =
    rollHistory SlidingList.rollBackward


gotoNextPage : Browser -> Browser
gotoNextPage =
    rollHistory SlidingList.rollForward


closeTab : Int -> Browser -> Browser
closeTab nth browser =
    browser
        |> SlidingList.removeNth nth
        |> ensureInitialTab



-- private


ensureInitialTab : Browser -> Browser
ensureInitialTab browser =
    if SlidingList.isEmpty browser then
        SlidingList.cons initialTab browser
    else
        browser


initialPage : BrowserPage
initialPage =
    { url = "about:blank", title = "", content = "" }


initialTab : BrowserTab
initialTab =
    let
        page =
            initialPage
    in
        { addressBar = getPageURL page
        , history = SlidingList.singleton page
        }


initialBrowser : Browser
initialBrowser =
    SlidingList.singleton initialTab


rollHistory : (BrowserHistory -> BrowserHistory) -> Browser -> Browser
rollHistory roll browser =
    let
        tab =
            getTab browser

        history =
            roll tab.history
    in
        history
            |> SlidingList.current
            |> andJust
                (\page ->
                    { tab
                        | addressBar = getPageURL page
                        , history = history
                    }
                )
            |> andJust (flip SlidingList.replace browser)
            |> withDefault browser
