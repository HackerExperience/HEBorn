module Apps.VirusPanel.View exposing (view)

import Dict as Dict exposing (Dict)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html.Lazy exposing (..)
import Html.CssHelpers
import Utils.Maybe as Maybe
import UI.Layouts.VerticalList exposing (verticalList)
import UI.Layouts.VerticalSticked exposing (verticalSticked)
import UI.ToString exposing (timestampToFullData)
import UI.Widgets.CustomSelect exposing (customSelect)
import UI.Widgets.HorizontalTabs exposing (hzTabs)
import UI.Widgets.Modal exposing (modalOk)
import UI.Widgets.Modal.Virus exposing (..)
import Game.Account.Database.Models as Database exposing (VirusType(..))
import Game.Account.Database.Shared exposing (..)
import Game.Account.Bounces.Shared as Bounces
import Game.Account.Finances.Models as Finances
import Game.Account.Finances.Shared exposing (toMoney)
import Game.Meta.Types.Network as Network exposing (NIP)
import Apps.VirusPanel.Config exposing (..)
import Apps.VirusPanel.Messages exposing (Msg(..))
import Apps.VirusPanel.Models exposing (..)
import Apps.VirusPanel.Resources exposing (Classes(..), prefix)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view config ({ selected } as model) =
    let
        viewData =
            case model.selected of
                TabList ->
                    lazy2 viewTabList config model

                TabBotnet ->
                    lazy2 viewTabBotnet config model

                TabCollect ->
                    lazy2 viewTabCollect config model

        msg =
            (GoTab >> config.toMsg)

        viewTabs =
            hzTabs (compareTabs selected) viewTabLabel msg tabs
    in
        verticalSticked (Just [ viewTabs ]) [ viewData ] Nothing


tabs : List MainTab
tabs =
    [ TabList
    , TabBotnet
    , TabCollect
    ]


compareTabs : MainTab -> MainTab -> Bool
compareTabs =
    (==)


viewTabLabel : Bool -> MainTab -> ( List (Attribute msg), List (Html msg) )
viewTabLabel _ tab =
    tab
        |> tabToString
        |> text
        |> List.singleton
        |> (,) []



-- TabsList Implementation


viewTabList : Config msg -> Model -> Html msg
viewTabList ({ database } as config) model =
    Database.getHackedServers database
        |> Dict.toList
        |> List.map (viewServer config model)
        |> verticalList [ class [ ServerList ] ]
        |> List.singleton
        |> (++) [ modalHandler config model ]
        |> div [ class [ Super, TList ] ]


viewServer :
    Config msg
    -> Model
    -> ( Network.NIP, Database.HackedServer )
    -> Html msg
viewServer ({ toMsg } as config) model ( nip, server ) =
    let
        name =
            case server.label of
                Just label ->
                    label

                Nothing ->
                    Network.render nip

        activeVirus =
            Database.getActiveVirus server
                |> Maybe.andThen (flip Database.getVirus config.database)
                |> Maybe.map (Database.getVirusName >> (++) "Running: " >> text)
                |> Maybe.withDefault (text "")
    in
        div [ class [ Server ] ]
            [ div [ class [ ServerTop ] ]
                [ text name
                , button
                    [ ForSetActiveVirus nip server
                        |> Just
                        |> SetModal
                        |> toMsg
                        |> onClick
                    ]
                    [ text "Change Active Virus" ]
                ]
            , activeVirus
            ]



-- TabBotnet Implementation


viewTabBotnet : Config msg -> Model -> Html msg
viewTabBotnet _ _ =
    div [ class [ Super, TBotnet ] ] [ text "TODO" ]



-- TabCollect Implementation


viewTabCollect : Config msg -> Model -> Html msg
viewTabCollect ({ database, toMsg } as config) model =
    let
        button_ =
            if List.isEmpty model.toCollectSelected then
                [ div [ class [ CollectButtons ] ] [] ]
            else
                [ div [ class [ CollectButtons ] ]
                    [ button
                        [ onClick <| toMsg <| SetModal (Just ForCollect)
                        , class [ CollectButton ]
                        ]
                        [ text "Collect" ]
                    ]
                ]
    in
        Database.getHackedServers database
            |> Dict.toList
            |> List.foldr (viewCollectVirus config model) []
            |> verticalList [ class [ CollectingVirusList ] ]
            |> flip (::) button_
            |> (++) [ modalHandler config model ]
            |> (::) (collectTopBar config model)
            |> div [ class [ Super, TCollect ] ]


collectTopBar : Config msg -> Model -> Html msg
collectTopBar ({ toMsg } as config) model =
    div [ class [ CollectTopBar ] ]
        [ checkbox (checkAllSelected config model) (toMsg CheckAll)
        , span [] [ text " Select All" ]
        ]


viewCollectVirus :
    Config msg
    -> Model
    -> ( Network.NIP, Database.HackedServer )
    -> List (Html msg)
    -> List (Html msg)
viewCollectVirus ({ toMsg, database } as config) model ( nip, server ) acu =
    let
        hackedServers =
            Database.getHackedServers config.database

        activeVirus =
            Database.getHackedServer nip hackedServers
                |> Maybe.andThen Database.getActiveVirus

        thereIsActiveVirus =
            activeVirus
                |> Maybe.map (flip Database.getVirus database)
                |> Maybe.isJust

        name =
            activeVirus
                |> Maybe.andThen (flip Database.getVirus database)
                |> Maybe.map (Database.getVirusName)
                |> Maybe.withDefault "Unknown"
                |> flip (++) " on "
                |> flip (++) (Network.render nip)

        -- HORA DO SHOW P****
        showTime str =
            case time of
                Just string ->
                    (++) "Running Since: " string
                        |> text

                Nothing ->
                    text ""

        time =
            Database.getHackedServer nip hackedServers
                |> Maybe.andThen (Database.getVirusTime)
                |> Maybe.map (timestampToFullData >> Just)
                |> Maybe.withDefault Nothing

        check_ =
            List.member nip model.toCollectSelected
    in
        if thereIsActiveVirus then
            div [ class [ CollectingVirus ] ]
                [ checkbox check_ (toMsg <| Check nip)
                , text name
                , br [] []
                , showTime time
                ]
                :: acu
        else
            acu



-- Modal Handling


modalHandler : Config msg -> Model -> Html msg
modalHandler ({ toMsg } as config) model =
    case model.modal of
        Just ForCollect ->
            modalCollecting config model

        Just (ForSetActiveVirus nip server) ->
            modalSetActiveVirus
                config
                server
                (SetActiveVirus >> toMsg)
                (toMsg <| ChangeActiveVirus nip)
                (toMsg <| SetModal Nothing)
                model

        Just (ForError (CollectError error)) ->
            modalError config error

        Just ForCollectSuccessful ->
            modalOk
                (Just "Virus Panel")
                "Collect has been successful"
                (toMsg <| SetModal Nothing)

        Nothing ->
            text ""


modalCollecting : Config msg -> Model -> Html msg
modalCollecting ({ toMsg } as config) model =
    let
        type_ =
            getCollectType config model.toCollectSelected
    in
        case type_ of
            Just type_ ->
                modalCollect config
                    type_
                    (Select >> toMsg)
                    ( toMsg Collect, toMsg (SetModal Nothing) )
                    model

            Nothing ->
                text ""


modalError : Config msg -> CollectWithBankError -> Html msg
modalError { toMsg } error =
    case error of
        CollectUSDBadRequest ->
            modalOk
                (Just "Error")
                "failed to Collect (BadRequest)"
                (toMsg <| SetModal Nothing)

        UnkownCollectError ->
            modalOk
                (Just "Error")
                "failed to Collect (Unknown Error)"
                (toMsg <| SetModal Nothing)



-- Helpers


checkbox : Bool -> msg -> Html msg
checkbox isChecked msg =
    input
        [ type_ "checkbox"
        , onClick msg
        , checked isChecked
        ]
        []


getCollectType : Config msg -> List NIP -> Maybe CollectType
getCollectType ({ database } as config) selectedServers =
    let
        hackedServers =
            Database.getHackedServers database

        reducer nip (( bank, wallet ) as acu) =
            let
                virusType =
                    Database.getHackedServer nip hackedServers
                        |> Maybe.andThen Database.getActiveVirus
                        |> Maybe.andThen (flip Database.getVirus database)
                        |> Maybe.map Database.getVirusType
            in
                case virusType of
                    Just Spyware ->
                        ( True, wallet )

                    Just Adware ->
                        ( True, wallet )

                    Just BTCMiner ->
                        ( bank, True )

                    Nothing ->
                        acu
    in
        case List.foldl reducer ( False, False ) selectedServers of
            ( True, True ) ->
                Just BothTypes

            ( False, True ) ->
                Just BitcoinVirus

            ( True, False ) ->
                Just MoneyVirus

            _ ->
                -- This should NEVER happen
                Nothing


checkAllSelected : Config msg -> Model -> Bool
checkAllSelected { database } ({ toCollectSelected } as model) =
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
    in
        (List.sort toCollectSelected) == runningVirus
