module OS.Header.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Storyline as Storyline
import Core.Dispatch.Account as Account
import Core.Dispatch.Servers as Servers
import Core.Dispatch.Notifications as Notifications
import Game.Data as Game
import Game.Models as Game
import Game.Meta.Types.Context exposing (Context)
import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Shared as Servers
import Game.Servers.Models as Servers
import Game.Storyline.Models as Storyline
import OS.Header.Messages exposing (..)
import OS.Header.Models exposing (..)
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Servers.Hardware.Models as Hardware
import Game.Notifications.Models as NotificingOpen


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Data -> Msg -> Model -> UpdateResponse
update data msg model =
    case msg of
        Logout ->
            onLogout model

        ToggleMenus next ->
            onToggleMenus next model

        MouseEnterDropdown ->
            onMouseEnterDropdown model

        MouseLeavesDropdown ->
            onMouseLeavesDropdown model

        SelectGateway cid ->
            onSelectGateway data cid model

        SelectBounce id ->
            onSelectBounce data id model

        SelectEndpoint cid ->
            onSelectEndpoint data cid model

        SelectNIP nip ->
            onSelectNIP data nip model

        ContextTo context ->
            onContextTo context model

        CheckMenus ->
            onCheckMenus model

        ToggleCampaign ->
            onTogglecampaign model

        ServerReadAll cid ->
            onServerReadAll cid model

        ChatReadAll ->
            Update.fromModel model

        AccountReadAll ->
            onAccountReadAll model


onLogout : Model -> UpdateResponse
onLogout model =
    let
        dispatch =
            Dispatch.account Account.Logout
    in
        ( model, Cmd.none, dispatch )


onToggleMenus : OpenMenu -> Model -> UpdateResponse
onToggleMenus next ({ openMenu } as model) =
    let
        openMenu_ =
            if (openMenu /= NothingOpen && openMenu == next) then
                NothingOpen
            else
                next
    in
        Update.fromModel
            { model | openMenu = openMenu_ }


onMouseEnterDropdown : Model -> UpdateResponse
onMouseEnterDropdown model =
    Update.fromModel
        { model | mouseSomewhereInside = True }


onMouseLeavesDropdown : Model -> UpdateResponse
onMouseLeavesDropdown model =
    Update.fromModel
        { model | mouseSomewhereInside = False }


onSelectGateway : Game.Data -> Maybe Servers.CId -> Model -> UpdateResponse
onSelectGateway data cid model =
    let
        dispatch =
            case cid of
                Just cid ->
                    Dispatch.batch
                        [ -- Change selected server
                          Dispatch.account <| Account.SetGateway cid

                        -- Switch game mode depending on Server.type
                        , switchGameMode data cid
                        ]

                Nothing ->
                    Dispatch.none

        model_ =
            { model | openMenu = NothingOpen }
    in
        ( model_, Cmd.none, dispatch )


onSelectBounce : Game.Data -> Maybe String -> Model -> UpdateResponse
onSelectBounce data id model =
    let
        dispatch =
            Dispatch.server
                (Game.getActiveCId data)
                (Servers.SetBounce id)

        model_ =
            { model | openMenu = NothingOpen }
    in
        ( model_, Cmd.none, dispatch )


onSelectEndpoint : Game.Data -> Maybe Servers.CId -> Model -> UpdateResponse
onSelectEndpoint data cid model =
    let
        dispatch =
            Dispatch.account <| Account.SetEndpoint cid

        model_ =
            { model | openMenu = NothingOpen }
    in
        ( model_, Cmd.none, dispatch )


onContextTo : Context -> Model -> UpdateResponse
onContextTo context model =
    let
        dispatch =
            Dispatch.account <| Account.SetContext context
    in
        ( model, Cmd.none, dispatch )


onCheckMenus : Model -> UpdateResponse
onCheckMenus ({ mouseSomewhereInside } as model) =
    let
        model_ =
            if not mouseSomewhereInside then
                { model | openMenu = NothingOpen }
            else
                model
    in
        Update.fromModel model_


onTogglecampaign : Model -> UpdateResponse
onTogglecampaign model =
    let
        dispatch =
            Dispatch.storyline <| Storyline.Toggle
    in
        ( model, Cmd.none, dispatch )


onServerReadAll : Servers.CId -> Model -> UpdateResponse
onServerReadAll cid model =
    let
        dispatch =
            Dispatch.notifications <| Notifications.ReadAllServer cid
    in
        ( model, Cmd.none, dispatch )


onAccountReadAll : Model -> UpdateResponse
onAccountReadAll model =
    let
        dispatch =
            Dispatch.notifications Notifications.ReadAllAccount
    in
        ( model, Cmd.none, dispatch )


onSelectNIP : Game.Data -> NIP -> Model -> UpdateResponse
onSelectNIP data nip model =
    let
        dispatcher =
            data
                |> Game.getActiveCId
                |> Dispatch.server

        dispatch =
            dispatcher <| Servers.SetActiveNIP nip
    in
        ( model, Cmd.none, dispatch )



-- internals


switchGameMode : Game.Data -> Servers.CId -> Dispatch
switchGameMode data cid =
    let
        server =
            data
                |> Game.getGame
                |> Game.getServers
                |> Servers.get cid

        isStoryModeActive =
            data
                |> Game.getGame
                |> Game.getStory
                |> Storyline.isActive
    in
        case server of
            Just server ->
                case server.type_ of
                    Servers.DesktopCampaign ->
                        if isStoryModeActive then
                            Dispatch.none
                        else
                            Dispatch.storyline <| Storyline.Toggle

                    Servers.Desktop ->
                        if isStoryModeActive then
                            Dispatch.storyline <| Storyline.Toggle
                        else
                            Dispatch.none

                    Servers.Mobile ->
                        if isStoryModeActive then
                            Dispatch.storyline <| Storyline.Toggle
                        else
                            Dispatch.none

            Nothing ->
                Dispatch.none
