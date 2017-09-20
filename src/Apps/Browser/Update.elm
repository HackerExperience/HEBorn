module Apps.Browser.Update exposing (update)

import Utils.Update as Update
import Game.Data as Game
import Game.Servers.Models as Servers
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Processes.Models as Processes
import Game.Web.Messages as Web
import Game.Web.DNS exposing (..)
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
            onSomeTabMsg data model.nowTab msg model

        SomeTabMsg tabK msg ->
            onSomeTabMsg data tabK msg model

        Crack ip ->
            onCrack data ip model

        -- Browser
        NewTabIn url ->
            onNewTabIn data url model

        ChangeTab tabK ->
            goTab tabK model
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

        tabK =
            goTabModel.nowTab

        tab =
            getTab tabK goTabModel.tabs

        ( tab_, cmd, dispatch ) =
            onGoAddress data url model.me tabK tab

        model_ =
            setNowTab tab_ goTabModel

        cmd_ =
            Cmd.map (SomeTabMsg tabK) cmd
    in
        ( model_, cmd_, dispatch )


onSomeTabMsg :
    Game.Data
    -> Int
    -> TabMsg
    -> Model
    -> UpdateResponse
onSomeTabMsg data tabK msg model =
    let
        tab =
            getTab tabK model.tabs

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
                    onGoAddress data url model.me tabK tab

                Fetched response ->
                    onFetched response tab

        setThisTab tab_ =
            { model | tabs = (setTab tabK tab_ model.tabs) }
    in
        result
            |> Update.mapModel setThisTab
            |> Update.mapCmd (SomeTabMsg tabK)


onCrack : Game.Data -> String -> Model -> UpdateResponse
onCrack data ip ({ me } as model) =
    let
        serverId =
            Game.getID data

        network =
            data
                |> Game.getServer
                |> Servers.getNIP
                |> Tuple.first

        dispatch =
            Processes.Start
                Processes.Cracker
                serverId
                ( network, ip )
                ( Nothing, Nothing, "Palatura" )
                |> Dispatch.processes serverId
    in
        ( model, Cmd.none, dispatch )



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


onFetched : Response -> Tab -> TabUpdateResponse
onFetched response tab =
    let
        ( url, pageModel ) =
            case response of
                ConnectionError url ->
                    -- TODO: Change to some "failed" page
                    ( url, Pages.BlankModel )

                NotFounded url ->
                    ( url, Pages.NotFoundModel { url = url } )

                Okay site ->
                    ( site.url, Pages.initialModel site )

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


onGoAddress :
    Game.Data
    -> String
    -> Config
    -> Int
    -> Tab
    -> TabUpdateResponse
onGoAddress data url { sessionId, windowId, context } tabK tab =
    let
        serverId =
            Game.getID data

        requester =
            { sessionId = sessionId
            , windowId = windowId
            , context = context
            , tabK = tabK
            }

        dispatch =
            Web.FetchUrl serverId url requester
                |> Dispatch.web

        tab_ =
            gotoPage url Pages.LoadingModel tab
    in
        ( tab_, Cmd.none, dispatch )
