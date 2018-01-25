module Apps.BounceManager.Update exposing (update)

import Utils.React as React exposing (React)
import Utils.List exposing (..)
import Game.Account.Bounces.Models as Bounces
import Apps.BounceManager.Config exposing (..)
import Apps.BounceManager.Models exposing (Model, MainTab(..), Selection(..))
import Apps.BounceManager.Messages as BounceManager exposing (Msg(..))
import Game.Meta.Types.Network as Network


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> BounceManager.Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        GoTab tab ->
            onGoTab tab model

        UpdateEditing str ->
            onUpdateEditing str model

        ToggleNameEdit ->
            onToggleNameEdit model

        ApplyNameChangings ->
            onApplyNameChangings model

        SelectServer nip ->
            onSelectServer nip model

        SelectSlot num ->
            onSelectSlot num model

        SelectEntry num ->
            onSelectEntry num model

        ClearSelection ->
            onClearSelection model

        ServerAdd nip where_ ->
            onServerAdd nip where_ model

        ServerRemove nip ->
            onServerRemove nip model


onGoTab : MainTab -> Model -> UpdateResponse msg
onGoTab tab model =
    case tab of
        TabManage ->
            let
                model_ =
                    { model | selected = tab }
            in
                ( model_, React.none )

        TabBuild bounceInfo ->
            let
                model_ =
                    { model
                        | selected = tab
                        , selectedBounce = Just bounceInfo
                    }
            in
                ( model_, React.none )


onUpdateEditing : String -> Model -> UpdateResponse msg
onUpdateEditing str model =
    let
        model_ =
            { model | bounceNameBuffer = Just str }
    in
        ( model_, React.none )


onToggleNameEdit : Model -> UpdateResponse msg
onToggleNameEdit model =
    let
        model_ =
            { model
                | editing = not model.editing
                , bounceNameBuffer = Nothing
            }
    in
        ( model_, React.none )


onApplyNameChangings : Model -> UpdateResponse msg
onApplyNameChangings model =
    let
        selectedBounce =
            case model.selectedBounce of
                Just ( id, bounce ) ->
                    case model.bounceNameBuffer of
                        Just name ->
                            Just ( id, Bounces.setName name bounce )

                        Nothing ->
                            Just ( id, bounce )

                Nothing ->
                    Nothing

        model_ =
            { model
                | editing = False
                , selectedBounce = selectedBounce
                , bounceNameBuffer = Nothing
            }
    in
        ( model_, React.none )


onSelectServer : Network.NIP -> Model -> UpdateResponse msg
onSelectServer nip model =
    let
        model_ =
            { model | selection = Just (SelectingServer nip) }
    in
        ( model_, React.none )


onSelectSlot : Int -> Model -> UpdateResponse msg
onSelectSlot num model =
    let
        model_ =
            { model | selection = Just (SelectingSlot num) }
    in
        ( model_, React.none )


onSelectEntry : Int -> Model -> UpdateResponse msg
onSelectEntry num model =
    let
        model_ =
            { model | selection = Just (SelectingEntry num) }
    in
        ( model_, React.none )


onClearSelection : Model -> UpdateResponse msg
onClearSelection model =
    let
        model_ =
            { model | selection = Nothing }
    in
        ( model_, React.none )


onServerAdd : Network.NIP -> Int -> Model -> UpdateResponse msg
onServerAdd nip where_ model =
    let
        model_ =
            { model | path = insertAt where_ nip model.path }
    in
        ( model_, React.none )


onServerRemove : Network.NIP -> Model -> UpdateResponse msg
onServerRemove nip model =
    let
        model_ =
            { model | path = List.filter (((==) nip) >> not) model.path }
    in
        ( model_, React.none )
