module OS.Header.Update exposing (update)

import Utils.Cmd as Cmd
import Game.Meta.Types.Context exposing (Context)
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Servers.Shared as Servers
import Game.Servers.Models as Servers
import Game.Storyline.Models as Storyline
import OS.Header.Messages exposing (..)
import OS.Header.Models exposing (..)
import OS.Header.Config exposing (..)
import Game.Servers.Hardware.Models as Hardware


type alias UpdateResponse msg =
    ( Model, Cmd msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
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
            onSelectGateway config cid model

        SelectBounce id ->
            onSelectBounce config id model

        SelectEndpoint cid ->
            onSelectEndpoint config cid model

        SelectNIP nip ->
            onSelectNIP config nip model

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


onLogout : Config msg -> Model -> UpdateResponse msg
onLogout { onLogout } model =
    ( model, Cmd.fromMsg onLogout )


onToggleMenus : OpenMenu -> Model -> UpdateResponse msg
onToggleMenus next ({ openMenu } as model) =
    let
        openMenu_ =
            if (openMenu /= NothingOpen && openMenu == next) then
                NothingOpen
            else
                next

        model_ =
            { model | openMenu = openMenu_ }
    in
        ( model_, Cmd.none )


onMouseEnterDropdown : Model -> UpdateResponse msg
onMouseEnterDropdown model =
    let
        model_ =
            { model | mouseSomewhereInside = True }
    in
        ( model_, Cmd.none )


onMouseLeavesDropdown : Model -> UpdateResponse msg
onMouseLeavesDropdown model =
    let
        model_ =
            { model | mouseSomewhereInside = False }
    in
        ( model_, Cmd.none )


onSelectGateway : Config msg -> Maybe Servers.CId -> Model -> UpdateResponse msg
onSelectGateway { onSetGateway } cid model =
    let
        cmd =
            case cid of
                Just cid ->
                    cid
                        |> onSetGateway
                        |> Cmd.fromMsg

                Nothing ->
                    Cmd.none

        model_ =
            { model | openMenu = NothingOpen }
    in
        ( model_, cmd )


onSelectBounce : Config msg -> Maybe String -> Model -> UpdateResponse msg
onSelectBounce { onSetBounce } id model =
    let
        cmd =
            Cmd.fromMsg <| onSetBounce id

        model_ =
            { model | openMenu = NothingOpen }
    in
        ( model_, cmd )


onSelectEndpoint : Config msg -> Maybe Servers.CId -> Model -> UpdateResponse msg
onSelectEndpoint { onSetEndpoint } cid model =
    let
        dispatch =
            Cmd.fromMsg <| onSetEndpoint cid

        model_ =
            { model | openMenu = NothingOpen }
    in
        ( model_, Cmd.none, dispatch )


onContextTo : Context -> Model -> UpdateResponse msg
onContextTo { onSetContext } model =
    let
        dispatch =
            Cmd.fromMsg <| onSetContext context
    in
        ( model, Cmd.none, dispatch )


onCheckMenus : Model -> UpdateResponse msg
onCheckMenus ({ mouseSomewhereInside } as model) =
    let
        model_ =
            if not mouseSomewhereInside then
                { model | openMenu = NothingOpen }
            else
                model
    in
        ( model_, Cmd.none )


onTogglecampaign : Config msg -> Bool -> Model -> UpdateResponse msg
onTogglecampaign { onSetStoryMode } mode model =
    let
        cmd =
            Cmd.fromMsg <| onSwitchStorymode mode
    in
        ( model, cmd )


onServerReadAll : Config msg -> Model -> UpdateResponse msg
onServerReadAll { onReadAllServerNotifications } model =
    let
        cmd =
            Cmd.fromMsg onReadAllServerNotifications
    in
        ( model, cmd )


onAccountReadAll : Config msg -> Model -> UpdateResponse msg
onAccountReadAll { onReadAllAccountNotifications } model =
    let
        cmd =
            Cmd.fromMsg onReadAllAccountNotifications
    in
        ( model, cmd )


onSelectNIP : Config msg -> NIP -> Model -> UpdateResponse msg
onSelectNIP { onSetActiveNIP } nip model =
    let
        cmd =
            Cmd.fromMsg onSetActiveNIP nip
    in
        ( model, cmd )
