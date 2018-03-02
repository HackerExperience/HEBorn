module Apps.DBAdmin.Tabs.Servers.View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (value, selected)
import Html.Events exposing (..)
import Html.CssHelpers
import UI.Layouts.VerticalList exposing (verticalList)
import UI.Entries.FilterHeader exposing (filterHeader)
import UI.Entries.Toogable exposing (toogableEntry)
import UI.Widgets.HorizontalBtnPanel exposing (horizontalBtnPanel)
import Utils.Html exposing (spacer)
import Utils.Html.Events exposing (onChange)
import Game.Account.Database.Models as Database
import Game.Meta.Types.Network as Network exposing (NIP)
import Apps.DBAdmin.Config exposing (..)
import Apps.DBAdmin.Messages exposing (Msg(..))
import Apps.DBAdmin.Models exposing (..)
import Apps.DBAdmin.Resources exposing (Classes(..), prefix)
import Apps.DBAdmin.Tabs.Servers.Helpers exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


isEntryExpanded : Model -> ( NIP, Database.HackedServer ) -> Bool
isEntryExpanded app ( nip, _ ) =
    List.member (Network.toString nip) app.servers.expanded


isEntryEditing : Model -> ( NIP, Database.HackedServer ) -> Bool
isEntryEditing app ( nip, _ ) =
    Dict.member (Network.toString nip) app.serversEditing


renderFlag : Classes -> List (Html Msg)
renderFlag flag =
    [ text " "
    , span [ class [ flag ] ] []
    ]


renderFlags : List Classes -> List (Html Msg)
renderFlags =
    List.map renderFlag
        >> List.concat
        >> List.tail
        >> Maybe.withDefault []


renderData : ( NIP, Database.HackedServer ) -> Html Msg
renderData ( nip, item ) =
    let
        alias =
            Database.getHackedServerAlias item
    in
        div []
            [ text "ip: "
            , text <| Network.render nip
            , text " psw: "
            , text item.password
            , text " nick: "
            , text <| Maybe.withDefault "[Unlabeled]" alias
            , text " notes: "
            , item.notes |> Maybe.withDefault "S/N" |> text
            , span [ onClick <| EnterSelectingVirus (Network.toString nip) ]
                [ text " !!!!VIRUS!!!!" ]
            ]


renderMiniData : ( NIP, Database.HackedServer ) -> Html Msg
renderMiniData ( nip, item ) =
    let
        alias =
            Database.getHackedServerAlias item
    in
        div []
            [ text "ip: "
            , text <| Tuple.second nip
            , text " psw: "
            , text item.password
            , text " nick: "
            , text <| Maybe.withDefault "[Unlabeled]" alias
            ]


renderVirusOption : Config msg -> String -> String -> Html Msg
renderVirusOption { database } activeId id =
    let
        version =
            id
                |> flip Database.getVirus database
                |> Maybe.andThen
                    (\virus ->
                        Database.getVirusVersion virus
                            |> toString
                            |> Just
                    )
                |> Maybe.withDefault "Unknown"

        label =
            id
                |> flip Database.getVirus database
                |> Maybe.andThen (Database.getVirusName >> Just)
                |> Maybe.withDefault "Unknown"
    in
        option
            [ value id, selected (activeId == id) ]
            [ text (label ++ " (" ++ (toString version) ++ ")") ]


renderEditing :
    Config msg
    -> ( NIP, Database.HackedServer )
    -> EditingServers
    -> Html Msg
renderEditing config (( nip, item ) as entry) src =
    case src of
        EditingTexts ( nick, notes ) ->
            div []
                [ renderMiniData entry
                , input
                    [ class []
                    , value nick
                    , onInput
                        (UpdateServersEditingNick (Network.toString nip))
                    ]
                    []
                , input
                    [ class [ BoxifyMe ]
                    , value notes
                    , onInput
                        (UpdateServersEditingNotes (Network.toString nip))
                    ]
                    []
                ]

        SelectingVirus activeId ->
            select
                [ class [ BoxifyMe ]
                , onChange
                    (UpdateServersSelectVirus (Network.toString nip))
                ]
                (List.map
                    (renderVirusOption config <| Maybe.withDefault "" activeId)
                    item.virusInstalled
                )


renderTopFlags : ( NIP, Database.HackedServer ) -> Html Msg
renderTopFlags _ =
    div []
        -- TODO: Catch the flags for real
        (renderFlags [ BtnEdit ])


btnsEditing : String -> List ( Attribute Msg, Msg )
btnsEditing itemId =
    [ ( class [ BtnApply, BottomButton ], ApplyEditing TabServers itemId )
    , ( class [ BtnCancel, BottomButton ], LeaveEditing TabServers itemId )
    ]


btnsNormal : String -> List ( Attribute Msg, Msg )
btnsNormal itemId =
    [ ( class [ BtnEdit, BottomButton ], EnterEditing TabServers itemId )
    , ( class [ BtnDelete, BottomButton ], StartDeleting TabServers itemId )
    ]


renderBottomActions : Model -> ( NIP, Database.HackedServer ) -> Html Msg
renderBottomActions app (( nip, _ ) as entry) =
    let
        btns =
            if (isEntryEditing app entry) then
                btnsEditing <| Network.toString nip
            else if (isEntryExpanded app entry) then
                btnsNormal <| Network.toString nip
            else
                []
    in
        horizontalBtnPanel btns


renderAnyData :
    Config msg
    -> Model
    -> ( NIP, Database.HackedServer )
    -> Html Msg
renderAnyData config app (( nip, _ ) as entry) =
    case (Dict.get (Network.toString nip) app.serversEditing) of
        Just x ->
            renderEditing config entry x

        Nothing ->
            if (isEntryExpanded app entry) then
                renderData entry
            else
                renderMiniData entry


renderBottom : Model -> ( NIP, Database.HackedServer ) -> Html Msg
renderBottom app entry =
    let
        data =
            if (isEntryEditing app entry || isEntryExpanded app entry) then
                [ renderBottomActions app entry ]
            else
                []
    in
        div
            [ class [ EBottom ] ]
            data


renderEntry :
    Config msg
    -> Model
    -> ( NIP, Database.HackedServer )
    -> Html Msg
renderEntry config app (( nip, _ ) as entry) =
    let
        expandedState =
            isEntryExpanded app entry

        editingState =
            isEntryEditing app entry

        etop =
            [ div [] []
            , spacer
            , renderTopFlags entry
            ]

        data =
            [ div [ class [ ETop ] ] etop
            , renderAnyData config app entry
            , renderBottom app entry
            ]
    in
        toogableEntry
            (not editingState)
            []
            (ToogleExpand TabServers <| Network.toString nip)
            expandedState
            data


renderEntryList :
    Config msg
    -> Model
    -> Database.HackedServers
    -> List (Html Msg)
renderEntryList config app entries =
    entries
        |> Dict.toList
        |> List.map (renderEntry config app)


view : Config msg -> Model -> Html Msg
view ({ database } as config) model =
    let
        header =
            filterHeader []
                []
                model.servers.filterText
                "Search..."
                (UpdateTextFilter TabServers)
    in
        database.servers
            |> applyFilter model
            |> renderEntryList config model
            |> (::) header
            |> verticalList []
