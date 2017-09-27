module Apps.Browser.Update exposing (update)

import Utils.Update as Update
import Game.Data as Game
import Game.Network.Types exposing (NIP)
import Game.Servers.Models as Servers
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Processes.Models as Processes
import Game.Web.Messages as Web
import Game.Web.Types as Web
import Game.Network.Types exposing (NIP)
import Apps.Config exposing (..)
import Apps.Browser.Messages exposing (..)
import Apps.Browser.Models exposing (..)
import Apps.Browser.Pages.Messages as Pages
import Apps.Browser.Pages.Update as Pages
import Apps.Browser.Pages.Models as Pages
import Apps.Browser.Menu.Messages as Menu
import Apps.Browser.Menu.Update as Menu
import Apps.Browser.Menu.Actions as Menu
import Core.Dispatch as Dispatch exposing (Dispatch)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


type alias TabUpdateResponse =
    ( Tab, Cmd TabMsg, Dispatch )


update :
    Game.Data
    -> Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case msg of
        -- Menu
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            onMenuMsg data msg model

        -- TabMsgs
        ActiveTabMsg msg ->
            updateSomeTabMsg data model.nowTab msg model

        SomeTabMsg tabId msg ->
            updateSomeTabMsg data tabId msg model

        -- Browser
        NewTabIn url ->
            onNewTabIn data url model

        ChangeTab tabId ->
            goTab tabId model
                |> Update.fromModel



-- browser internals


onMenuMsg :
    Game.Data
    -> Menu.Msg
    -> Model
    -> UpdateResponse
onMenuMsg data msg model =
    Update.child
        { get = .menu
        , set = (\menu model -> { model | menu = menu })
        , toMsg = MenuMsg
        , update = (Menu.update data)
        }
        msg
        model


onNewTabIn : Game.Data -> URL -> Model -> UpdateResponse
onNewTabIn data url model =
    let
        createTabModel =
            addTab model

        goTabModel =
            goTab
                createTabModel.lastTab
                createTabModel

        tabId =
            goTabModel.nowTab

        tab =
            getTab tabId goTabModel.tabs

        ( tab_, cmd, dispatch ) =
            onGoAddress data url model.me tabId tab

        model_ =
            setNowTab tab_ goTabModel

        cmd_ =
            Cmd.map (SomeTabMsg tabId) cmd
    in
        ( model_, cmd_, dispatch )


updateSomeTabMsg :
    Game.Data
    -> Int
    -> TabMsg
    -> Model
    -> UpdateResponse
updateSomeTabMsg data tabId msg model =
    let
        tab =
            getTab tabId model.tabs

        result =
            case msg of
                UpdateAddress newAddr ->
                    onUpdateAddress newAddr tab

                GoPrevious ->
                    onGoPrevious tab

                GoNext ->
                    onGoNext tab

                PageMsg msg ->
                    onPageMsg data msg tab

                GoAddress url ->
                    onGoAddress data url model.me tabId tab

                Fetched response ->
                    onFetched response tab

                Crack nip ->
                    onCrack data nip tab

                AnyMap _ ->
                    Update.fromModel tab

                Login nip password ->
                    onLogin data nip password model.me tabId tab

                LoginFailed ->
                    Update.fromModel tab

        setThisTab tab_ =
            { model | tabs = (setTab tabId tab_ model.tabs) }
    in
        result
            |> Update.mapModel setThisTab
            |> Update.mapCmd (SomeTabMsg tabId)



-- tabs internals


onPageMsg :
    Game.Data
    -> Pages.Msg
    -> Tab
    -> TabUpdateResponse
onPageMsg data msg tab =
    Update.child
        { get = .page
        , set = (\page tab -> { tab | page = page })
        , toMsg = PageMsg
        , update = (Pages.update data)
        }
        msg
        tab


onUpdateAddress : URL -> Tab -> TabUpdateResponse
onUpdateAddress newAddr tab =
    { tab | addressBar = newAddr }
        |> Update.fromModel


onGoPrevious : Tab -> TabUpdateResponse
onGoPrevious =
    gotoPreviousPage >> Update.fromModel


onGoNext : Tab -> TabUpdateResponse
onGoNext =
    gotoNextPage >> Update.fromModel


onFetched : Web.Response -> Tab -> TabUpdateResponse
onFetched response tab =
    let
        ( url, pageModel ) =
            case response of
                Web.PageLoaded site ->
                    ( site.url, Pages.initialModel site )

                Web.PageNotFound url ->
                    ( url, Pages.NotFoundModel { url = url } )

                Web.ConnectionError url ->
                    -- TODO: Change to some "failed" page
                    ( url, Pages.BlankModel )

        isLoadingThisRequest =
            (Pages.isLoading <| getPage tab)
                && (getURL tab == url)
    in
        if (isLoadingThisRequest) then
            tab
                |> gotoPage url pageModel
                |> Update.fromModel
        else
            Update.fromModel tab


onCrack : Game.Data -> NIP -> Tab -> TabUpdateResponse
onCrack data nip tab =
    let
        serverId =
            Game.getID data

        dispatch =
            Dispatch.processes serverId <|
                Processes.StartBruteforce nip
    in
        ( tab, Cmd.none, dispatch )


onGoAddress :
    Game.Data
    -> String
    -> Config
    -> Int
    -> Tab
    -> TabUpdateResponse
onGoAddress data url { sessionId, windowId, context } tabId tab =
    let
        networkId =
            data
                |> Game.getServer
                |> Servers.getNIP
                |> Tuple.first

        serverId =
            Game.getID data

        requester =
            { sessionId = sessionId
            , windowId = windowId
            , context = context
            , tabId = tabId
            }

        dispatch =
            Web.FetchUrl serverId url networkId requester
                |> Dispatch.web

        tab_ =
            gotoPage url (Pages.LoadingModel url) tab
    in
        ( tab_, Cmd.none, dispatch )


onLogin :
    Game.Data
    -> NIP
    -> String
    -> Config
    -> Int
    -> Tab
    -> TabUpdateResponse
onLogin data nip password { sessionId, windowId, context } tabId tab =
    let
        requester =
            { sessionId = sessionId
            , windowId = windowId
            , context = context
            , tabId = tabId
            }

        serverId =
            Game.getID data

        dispatch =
            Dispatch.web <|
                Web.Login serverId nip password requester
    in
        ( tab, Cmd.none, dispatch )
