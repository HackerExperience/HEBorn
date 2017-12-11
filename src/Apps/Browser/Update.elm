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
import Game.Web.Messages as Web
import Game.Web.Types as Web
import Game.Meta.Types.Network as Network
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
import Game.Meta.Types.Context exposing (Context(Endpoint))


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

        PublicDownload source file storage ->
            onReqDownload data source file storage model

        HandlePasswordAcquired event ->
            onEveryTabMsg data (Cracked event.nip event.password) model



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
            Dispatch.os <| OS.OpenApp (Just Endpoint) app
    in
        ( model, Cmd.none, dispatch )


onSelectEndpoint : Model -> UpdateResponse
onSelectEndpoint model =
    let
        dispatch =
            Dispatch.account <|
                Account.SetContext Endpoint
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

        Crack nip ->
            onCrack data nip tab

        AnyMap _ ->
            Update.fromModel tab

        Login nip password ->
            onLogin data nip password model.me tabId tab

        Cracked _ _ ->
            Update.fromModel tab

        LoginFailed ->
            Update.fromModel tab

        HandleFetched response ->
            onHandleFetched response tab

        EnterModal newModal ->
            onEnterModal newModal tab



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


onHandleFetched : Web.Response -> Tab -> TabUpdateResponse
onHandleFetched response tab =
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


onEnterModal : Maybe ModalAction -> Tab -> TabUpdateResponse
onEnterModal newModal tab =
    { tab | modal = newModal }
        |> Update.fromModel
