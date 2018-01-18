module Apps.Browser.Update exposing (update)

import Dict
import Native.Panic
import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Core.Dispatch.Account as Account
import Core.Dispatch.OS as OS
import Core.Error as Error
import Game.Data as Game
import Game.Models
import Game.Servers.Models as Servers
import Game.Servers.Shared exposing (StorageId)
import Game.Servers.Filesystem.Models as Filesystem
import Game.Web.Types as Web
import Game.Meta.Types.Context exposing (Context(..))
import Game.Meta.Types.Network as Network
import Apps.Reference exposing (..)
import Apps.Apps as Apps
import Apps.Browser.Pages.Webserver.Update as Webserver
import Apps.Browser.Pages.Bank.Update as Bank
import Apps.Browser.Pages.DownloadCenter.Update as DownloadCenter
import Apps.Browser.Menu.Messages as Menu
import Apps.Browser.Menu.Update as Menu
import Apps.Browser.Menu.Actions as Menu
import Apps.Browser.Pages.Configs exposing (..)
import Apps.Browser.Messages exposing (..)
import Apps.Browser.Models exposing (..)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


type alias TabUpdateResponse =
    ( Tab, Cmd Msg, Dispatch )


update : Game.Data -> Msg -> Model -> UpdateResponse
update data msg model =
    case msg of
        -- menu
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            onMenuMsg data msg model

        LaunchApp context params ->
            onLaunchApp data context params model

        ChangeTab tabId ->
            Update.fromModel <| goTab tabId model

        NewTabIn url ->
            onNewTabIn data url model

        PublicDownload nip entry ->
            update data
                (ActiveTabMsg <| EnterModal <| Just <| ForDownload nip entry)
                model

        ReqDownload source file storage ->
            onReqDownload data source file storage model

        HandlePasswordAcquired event ->
            onEveryTabMsg data (Cracked event.nip event.password) model

        ActiveTabMsg msg ->
            updateSomeTabMsg data model.nowTab msg model

        SomeTabMsg tabId msg ->
            updateSomeTabMsg data tabId msg model

        EveryTabMsg msg ->
            onEveryTabMsg data msg model



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


onLaunchApp : Game.Data -> Context -> Params -> Model -> UpdateResponse
onLaunchApp data context (OpenAtUrl url) model =
    let
        filter id tab =
            tab.addressBar == url

        maybeId =
            model.tabs
                |> Dict.filter filter
                |> Dict.keys
                |> List.head
    in
        case maybeId of
            Just id ->
                Update.fromModel <| goTab id model

            Nothing ->
                onNewTabIn data url model


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
    in
        ( model_, cmd, dispatch )


onReqDownload :
    Game.Data
    -> Network.NIP
    -> Filesystem.FileEntry
    -> StorageId
    -> Model
    -> UpdateResponse
onReqDownload data source file storage model =
    let
        ( me, _ ) =
            data
                |> Game.getGame
                |> Game.Models.unsafeGetGateway

        startMsg =
            Servers.NewPublicDownloadProcess source storage file

        dispatch =
            Dispatch.processes me startMsg

        model_ =
            model
                |> getNowTab
                |> leaveModal
                |> flip setNowTab model
    in
        ( model_, Cmd.none, dispatch )



-- tabs


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

        setThisTab tab_ =
            { model | tabs = (setTab tabId tab_ model.tabs) }
    in
        model
            |> processTabMsg data tabId msg tab
            |> Update.mapModel setThisTab


onEveryTabMsg : Game.Data -> TabMsg -> Model -> UpdateResponse
onEveryTabMsg data msg model =
    model.tabs
        |> Dict.foldl (reduceTabMsg data msg model)
            ( Dict.empty, Cmd.none, Dispatch.none )
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
            processTabMsg data tabId msg tab model

        tabs_ =
            Dict.insert tabId tab tabs

        cmd =
            Cmd.batch
                [ cmd0
                , cmd1
                ]

        dispatch =
            Dispatch.batch [ dispatch0, dispatch1 ]
    in
        ( tabs_, cmd, dispatch )


processTabMsg :
    Game.Data
    -> Int
    -> TabMsg
    -> Tab
    -> Model
    -> TabUpdateResponse
processTabMsg data tabId msg tab model =
    case msg of
        GoPrevious ->
            Update.fromModel <| gotoPreviousPage tab

        GoNext ->
            Update.fromModel <| gotoNextPage tab

        UpdateAddress url ->
            Update.fromModel { tab | addressBar = url }

        EnterModal modal ->
            Update.fromModel { tab | modal = modal }

        HandleFetched response ->
            onHandleFetched response tab

        GoAddress url ->
            onGoAddress data url model.me tabId tab

        AnyMap nip ->
            -- TODO: implementation pending
            Update.fromModel tab

        NewApp params ->
            ( tab
            , Cmd.none
            , Dispatch.os <| OS.NewApp Nothing Nothing params
            )

        SelectEndpoint ->
            ( tab
            , Cmd.none
            , Dispatch.account <| Account.SetContext Endpoint
            )

        Login nip password ->
            onLogin data nip password model.me tabId tab

        Logout ->
            -- TODO #285
            Update.fromModel tab

        LoginFailed ->
            -- TODO: forward error
            Update.fromModel tab

        Crack nip ->
            onCrack data nip tab

        Cracked _ _ ->
            -- TODO: forward success
            Update.fromModel tab

        -- site msgs
        _ ->
            onPageMsg data msg tab


onHandleFetched : Web.Response -> Tab -> TabUpdateResponse
onHandleFetched response tab =
    let
        ( url, pageModel ) =
            case response of
                Web.PageLoaded site ->
                    ( site.url, initialPage site )

                Web.PageNotFound url ->
                    ( url, NotFoundModel { url = url } )

                Web.ConnectionError url ->
                    -- TODO: Change to some "failed" page
                    ( url, BlankModel )

        isLoadingThisRequest =
            (isLoading <| getPage tab)
                && (getURL tab == url)
    in
        if (isLoadingThisRequest) then
            tab
                |> gotoPage url pageModel
                |> Update.fromModel
        else
            Update.fromModel tab


onGoAddress :
    Game.Data
    -> String
    -> Reference
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
                |> Servers.get cid
                |> Maybe.map
                    (Servers.getActiveNIP
                        >> Network.getId
                    )
                |> Maybe.withDefault "::"

        requester =
            { sessionId = sessionId
            , windowId = windowId
            , context = context
            , tabId = tabId
            }

        dispatch =
            Dispatch.server cid <|
                Servers.FetchUrl url
                    networkId
                    requester

        tab_ =
            gotoPage url (LoadingModel url) tab
    in
        ( tab_, Cmd.none, dispatch )


onLogin :
    Game.Data
    -> Network.NIP
    -> String
    -> Reference
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
            Servers.get (Game.getActiveCId data) servers
                |> Maybe.map (Servers.getActiveNIP)

        remoteIp =
            Network.getIp remoteNip

        dispatch =
            case gatewayNip of
                Just gatewayNip ->
                    Dispatch.servers <|
                        Servers.Login gatewayNip remoteIp password requester

                Nothing ->
                    -- You don't have a Gateway?
                    "A gateway is required for everything!"
                        |> Error.astralProj
                        |> uncurry Native.Panic.crash
    in
        ( tab, Cmd.none, dispatch )


onCrack : Game.Data -> Network.NIP -> Tab -> TabUpdateResponse
onCrack data nip tab =
    let
        serverId =
            Game.getActiveCId data

        targetIp =
            Network.getIp nip

        dispatch =
            Dispatch.processes serverId <|
                Servers.NewBruteforceProcess targetIp
    in
        ( tab, Cmd.none, dispatch )


onPageMsg : Game.Data -> TabMsg -> Tab -> TabUpdateResponse
onPageMsg data msg tab =
    let
        ( page_, cmd, dispatch ) =
            updatePage data msg tab.page

        tab_ =
            { tab | page = page_ }
    in
        ( tab_, cmd, dispatch )


updatePage :
    Game.Data
    -> TabMsg
    -> Page
    -> ( Page, Cmd Msg, Dispatch )
updatePage data msg tab =
    case ( tab, msg ) of
        ( WebserverModel page, WebserverMsg msg ) ->
            Update.mapModel WebserverModel <|
                Webserver.update webserverConfig data msg page

        ( BankModel page, BankMsg msg ) ->
            Update.mapModel BankModel <|
                Bank.update bankConfig data msg page

        ( DownloadCenterModel page, DownloadCenterMsg msg ) ->
            Update.mapModel DownloadCenterModel <|
                DownloadCenter.update downloadCenterConfig data msg page

        _ ->
            Update.fromModel tab
