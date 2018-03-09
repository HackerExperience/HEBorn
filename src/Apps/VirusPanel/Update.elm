module Apps.VirusPanel.Update exposing (update)

import Dict as Dict
import Utils.React as React exposing (React)
import Game.Meta.Types.Network exposing (NIP)
import Game.Account.Bounces.Shared as Bounces
import Game.Account.Database.Models as Database
import Game.Account.Database.Shared exposing (..)
import Game.Account.Database.Requests.CollectWithBank as CollectWithBank
    exposing
        ( collectWithBankRequest
        )
import Game.Account.Finances.Models as Finances
import Game.Servers.Shared as Servers exposing (CId(..))
import Apps.VirusPanel.Config exposing (..)
import Apps.VirusPanel.Models exposing (..)
import Apps.VirusPanel.Messages as VirusPanel exposing (Msg(..))


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> VirusPanel.Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        GoTab tab ->
            onGoTab tab model

        SetModal modal ->
            onSetModal config modal model

        Select behavior ->
            onSelect behavior model

        Check nip ->
            onCheck config nip model

        CheckAll ->
            onCheckAll config model

        SetActiveVirus id ->
            onSetActiveVirus config id model

        ChangeActiveVirus nip ->
            onChangeActiveVirus config nip model

        Collect ->
            onCollect config model

        HandleCollected response ->
            onHandleCollected config response model


onSetModal : Config msg -> Maybe ModalAction -> Model -> UpdateResponse msg
onSetModal config modal model =
    let
        collectSelected =
            case getCollectType config.database model.toCollectSelected of
                Just BothTypes ->
                    Just (Both Nothing Nothing Nothing)

                Just BitcoinVirus ->
                    Just (BTC Nothing Nothing)

                Just MoneyVirus ->
                    Just (Money Nothing Nothing)

                Nothing ->
                    model.collectSelected

        model_ =
            case modal of
                Just ForCollect ->
                    { model
                        | modal = modal
                        , collectSelected = collectSelected
                    }

                _ ->
                    { model | modal = modal }
    in
        ( model_, React.none )


onGoTab : MainTab -> Model -> UpdateResponse msg
onGoTab tab model =
    let
        model_ =
            { model | selected = tab }
    in
        ( model_, React.none )


onSelect : Maybe CollectBehavior -> Model -> UpdateResponse msg
onSelect behavior model =
    ( { model | collectSelected = behavior }, React.none )


onCheck : Config msg -> NIP -> Model -> UpdateResponse msg
onCheck config nip model =
    if List.member nip (getSelectedToCollect model) then
        List.filter ((==) nip >> not) (getSelectedToCollect model)
            |> setSelectedToCollect model
            |> flip (,) React.none
    else
        (::) nip (getSelectedToCollect model)
            |> setSelectedToCollect model
            |> flip (,) React.none


onCheckAll : Config msg -> Model -> UpdateResponse msg
onCheckAll ({ database } as config) model =
    let
        filterer k v =
            case Database.getActiveVirus v of
                Just _ ->
                    True

                Nothing ->
                    False

        runningVirus =
            Database.getHackedServers database
                |> Dict.filter filterer
                |> Dict.keys

        model_ =
            if (List.length model.toCollectSelected) < (List.length runningVirus) then
                { model
                    | toCollectSelected = runningVirus
                }
            else
                { model | toCollectSelected = [] }
    in
        ( model_, React.none )


onChangeActiveVirus :
    Config msg
    -> NIP
    -> Model
    -> UpdateResponse msg
onChangeActiveVirus config nip model =
    let
        react =
            doChangeActiveVirusRequest config nip model.selectedActiveVirus

        model_ =
            { model | selectedActiveVirus = Nothing }
    in
        ( dropModal model, react )


onSetActiveVirus : Config msg -> Maybe String -> Model -> UpdateResponse msg
onSetActiveVirus config id model =
    ( { model | selectedActiveVirus = id }, React.none )


onCollect :
    Config msg
    -> Model
    -> UpdateResponse msg
onCollect config model =
    let
        virusList =
            model.toCollectSelected

        react =
            case model.collectSelected of
                Just (Money bounceId accountId) ->
                    case accountId of
                        Just id ->
                            doCollectWithBankRequest config bounceId id virusList

                        Nothing ->
                            React.none

                Just (BTC bounceId wallet) ->
                    case wallet of
                        Just wallet ->
                            doCollectWithBTCRequest config bounceId wallet virusList

                        Nothing ->
                            React.none

                Just (Both bounceId accountId wallet) ->
                    case ( accountId, wallet ) of
                        ( Just accId, Just wallet ) ->
                            doCollectWithBoth config bounceId accId wallet virusList

                        _ ->
                            React.none

                Nothing ->
                    React.none
    in
        ( dropModal model, react )


doCollectWithBankRequest :
    Config msg
    -> Maybe Bounces.ID
    -> Finances.AccountId
    -> List NIP
    -> React msg
doCollectWithBankRequest config bounceId bankAccountId virusList =
    let
        gateway =
            config.activeGatewayCId

        folder k v ( acu, found ) =
            if not found && v.isActive then
                ( k :: (Tuple.first acu), True )
            else
                ( acu, found )

        virusReducer nip acu =
            config.database
                |> Database.getHackedServers
                |> Dict.get nip
                |> Maybe.map
                    (Database.getVirusInstalled
                        >> Dict.foldr folder ( [], False )
                        >> Tuple.first
                    )
                |> Maybe.withDefault []

        virusesId =
            List.foldr virusReducer [] virusList
    in
        case gateway of
            GatewayCId id ->
                config
                    |> collectWithBankRequest id
                        virusesId
                        bounceId
                        bankAccountId
                        config.accountId
                    |> Cmd.map (HandleCollected >> config.toMsg)
                    |> React.cmd

            EndpointCId _ ->
                React.none


doCollectWithBTCRequest :
    Config msg
    -> Maybe Bounces.ID
    -> Finances.BitcoinAddress
    -> List NIP
    -> React msg
doCollectWithBTCRequest config bounceId wallet virusList =
    --TODO
    React.none


doCollectWithBoth :
    Config msg
    -> Maybe String
    -> Finances.AccountId
    -> Finances.BitcoinAddress
    -> List NIP
    -> React msg
doCollectWithBoth config bounceId accountId wallet virusList =
    --TODO
    React.none


doChangeActiveVirusRequest :
    Config msg
    -> NIP
    -> Maybe String
    -> React msg
doChangeActiveVirusRequest config nip id =
    --TODO
    React.none


onHandleCollected :
    Config msg
    -> Result CollectWithBankError ()
    -> Model
    -> UpdateResponse msg
onHandleCollected config response model =
    let
        ( modal, collectSelected ) =
            case response of
                Err error ->
                    ( Just <| ForError <| CollectError error, Nothing )

                Ok () ->
                    ( Just <| ForCollectSuccessful, Nothing )
    in
        React.update { model | modal = modal, collectSelected = collectSelected }
