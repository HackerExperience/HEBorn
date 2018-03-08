module Apps.Browser.Update exposing (update)

import Dict
import Utils.React as React exposing (React)
import Game.Account.Finances.Shared as Finances
import Game.Account.Finances.Requests.Login as BankLoginRequest
import Game.Account.Finances.Requests.Transfer as BankTransferRequest
import Game.Servers.Models as Servers
import Game.Servers.Shared exposing (StorageId)
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Requests.Browse as BrowseRequest exposing (browseRequest)
import Game.Meta.Types.Apps.Desktop exposing (Reference, Requester)
import Game.Meta.Types.Context exposing (Context(..))
import Game.Meta.Types.Network as Network
import Apps.Browser.Pages.Webserver.Update as Webserver
import Apps.Browser.Pages.Bank.Messages as Bank
import Apps.Browser.Pages.Bank.Update as Bank
import Apps.Browser.Pages.DownloadCenter.Update as DownloadCenter
import Apps.Browser.Messages exposing (..)
import Apps.Browser.Config exposing (..)
import Apps.Browser.Models exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


type alias TabUpdateResponse msg =
    ( Tab, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        LaunchApp params ->
            onLaunchApp config params model

        ChangeTab tabId ->
            ( goTab tabId model, React.none )

        NewTab ->
            ( addTab model, React.none )

        NewTabIn url ->
            onNewTabIn config url model

        DeleteTab tabId ->
            ( deleteTab tabId model, React.none )

        PublicDownload nip entry ->
            update config
                (ActiveTabMsg <| EnterModal <| Just <| ForDownload nip entry)
                model

        ReqDownload source file storage ->
            onReqDownload config source file storage model

        HandlePasswordAcquired event ->
            onEveryTabMsg config (Cracked event.nip event.password) model

        ActiveTabMsg msg ->
            updateSomeTabMsg config model.nowTab msg model

        SomeTabMsg tabId msg ->
            updateSomeTabMsg config tabId msg model

        EveryTabMsg msg ->
            onEveryTabMsg config msg model

        BankLogin request ->
            onBankLogin config request model.me model

        BankTransfer request ->
            onBankTransfer config request model.me model

        BankLogout ->
            onBankLogout config model



-- browser internals


onLaunchApp : Config msg -> Params -> Model -> UpdateResponse msg
onLaunchApp config (OpenAtUrl url) model =
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
                ( goTab id model, React.none )

            Nothing ->
                onNewTabIn config url model


onNewTabIn : Config msg -> URL -> Model -> UpdateResponse msg
onNewTabIn config url model =
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

        ( tab_, react ) =
            onGoAddress config url model.me tabId tab

        model_ =
            setNowTab tab_ goTabModel
    in
        ( model_, react )


onReqDownload :
    Config msg
    -> Network.NIP
    -> Filesystem.FileEntry
    -> StorageId
    -> Model
    -> UpdateResponse msg
onReqDownload { onNewPublicDownload } source file storage model =
    file
        |> onNewPublicDownload source storage
        |> React.msg
        |> (,) model


onBankLogin :
    Config msg
    -> BankLoginRequest.Payload
    -> Reference
    -> Model
    -> UpdateResponse msg
onBankLogin { onBankAccountLogin } request reference model =
    model.nowTab
        |> Requester reference
        |> onBankAccountLogin request
        |> React.msg
        |> (,) model


onBankTransfer :
    Config msg
    -> BankTransferRequest.Payload
    -> Reference
    -> Model
    -> UpdateResponse msg
onBankTransfer { onBankAccountTransfer } request reference model =
    model.nowTab
        |> Requester reference
        |> onBankAccountTransfer request
        |> React.msg
        |> (,) model


onBankLogout : Config msg -> Model -> UpdateResponse msg
onBankLogout config model =
    -- TODO: Bank Logout Request
    ( model, React.none )



-- tabs


updateSomeTabMsg :
    Config msg
    -> Int
    -> TabMsg
    -> Model
    -> UpdateResponse msg
updateSomeTabMsg config tabId msg model =
    let
        tab =
            getTab tabId model.tabs

        setThisTab tab_ =
            { model | tabs = (setTab tabId tab_ model.tabs) }

        ( model_, react ) =
            processTabMsg config tabId msg tab model
    in
        Tuple.mapFirst setThisTab ( model_, react )


onEveryTabMsg : Config msg -> TabMsg -> Model -> UpdateResponse msg
onEveryTabMsg config msg model =
    model.tabs
        |> Dict.foldl (reduceTabMsg config msg model)
            ( Dict.empty, React.none )
        |> Tuple.mapFirst (\tabs_ -> { model | tabs = tabs_ })


reduceTabMsg :
    Config msg
    -> TabMsg
    -> Model
    -> Int
    -> Tab
    -> ( Tabs, React msg )
    -> ( Tabs, React msg )
reduceTabMsg config msg model tabId tab ( tabs, react0 ) =
    let
        ( tab_, react1 ) =
            processTabMsg config tabId msg tab model

        tabs_ =
            Dict.insert tabId tab tabs

        react =
            React.batch
                config.batchMsg
                [ react0, react1 ]
    in
        ( tabs_, react )


processTabMsg :
    Config msg
    -> Int
    -> TabMsg
    -> Tab
    -> Model
    -> TabUpdateResponse msg
processTabMsg config tabId msg tab model =
    case msg of
        GoPrevious ->
            ( gotoPreviousPage tab, React.none )

        GoNext ->
            ( gotoNextPage tab, React.none )

        UpdateAddress url ->
            ( { tab | addressBar = url }, React.none )

        EnterModal modal ->
            ( { tab | modal = modal }, React.none )

        HandleBrowse response ->
            handleBrowse response tab

        GoAddress url ->
            onGoAddress config url model.me tabId tab

        AnyMap nip ->
            -- TODO: implementation pending
            ( tab, React.none )

        NewApp params ->
            ( tab
            , React.none
              --, React.msg <| config.onNewApp Nothing params
            )

        SelectEndpoint ->
            ( tab
            , React.msg <| config.onSetContext Endpoint
            )

        HandleBankLogin data ->
            handleBankLogin config tabId tab data model

        HandleBankTransfer data ->
            handleBankTransfer config tabId tab data model

        Login nip password ->
            onLogin config nip password model.me tabId tab

        HandleLoginFailed ->
            handleLoginFailed tab

        Crack nip ->
            onCrack config nip tab

        Cracked _ _ ->
            -- TODO: forward success
            ( tab, React.none )

        -- site msgs
        _ ->
            onPageMsg config msg tab


handleBrowse : BrowseRequest.Data -> Tab -> TabUpdateResponse msg
handleBrowse data tab =
    let
        ( url, pageModel ) =
            case data of
                Ok site ->
                    ( site.url, initialPage site )

                Err error ->
                    case error of
                        BrowseRequest.PageNotFound url ->
                            ( url, NotFoundModel { url = url } )

                        BrowseRequest.ConnectionError url ->
                            -- TODO: Change to some "failed" page
                            ( url, BlankModel )

        isLoadingThisRequest =
            (isLoading <| getPage tab) && (getURL tab == url)

        tab_ =
            if isLoadingThisRequest then
                gotoPage url pageModel tab
            else
                tab
    in
        React.update tab_


handleLoginFailed : Tab -> TabUpdateResponse msg
handleLoginFailed tab =
    { tab
        | page =
            case tab.page of
                WebserverModel model ->
                    { model | loginFailed = True }
                        |> WebserverModel

                DownloadCenterModel model ->
                    { model | loginFailed = True }
                        |> DownloadCenterModel

                _ ->
                    tab.page
        , modal = Just ImpossibleToLogin
    }
        |> flip (,) React.none


onGoAddress :
    Config msg
    -> String
    -> Reference
    -> Int
    -> Tab
    -> TabUpdateResponse msg
onGoAddress config url reference tabId tab =
    let
        ( cid, server ) =
            config.activeServer

        networkId =
            server
                |> Servers.getActiveNIP
                |> Network.getId

        tab_ =
            gotoPage url (LoadingModel url) tab

        react =
            config
                |> browseRequest url networkId cid
                |> Cmd.map (HandleBrowse >> SomeTabMsg tabId >> config.toMsg)
                |> React.cmd
    in
        ( tab_, react )


onLogin :
    Config msg
    -> Network.NIP
    -> String
    -> Reference
    -> Int
    -> Tab
    -> TabUpdateResponse msg
onLogin config remoteNip password reference tabId tab =
    tabId
        |> Requester reference
        |> config.onLogin
            (Servers.getActiveNIP <| Tuple.second config.activeGateway)
            (Network.getIp remoteNip)
            password
        |> React.msg
        |> (,) tab


onCrack : Config msg -> Network.NIP -> Tab -> TabUpdateResponse msg
onCrack { onNewBruteforceProcess } nip tab =
    nip
        |> Network.getIp
        |> onNewBruteforceProcess
        |> React.msg
        |> (,) tab


onPageMsg : Config msg -> TabMsg -> Tab -> TabUpdateResponse msg
onPageMsg config msg tab =
    let
        ( page_, react ) =
            updatePage config msg tab.page

        tab_ =
            { tab | page = page_ }
    in
        ( tab_, react )


updatePage :
    Config msg
    -> TabMsg
    -> Page
    -> ( Page, React msg )
updatePage config msg tab =
    case ( tab, msg ) of
        ( WebserverModel page, WebserverMsg msg ) ->
            let
                ( tab_, react ) =
                    Webserver.update (webserverConfig config) msg page
            in
                ( WebserverModel tab_, react )

        ( BankModel page, BankMsg msg ) ->
            let
                ( tab_, react ) =
                    Bank.update (bankConfig config) msg page
            in
                ( BankModel tab_, react )

        ( DownloadCenterModel page, DownloadCenterMsg msg ) ->
            let
                ( tab_, react ) =
                    DownloadCenter.update (downloadCenterConfig config) msg page
            in
                ( DownloadCenterModel tab_, react )

        _ ->
            ( tab, React.none )


handleBankLogin :
    Config msg
    -> Int
    -> Tab
    -> BankLoginRequest.Data
    -> Model
    -> TabUpdateResponse msg
handleBankLogin config tabId tab data model =
    let
        page =
            (getTab tabId model.tabs).page

        ( pageModel, _ ) =
            case data of
                Ok accountData ->
                    updatePage config
                        (BankMsg <| Bank.HandleLogin accountData)
                        page

                Err _ ->
                    updatePage config (BankMsg Bank.HandleLoginError) page
    in
        ( { tab | page = pageModel }, React.none )


handleBankTransfer :
    Config msg
    -> Int
    -> Tab
    -> BankTransferRequest.Data
    -> Model
    -> TabUpdateResponse msg
handleBankTransfer config tabId tab data model =
    let
        page =
            (getTab tabId model.tabs).page

        ( pageModel, _ ) =
            case data of
                Ok () ->
                    updatePage config (BankMsg Bank.HandleTransfer) page

                Err _ ->
                    updatePage config (BankMsg Bank.HandleTransferError) page
    in
        ( { tab | page = pageModel }, React.none )
