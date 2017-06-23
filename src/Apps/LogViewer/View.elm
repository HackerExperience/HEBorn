module Apps.LogViewer.View exposing (view)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Css.Common exposing (elasticClass)
import UI.ToString exposing (timestampToFullData)
import UI.Layouts.VerticalList exposing (verticalList)
import UI.Entries.FilterHeader exposing (filterHeader)
import UI.Inlines.Networking as Inlines exposing (user, addr, file)
import UI.Entries.Toogable exposing (toogableEntry)
import UI.Widgets.HorizontalBtnPanel exposing (horizontalBtnPanel)
import Game.Data as Game
import Game.Servers.Models as Servers
import Game.Servers.Logs.Models as Logs exposing (..)
import Apps.LogViewer.Messages exposing (Msg(..))
import Apps.LogViewer.Models exposing (..)
import Apps.LogViewer.Menu.View exposing (menuView, menuNormalEntry, menuEditingEntry, menuFilter)
import Apps.LogViewer.Style exposing (Classes(..))


{ id, class, classList } =
    Html.CssHelpers.withNamespace "logvw"


isEntryExpanded : LogViewer -> StdData -> Bool
isEntryExpanded app log =
    List.member log.id app.expanded


isEntryEditing : LogViewer -> StdData -> Bool
isEntryEditing app log =
    Dict.member log.id app.editing


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


renderMsg : SmartContent -> Html Msg
renderMsg msg =
    div []
        (case msg of
            LoginLocal addr user ->
                [ Inlines.addr addr
                , span [] [ text " logged in as " ]
                , Inlines.user user
                ]

            LoginRemote dest ->
                [ span [] [ text "Logged into " ]
                , Inlines.addr dest
                ]

            Connection actor src dest ->
                [ Inlines.addr actor
                , span [] [ text " bounced connection from " ]
                , Inlines.addr src
                , span [] [ text " to " ]
                , Inlines.addr dest
                ]

            DownloadBy fileName destIP ->
                [ span [] [ text "File " ]
                , Inlines.file fileName
                , span [] [ text " downloaded by " ]
                , Inlines.addr destIP
                ]

            DownloadFrom fileName srcIP ->
                [ span [] [ text "File " ]
                , Inlines.file fileName
                , span [] [ text " downloaded from " ]
                , Inlines.addr srcIP
                ]

            Invalid msg ->
                [ span [] [ text "Corrupted: " ]
                , span [] [ text msg ]
                ]

            Unintelligible ->
                [ span [] [ text "● ◐ ◑ ◒ ◓ ◔ ◕ ◖ ◗" ] ]
        )


renderMiniMsg : SmartContent -> Html Msg
renderMiniMsg msg =
    (case msg of
        Connection actor src dest ->
            div []
                [ Inlines.addr actor
                , span [] [ text " bounced connection from " ]
                , Inlines.addr src
                , span [] [ text " to ..." ]
                ]

        _ ->
            renderMsg msg
    )


renderEditing : Logs.ID -> String -> Html Msg
renderEditing logID src =
    input
        [ class [ BoxifyMe ]
        , value src
        , onInput (UpdateEditing logID)
        ]
        []


renderTopActions : StdData -> Html Msg
renderTopActions entry =
    div []
        -- TODO: Catch the flags for real
        (renderFlags [ BtnUser, BtnEdit, BtnCrypt ])


btnsEditing : Logs.ID -> List ( Attribute Msg, Msg )
btnsEditing logID =
    [ ( class [ BtnApply, BottomButton ], ApplyEditing logID )
    , ( class [ BtnCancel, BottomButton ], LeaveEditing logID )
    ]


btnsNormal : Logs.ID -> List ( Attribute Msg, Msg )
btnsNormal logID =
    [ ( class [ BtnCrypt, BottomButton ], StartCrypting logID )
    , ( class [ BtnHide, BottomButton ], StartHiding logID )
    , ( class [ BtnEdit, BottomButton ], EnterEditing logID )
    , ( class [ BtnDelete, BottomButton ], StartDeleting logID )
    ]


btnsCryptographed : Logs.ID -> List ( Attribute Msg, Msg )
btnsCryptographed logID =
    [ ( class [ BtnHide, BottomButton ], StartHiding logID )
    , ( class [ BtnUncrypt, BottomButton ], StartUncrypting logID )
    ]


renderBottomActions : LogViewer -> StdData -> Html Msg
renderBottomActions app entry =
    let
        btns =
            if (isEntryEditing app entry) then
                btnsEditing entry.id
            else if (isEntryExpanded app entry) then
                case entry.status of
                    StatusNormal ->
                        btnsNormal entry.id

                    Cryptographed ->
                        btnsCryptographed entry.id
            else
                []
    in
        horizontalBtnPanel btns


renderData : LogViewer -> StdData -> Html Msg
renderData app entry =
    case (Dict.get entry.id app.editing) of
        Just x ->
            renderEditing entry.id x

        Nothing ->
            if (isEntryExpanded app entry) then
                renderMsg entry.smart
            else
                renderMiniMsg entry.smart


renderBottom : LogViewer -> StdData -> Html Msg
renderBottom app entry =
    let
        data =
            if (isEntryEditing app entry) then
                [ renderBottomActions app entry ]
            else if (isEntryExpanded app entry) then
                [ renderBottomActions app entry ]
            else
                []
    in
        div
            [ class [ EBottom ] ]
            data


menuInclude : LogViewer -> StdData -> List (Attribute Msg)
menuInclude app entry =
    if (isEntryEditing app entry) then
        [ menuEditingEntry entry.id ]
    else
        case entry.status of
            StatusNormal ->
                [ menuNormalEntry entry.id ]

            _ ->
                []


renderEntry : LogViewer -> StdData -> Html Msg
renderEntry app entry =
    let
        expandedState =
            isEntryExpanded app entry

        editingState =
            isEntryEditing app entry

        etop =
            [ div [] [ entry.timestamp |> timestampToFullData |> text ]
            , div [ elasticClass ] []
            , renderTopActions entry
            ]

        data =
            [ div [ class [ ETop ] ] etop
            , renderData app entry
            , renderBottom app entry
            ]
    in
        toogableEntry
            (not editingState)
            (menuInclude app entry)
            (ToogleExpand entry.id)
            expandedState
            data


renderEntryList : LogViewer -> List StdData -> List (Html Msg)
renderEntryList app =
    List.map (renderEntry app)


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    verticalList
        ([ menuView model
         , filterHeader
            [ ( class [ BtnUser ], DummyNoOp, False )
            , ( class [ BtnEdit ], DummyNoOp, False )
            , ( class [ BtnHide ], DummyNoOp, False )
            ]
            []
            app.filterText
            "Search..."
            UpdateTextFilter
         ]
            ++ (data.server
                    |> Servers.getLogs
                    |> applyFilter app
                    |> renderEntryList app
               )
        )
