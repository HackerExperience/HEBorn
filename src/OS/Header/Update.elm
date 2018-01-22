module OS.Header.Update exposing (update)

import Utils.React as React exposing (React)
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
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        Logout ->
            onLogout config model

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
            onContextTo config context model

        CheckMenus ->
            onCheckMenus model

        ToggleCampaign toStory ->
            onTogglecampaign config toStory model

        ServerReadAll ->
            onServerReadAll config model

        ChatReadAll ->
            ( model, React.none )

        AccountReadAll ->
            onAccountReadAll config model


onLogout : Config msg -> Model -> UpdateResponse msg
onLogout { onLogout } model =
    onLogout
        |> React.msg
        |> (,) model


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
        ( model_, React.none )


onMouseEnterDropdown : Model -> UpdateResponse msg
onMouseEnterDropdown model =
    let
        model_ =
            { model | mouseSomewhereInside = True }
    in
        ( model_, React.none )


onMouseLeavesDropdown : Model -> UpdateResponse msg
onMouseLeavesDropdown model =
    let
        model_ =
            { model | mouseSomewhereInside = False }
    in
        ( model_, React.none )


onSelectGateway : Config msg -> Maybe Servers.CId -> Model -> UpdateResponse msg
onSelectGateway { onSetGateway } cid model =
    let
        cmd =
            case cid of
                Just cid ->
                    cid
                        |> onSetGateway
                        |> React.msg

                Nothing ->
                    React.none

        model_ =
            { model | openMenu = NothingOpen }
    in
        ( model_, cmd )


onSelectBounce : Config msg -> Maybe String -> Model -> UpdateResponse msg
onSelectBounce { onSetBounce } id model =
    id
        |> onSetBounce
        |> React.msg
        |> (,) (dropMenu model)


onSelectEndpoint : Config msg -> Maybe Servers.CId -> Model -> UpdateResponse msg
onSelectEndpoint { onSetEndpoint } cid model =
    cid
        |> onSetEndpoint
        |> React.msg
        |> (,) (dropMenu model)


onContextTo : Config msg -> Context -> Model -> UpdateResponse msg
onContextTo { onSetContext } context model =
    context
        |> onSetContext
        |> React.msg
        |> (,) model


onCheckMenus : Model -> UpdateResponse msg
onCheckMenus ({ mouseSomewhereInside } as model) =
    let
        model_ =
            if not mouseSomewhereInside then
                dropMenu model
            else
                model
    in
        ( model_, React.none )


onTogglecampaign : Config msg -> Bool -> Model -> UpdateResponse msg
onTogglecampaign { onSetStoryMode } mode model =
    mode
        |> onSetStoryMode
        |> React.msg
        |> (,) model


onServerReadAll : Config msg -> Model -> UpdateResponse msg
onServerReadAll { onReadAllServerNotifications } model =
    onReadAllServerNotifications
        |> React.msg
        |> (,) model


onAccountReadAll : Config msg -> Model -> UpdateResponse msg
onAccountReadAll { onReadAllAccountNotifications } model =
    onReadAllAccountNotifications
        |> React.msg
        |> (,) model


onSelectNIP : Config msg -> NIP -> Model -> UpdateResponse msg
onSelectNIP { onSetActiveNIP } nip model =
    nip
        |> onSetActiveNIP
        |> React.msg
        |> (,) model
