module Apps.Browser.Update exposing (update)

import Dict
import Utils.Update as Update
import Game.Data as Game
import Game.Models
import Game.Servers.Models as Servers
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Web.Messages as Web
import Game.Web.Types as Web
import Game.Network.Types as Network
import Apps.Config exposing (..)
import Apps.Browser.Messages exposing (..)
import Apps.Browser.Models exposing (..)
import Apps.Browser.Pages.Messages as Pages
import Apps.Browser.Pages.Update as Pages
import Apps.Browser.Pages.Models as Pages
import Apps.Browser.Menu.Messages as Menu
import Apps.Browser.Menu.Update as Menu
import Apps.Browser.Menu.Actions as Menu
import Apps.Apps as Apps
import Game.Account.Messages as Account
import Game.Meta.Types exposing (Context(Endpoint))
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

        EveryTabMsg msg ->
            onEveryTabMsg data msg model

        -- Browser
        NewTabIn url ->
            onNewTabIn data url model

        ChangeTab tabId ->
            goTab tabId model
                |> Update.fromModel

        OpenApp app ->
            onOpenApp app model

        SelectEndpoint ->
            onSelectEndpoint model

        Logout ->
            onLogout model

        HandlePasswordAcquired event ->
            onEveryTabMsg data (Cracked event.nip event.password) model

        PublicDownload source file ->
            onReqDownload data source file model



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


onOpenApp : Apps.App -> Model -> UpdateResponse
onOpenApp app model =
    let
        dispatch =
            Dispatch.openApp (Just Endpoint) app
    in
        ( model, Cmd.none, dispatch )


onSelectEndpoint : Model -> UpdateResponse
onSelectEndpoint model =
    let
        dispatch =
            Dispatch.account <|
                Account.ContextTo Endpoint
    in
        ( model, Cmd.none, dispatch )


onLogout : Model -> UpdateResponse
onLogout model =
    -- TODO #285
    Update.fromModel model


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
            processTabMsg data tabId tab msg model

        setThisTab tab_ =
            { model | tabs = (setTab tabId tab_ model.tabs) }
    in
        result
            |> Update.mapModel setThisTab
            |> Update.mapCmd (SomeTabMsg tabId)


onEveryTabMsg : Game.Data -> TabMsg -> Model -> UpdateResponse
onEveryTabMsg data msg model =
    model.tabs
        |> Dict.foldl (reduceTabMsg data msg model) ( Dict.empty, Cmd.none, Dispatch.none )
        |> Update.mapModel (\tabs_ -> { model | tabs = tabs_ })


reduceTabMsg :
    Game.Data
    -> TabMsg
    -> Model
    -> Int
    -> Tab
    -> ( Tabs, Cmd Msg, Dispatch )
    -> ( Tabs, Cmd Msg, Dispatch )
reduceTabMsg data msg model tabId tab ( tabs, cmd0, dispatch0 ) =
    let
        ( tab_, cmd1, dispatch1 ) =
            processTabMsg data tabId tab msg model

        tabs_ =
            Dict.insert tabId tab tabs

        cmd =
            Cmd.batch
                [ cmd0
                , Cmd.map (SomeTabMsg tabId) cmd1
                ]

        dispatch =
            Dispatch.batch [ dispatch0, dispatch1 ]
    in
        ( tabs_, cmd, dispatch )


onReqDownload :
    Game.Data
    -> Network.NIP
    -> Filesystem.ForeignFileBox
    -> Model
    -> UpdateResponse
onReqDownload data source file model =
    let
        ( me, _ ) =
            data
                |> Game.getGame
                |> Game.Models.unsafeGetGateway

        startMsg =
            Processes.StartPublicDownload source file "storage id"

        dispatch =
            Dispatch.processes me startMsg
    in
        ( model, Cmd.none, dispatch )


processTabMsg :
    Game.Data
    -> Int
    -> Tab
    -> TabMsg
    -> Model
    -> TabUpdateResponse
processTabMsg data tabId tab msg model =
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

        Cracked _ _ ->
            Update.fromModel tab



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


onCrack : Game.Data -> Network.NIP -> Tab -> TabUpdateResponse
onCrack data nip tab =
    let
        serverId =
            Game.getActiveCId data

        targetIp =
            Network.getIp nip

        dispatch =
            Dispatch.processes serverId <|
                Processes.StartBruteforce targetIp
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
        cid =
            Game.getActiveCId data

        servers =
            data
                |> Game.getGame
                |> Game.Models.getServers

        networkId =
            servers
                |> Servers.getNIP cid
                |> Network.getId

        requester =
            { sessionId = sessionId
            , windowId = windowId
            , context = context
            , tabId = tabId
            }

        dispatch =
            Dispatch.web <|
                Web.FetchUrl url networkId cid requester

        tab_ =
            gotoPage url (Pages.LoadingModel url) tab
    in
        ( tab_, Cmd.none, dispatch )


onLogin :
    Game.Data
    -> Network.NIP
    -> String
    -> Config
    -> Int
    -> Tab
    -> TabUpdateResponse
onLogin data remoteNip password { sessionId, windowId, context } tabId tab =
    let
        servers =
            data
                |> Game.getGame
                |> Game.Models.getServers

        requester =
            { sessionId = sessionId
            , windowId = windowId
            , context = context
            , tabId = tabId
            }

        gatewayNip =
            Servers.getNIP (Game.getActiveCId data) servers

        remoteIp =
            Network.getIp remoteNip

        dispatch =
            Dispatch.web <|
                Web.Login gatewayNip remoteIp password requester
    in
        ( tab, Cmd.none, dispatch )
