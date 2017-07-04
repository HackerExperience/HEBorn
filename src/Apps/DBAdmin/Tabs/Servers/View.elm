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
import Game.Account.Database.Models exposing (..)
import Apps.DBAdmin.Messages exposing (Msg(..))
import Apps.DBAdmin.Models exposing (..)
import Apps.DBAdmin.Menu.View exposing (menuView, menuNormalEntry, menuEditingEntry, menuFilter)
import Apps.DBAdmin.Style exposing (Classes(..))
import Apps.DBAdmin.Tabs.Servers.Helpers exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "udb"


isEntryExpanded : DBAdmin -> HackedServer -> Bool
isEntryExpanded app item =
    List.member item.ip app.servers.expanded


isEntryEditing : DBAdmin -> HackedServer -> Bool
isEntryEditing app item =
    Dict.member item.ip app.serversEditing


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


renderData : HackedServer -> Html Msg
renderData item =
    div []
        [ text "ip: "
        , text item.ip
        , text " psw: "
        , text item.password
        , text " nick: "
        , text item.nick
        , text " notes: "
        , item.notes |> Maybe.withDefault "S/N" |> text
        , span [ onClick <| EnterSelectingVirus item.ip ] [ text " !!!!VIRUS!!!!" ]
        ]


renderMiniData : HackedServer -> Html Msg
renderMiniData item =
    div []
        [ text "ip: "
        , text item.ip
        , text " psw: "
        , text item.password
        , text " nick: "
        , text item.nick
        ]


renderVirusOption : String -> ( String, String, Float ) -> Html Msg
renderVirusOption activeId ( id, label, version ) =
    option
        [ value id, selected (activeId == id) ]
        [ text (label ++ " (" ++ (toString version) ++ ")") ]


renderEditing : HackedServer -> EditingServers -> Html Msg
renderEditing item src =
    case src of
        EditingTexts ( nick, notes ) ->
            div []
                [ renderMiniData item
                , input
                    [ class []
                    , value nick
                    , onInput (UpdateServersEditingNick item.ip)
                    ]
                    []
                , input
                    [ class [ BoxifyMe ]
                    , value notes
                    , onInput (UpdateServersEditingNotes item.ip)
                    ]
                    []
                ]

        SelectingVirus activeId ->
            select
                [ class [ BoxifyMe ]
                , onChange (UpdateServersSelectVirus item.ip)
                ]
                (List.map
                    (renderVirusOption <| Maybe.withDefault "" activeId)
                    item.virusInstalled
                )


renderTopFlags : HackedServer -> Html Msg
renderTopFlags entry =
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


renderBottomActions : DBAdmin -> HackedServer -> Html Msg
renderBottomActions app entry =
    let
        btns =
            if (isEntryEditing app entry) then
                btnsEditing entry.ip
            else if (isEntryExpanded app entry) then
                btnsNormal entry.ip
            else
                []
    in
        horizontalBtnPanel btns


renderAnyData : DBAdmin -> HackedServer -> Html Msg
renderAnyData app entry =
    case (Dict.get entry.ip app.serversEditing) of
        Just x ->
            renderEditing entry x

        Nothing ->
            if (isEntryExpanded app entry) then
                renderData entry
            else
                renderMiniData entry


renderBottom : DBAdmin -> HackedServer -> Html Msg
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


menuInclude : DBAdmin -> HackedServer -> List (Attribute Msg)
menuInclude app entry =
    if (isEntryEditing app entry) then
        [ menuEditingEntry entry.ip ]
    else
        [ menuNormalEntry entry.ip ]


renderEntry : DBAdmin -> HackedServer -> Html Msg
renderEntry app entry =
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
            , renderAnyData app entry
            , renderBottom app entry
            ]
    in
        toogableEntry
            (not editingState)
            (menuInclude app entry)
            (ToogleExpand TabServers entry.ip)
            expandedState
            data


renderEntryList : DBAdmin -> List HackedServer -> List (Html Msg)
renderEntryList app entries =
    List.map (renderEntry app) entries


view : Database -> Model -> DBAdmin -> Html Msg
view database model app =
    verticalList
        ([ menuView model
         , filterHeader
            []
            []
            app.servers.filterText
            "Search..."
            (UpdateTextFilter TabServers)
         ]
            ++ (database.servers
                    |> applyFilter app
                    |> renderEntryList app
               )
        )
