module Apps.Browser.Models
    exposing
        ( Browser
        , ContextBrowser
        , Model
        , BrowserHistory
        , BrowserPage
        , PageURL
        , PageTitle
        , PageContent
        , initialBrowser
        , initialModel
        , initialBrowserContext
        , getBrowserInstance
        , getBrowserContext
        , getState
        , getPage
        , getPageURL
        , getPageContent
        , getPageTitle
        , getPreviousPages
        , getNextPages
        , gotoPage
        , gotoPreviousPage
        , gotoNextPage
        )

import Maybe
import Apps.Instances.Models as Instance
    exposing
        ( Instances
        , InstanceID
        , initialState
        )
import Apps.Browser.Messages exposing (Msg(..))
import Apps.Context as Context exposing (ContextApp)
import Apps.Browser.Menu.Models as Menu


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
    List BrowserPage


type alias Browser =
    { addressBar : PageURL
    , page : BrowserPage
    , previousPages : BrowserHistory
    , nextPages : BrowserHistory
    }


type alias ContextBrowser =
    ContextApp Browser


type alias Model =
    { instances : Instances ContextBrowser
    , menu : Menu.Model
    }


initialBrowser : Browser
initialBrowser =
    { addressBar = "about:blank"

    -- FIXME: update the content
    , page = { url = "about:blank", title = "", content = "" }
    , previousPages = []
    , nextPages = []
    }


initialModel : Model
initialModel =
    { instances = initialState
    , menu = Menu.initialMenu
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


getPage : Browser -> BrowserPage
getPage browser =
    browser.page


getPageURL : BrowserPage -> PageURL
getPageURL page =
    page.url


getPageTitle : BrowserPage -> PageTitle
getPageTitle page =
    page.title


getPageContent : BrowserPage -> PageContent
getPageContent page =
    page.content


getPreviousPages : Browser -> BrowserHistory
getPreviousPages browser =
    browser.previousPages


getNextPages : Browser -> BrowserHistory
getNextPages browser =
    browser.nextPages


gotoPage : BrowserPage -> Browser -> Browser
gotoPage page browser =
    if page /= getPage browser then
        let
            previousPages =
                browser.page :: (getPreviousPages browser)
        in
            { browser
                | addressBar = getPageURL page
                , page = page
                , previousPages = previousPages
                , nextPages = []
            }
    else
        browser


gotoPreviousPage : Browser -> Browser
gotoPreviousPage browser =
    let
        maybeReorderedHistory =
            reorderHistory getPreviousPages getNextPages browser
    in
        case maybeReorderedHistory of
            Just ( page, prev, next ) ->
                { browser
                    | page = page
                    , previousPages = prev
                    , nextPages = next
                }

            Nothing ->
                browser


gotoNextPage : Browser -> Browser
gotoNextPage browser =
    let
        maybeReorderedHistory =
            reorderHistory getNextPages getPreviousPages browser
    in
        case maybeReorderedHistory of
            Just ( page, next, prev ) ->
                { browser
                    | page = page
                    , previousPages = prev
                    , nextPages = next
                }

            Nothing ->
                browser


reorderHistory :
    (Browser -> BrowserHistory)
    -> (Browser -> BrowserHistory)
    -> Browser
    -> Maybe ( BrowserPage, BrowserHistory, BrowserHistory )
reorderHistory getFromList getToList browser =
    let
        from =
            getFromList browser

        to =
            getToList browser

        oldPage =
            getPage browser
    in
        case List.head from of
            Just newPage ->
                let
                    from_ =
                        from
                            |> List.tail
                            |> Maybe.withDefault ([])

                    to_ =
                        oldPage :: to
                in
                    Just ( newPage, from_, to_ )

            Nothing ->
                Nothing
