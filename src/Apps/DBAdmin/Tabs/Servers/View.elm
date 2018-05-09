module Apps.DBAdmin.Tabs.Servers.View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (value, selected, placeholder)
import Html.Events exposing (..)
import Html.CssHelpers
import UI.Layouts.VerticalList exposing (verticalList)
import UI.Elements.FilterHeader exposing (filterHeader)
import UI.Elements.Toogable exposing (toogableEntry)
import UI.Elements.HorizontalBtnPanel exposing (horizontalBtnPanel)
import Utils.Html exposing (spacer)
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


renderFlag : Classes -> List (Html msg)
renderFlag flag =
    [ text " "
    , span [ class [ flag ] ] []
    ]


renderFlags : List Classes -> List (Html msg)
renderFlags =
    List.map renderFlag
        >> List.concat
        >> List.tail
        >> Maybe.withDefault []


renderData : ( NIP, Database.HackedServer ) -> Html msg
renderData ( nip, item ) =
    let
        alias =
            Database.getHackedServerAlias item
    in
        div []
            [ text "ip: "
            , text <| Network.render nip
            , br [] []
            , text " psw: "
            , span [ class [ Password ] ] [ text item.password ]
            , br [] []
            , text " nick: "
            , text <| Maybe.withDefault "[Unlabeled]" alias
            , br [] []
            , text " notes: "
            , item.notes |> Maybe.withDefault "S/N" |> text
            ]


renderMiniData : ( NIP, Database.HackedServer ) -> Html msg
renderMiniData ( nip, item ) =
    let
        alias =
            Database.getHackedServerAlias item
    in
        div []
            [ text <| Maybe.withDefault (Tuple.second nip) alias
            ]


renderEditing :
    Config msg
    -> ( NIP, Database.HackedServer )
    -> EditingServers
    -> Html msg
renderEditing { toMsg } (( nip, item ) as entry) src =
    case src of
        EditingTexts ( nick, notes ) ->
            div []
                [ renderData entry
                , text "New label:"
                , br [] []
                , input
                    [ class [ BoxifyMe ]
                    , value nick
                    , placeholder "Alias"
                    , onInput
                        (UpdateServersEditingNick (Network.toString nip) >> toMsg)
                    ]
                    []
                , text "New notes:"
                , br [] []
                , input
                    [ class [ BoxifyMe ]
                    , value notes
                    , placeholder "Notes"
                    , onInput
                        (UpdateServersEditingNotes (Network.toString nip) >> toMsg)
                    ]
                    []
                ]


renderTopFlags : Config msg -> ( NIP, Database.HackedServer ) -> Html msg
renderTopFlags _ _ =
    div []
        -- TODO: Catch the flags for real
        (renderFlags [ BtnEdit ])


btnsEditing : Config msg -> NIP -> List ( Attribute msg, msg )
btnsEditing { toMsg } itemId =
    [ ( class [ BtnApply, BottomButton ], toMsg <| ApplyEditing TabServers <| Network.toString itemId )
    , ( class [ BtnCancel, BottomButton ], toMsg <| LeaveEditing TabServers <| Network.toString itemId )
    ]


btnsNormal : Config msg -> NIP -> List ( Attribute msg, msg )
btnsNormal { toMsg } itemId =
    [ ( class [ BtnEdit, BottomButton ], toMsg <| EnterEditing TabServers <| Network.toString itemId )
    , ( class [ BtnDelete, BottomButton ], toMsg <| StartDeleting TabServers <| Network.toString itemId )
    ]


renderBottomActions : Config msg -> Model -> ( NIP, Database.HackedServer ) -> Html msg
renderBottomActions config app (( nip, _ ) as entry) =
    let
        btns =
            if (isEntryEditing app entry) then
                btnsEditing config nip
            else if (isEntryExpanded app entry) then
                btnsNormal config nip
            else
                []
    in
        horizontalBtnPanel btns


renderAnyData :
    Config msg
    -> Model
    -> ( NIP, Database.HackedServer )
    -> Html msg
renderAnyData config app (( nip, _ ) as entry) =
    case (Dict.get (Network.toString nip) app.serversEditing) of
        Just x ->
            renderEditing config entry x

        Nothing ->
            if (isEntryExpanded app entry) then
                renderData entry
            else
                renderMiniData entry


renderBottom : Config msg -> Model -> ( NIP, Database.HackedServer ) -> Html msg
renderBottom config app entry =
    let
        data =
            if (isEntryEditing app entry || isEntryExpanded app entry) then
                [ renderBottomActions config app entry ]
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
    -> Html msg
renderEntry config app (( nip, _ ) as entry) =
    let
        expandedState =
            isEntryExpanded app entry

        editingState =
            isEntryEditing app entry

        etop =
            [ div [] []
            , spacer
            , renderTopFlags config entry
            ]

        data =
            [ div [ class [ ETop ] ] etop
            , renderAnyData config app entry
            , renderBottom config app entry
            ]
    in
        toogableEntry
            (not editingState)
            []
            (config.toMsg <| ToogleExpand TabServers <| Network.toString nip)
            expandedState
            data


renderEntryList :
    Config msg
    -> Model
    -> Database.HackedServers
    -> List (Html msg)
renderEntryList config app entries =
    entries
        |> Dict.toList
        |> List.map (renderEntry config app)


view : Config msg -> Model -> Html msg
view ({ database, toMsg } as config) model =
    let
        header =
            filterHeader []
                []
                model.servers.filterText
                "Search..."
                (UpdateTextFilter TabServers >> toMsg)
    in
        database.servers
            |> applyFilter model
            |> renderEntryList config model
            |> (::) header
            |> verticalList []
