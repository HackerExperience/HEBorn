module Apps.Browser.Update exposing (update)

import Utils.Update as Update
import Game.Data as Game
import Game.Servers.Models as Servers
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Processes.Models as Processes
import Game.Web.Messages as Web
import Game.Web.Types as Web
import Game.Network.Types as Network
import Apps.Config exposing (..)
import Apps.Browser.Pages.CommonActions as CommonActions exposing (CommonActions)
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

        setThisTab tab_ =
            { model | tabs = (setTab tabId tab_ model.tabs) }

        toUpdateResponse result =
            result
                |> Update.mapModel setThisTab
                |> Update.mapCmd (SomeTabMsg tabId)
    in
        case msg of
            PageMsg msg ->
                let
                    ( updateResponse, maybeCA ) =
                        onPageMsg data msg tab
                in
                    case maybeCA of
                        Just action ->
                            let
                                ( model0, cmd0, dispatch0 ) =
                                    toUpdateResponse updateResponse

                                ( model_, cmd1, dispatch1 ) =
                                    update data
                                        (commonActionToMsg tabId action)
                                        model0

                                cmd_ =
                                    Cmd.batch [ cmd0, cmd1 ]

                                dispatch_ =
                                    Dispatch.batch [ dispatch0, dispatch1 ]
                            in
                                ( model_, cmd_, dispatch_ )

                        Nothing ->
                            toUpdateResponse updateResponse

            UpdateAddress newAddr ->
                tab
                    |> onUpdateAddress newAddr
                    |> toUpdateResponse

            GoPrevious ->
                tab
                    |> onGoPrevious
                    |> toUpdateResponse

            GoNext ->
                tab
                    |> onGoNext
                    |> toUpdateResponse

            GoAddress url ->
                tab
                    |> onGoAddress data url model.me tabId
                    |> toUpdateResponse

            Fetched response ->
                tab
                    |> onFetched response
                    |> toUpdateResponse

            Crack nip ->
                tab
                    |> onCrack data nip
                    |> toUpdateResponse

            AnyMap _ ->
                Update.fromModel model

            Login nip password ->
                tab
                    |> onLogin data nip password model.me tabId
                    |> toUpdateResponse

            LoginFailed ->
                Update.fromModel model



-- tabs internals


onPageMsg :
    Game.Data
    -> Pages.Msg
    -> Tab
    -> ( TabUpdateResponse, Maybe CommonActions )
onPageMsg data msg tab =
    let
        ( ( page, cmd, dispatch ), maybeCommonAction ) =
            Pages.update data msg tab.page

        tab_ =
            { tab | page = page }

        cmd_ =
            Cmd.map PageMsg cmd
    in
        ( ( tab_, cmd_, dispatch ), maybeCommonAction )


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
            Game.getID data

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
        nip =
            Servers.toNip <| Game.getID data

        networkId =
            Network.getId nip

        networkIp =
            Network.getIp nip

        requester =
            { sessionId = sessionId
            , windowId = windowId
            , context = context
            , tabId = tabId
            }

        dispatch =
            Dispatch.web <|
                Web.FetchUrl url networkId networkIp requester

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
        requester =
            { sessionId = sessionId
            , windowId = windowId
            , context = context
            , tabId = tabId
            }

        gatewayNip =
            Game.getID data

        remoteIp =
            Network.getIp remoteNip

        dispatch =
            Dispatch.web <|
                Web.Login gatewayNip remoteIp password requester
    in
        ( tab, Cmd.none, dispatch )


commonActionToMsg : Int -> CommonActions -> Msg
commonActionToMsg tabId action =
    case action of
        CommonActions.GoAddress a ->
            SomeTabMsg tabId <| GoAddress a

        CommonActions.NewTabIn a ->
            NewTabIn a

        CommonActions.Crack nip ->
            SomeTabMsg tabId <| Crack nip

        CommonActions.AnyMap nip ->
            SomeTabMsg tabId <| AnyMap nip

        CommonActions.Login nip a ->
            SomeTabMsg tabId <| Login nip a
