module Apps.LogViewer.View exposing (view)

import Dict exposing (Dict)
import ContextMenu
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Utils.Html exposing (spacer)
import UI.ToString exposing (timestampToFullData)
import UI.Layouts.VerticalList exposing (verticalList)
import UI.Layouts.VerticalSticked exposing (verticalSticked)
import UI.Entries.FilterHeader exposing (filterHeader)
import UI.Inlines.Networking as Inlines exposing (user, addr, file)
import UI.Entries.Toogable exposing (toogableEntry)
import UI.Widgets.HorizontalBtnPanel exposing (horizontalBtnPanel)
import Game.Servers.Logs.Models as Logs exposing (Format(..))
import Apps.LogViewer.Config exposing (..)
import Apps.LogViewer.Messages exposing (Msg(..))
import Apps.LogViewer.Models exposing (..)
import Apps.LogViewer.Resources exposing (Classes(..), prefix)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


noOp : Config msg -> msg
noOp { batchMsg } =
    batchMsg []


view : Config msg -> Model -> Html msg
view config model =
    let
        filterHeaderLayout =
            verticalList []
                [ filterHeader
                    [ ( class [ BtnUser ], noOp config, False )
                    , ( class [ BtnEdit ], noOp config, False )
                    , ( class [ BtnHide ], noOp config, False )
                    ]
                    []
                    model.filterText
                    "Search..."
                    (UpdateTextFilter >> config.toMsg)
                ]

        mainEntries =
            config.logs
                |> applyFilter model
                |> renderEntries config model
                |> verticalList []
    in
        verticalSticked
            (Just [ filterHeaderLayout ])
            [ mainEntries
            ]
            Nothing



-- internals


encrypted : String
encrypted =
    "⠽⠕⠥ ⠚⠥⠎⠞ ⠇⠕⠎⠞ ⠠⠠⠞⠓⠑ ⠠⠠⠛⠁⠍⠑"


renderEntries : Config msg -> Model -> Logs.Model -> List (Html msg)
renderEntries config model logs =
    getLogsfromDate logs
        |> List.map (uncurry <| renderEntry config model)


renderEntry : Config msg -> Model -> Logs.ID -> Logs.Log -> Html msg
renderEntry config model id log =
    let
        expandedState =
            isEntryExpanded id model

        editingState =
            isEntryEditing id model

        etop =
            [ div [] [ log.timestamp |> timestampToFullData |> text ]
            , spacer
            , renderTopActions config log
            ]

        data =
            [ div [ class [ ETop ] ] etop
            , renderData config id log model
            , renderBottom config id log model
            ]
    in
        toogableEntry
            (not editingState)
            [ menu config id log model ]
            (config.toMsg <| ToogleExpand id)
            expandedState
            data


isEntryExpanded : Logs.ID -> Model -> Bool
isEntryExpanded id model =
    List.member id model.expanded


isEntryEditing : Logs.ID -> Model -> Bool
isEntryEditing id model =
    Dict.member id model.editing


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


renderContent : Config msg -> Logs.Log -> Html msg
renderContent config log =
    let
        rendered =
            case Logs.getContent log of
                Logs.NormalContent data ->
                    render config data

                Logs.Encrypted ->
                    [ span [] [ text encrypted ] ]
    in
        div [] rendered


renderMiniContent : Config msg -> Logs.Log -> Html msg
renderMiniContent =
    renderContent


renderEditing : Config msg -> Logs.ID -> String -> Html msg
renderEditing { toMsg } logID src =
    input
        [ class [ BoxifyMe ]
        , value src
        , onInput (UpdateEditing logID >> toMsg)
        ]
        []


renderTopActions : Config msg -> Logs.Log -> Html msg
renderTopActions _ log =
    -- TODO: Catch the flags for real
    div [] <| renderFlags [ BtnUser, BtnEdit, BtnCrypt ]


btnsEditing : Config msg -> Logs.ID -> List ( Attribute msg, msg )
btnsEditing { toMsg } logID =
    [ ( class [ BtnApply, BottomButton ], toMsg <| ApplyEditing logID )
    , ( class [ BtnCancel, BottomButton ], toMsg <| LeaveEditing logID )
    ]


btnsNormal : Config msg -> Logs.ID -> List ( Attribute msg, msg )
btnsNormal { toMsg, onEncrypt, onHide, onDelete } logID =
    [ ( class [ BtnCrypt, BottomButton ], onEncrypt logID )
    , ( class [ BtnHide, BottomButton ], onHide logID )
    , ( class [ BtnEdit, BottomButton ], toMsg <| EnterEditing logID )
    , ( class [ BtnDelete, BottomButton ], onDelete logID )
    ]


btnsCryptographed : Config msg -> Logs.ID -> List ( Attribute msg, msg )
btnsCryptographed { batchMsg, onHide } logID =
    [ ( class [ BtnHide, BottomButton ], onHide logID )
    , ( class [ BtnDecrypt, BottomButton ], batchMsg [] )
    ]


renderBottomActions :
    Config msg
    -> Logs.ID
    -> Logs.Log
    -> Model
    -> Html msg
renderBottomActions ({ toMsg } as config) id log model =
    let
        btns =
            if (isEntryEditing id model) then
                btnsEditing config id
            else if (isEntryExpanded id model) then
                case log.content of
                    Logs.NormalContent _ ->
                        btnsNormal config id

                    Logs.Encrypted ->
                        btnsCryptographed config id
            else
                []
    in
        horizontalBtnPanel btns


renderData : Config msg -> Logs.ID -> Logs.Log -> Model -> Html msg
renderData config id log model =
    case (Dict.get id model.editing) of
        Just x ->
            renderEditing config id x

        Nothing ->
            if (isEntryExpanded id model) then
                renderContent config log
            else
                renderMiniContent config log


renderBottom : Config msg -> Logs.ID -> Logs.Log -> Model -> Html msg
renderBottom config id log model =
    let
        actions =
            if (isEntryEditing id model) then
                renderBottomActions config id log model
            else if (isEntryExpanded id model) then
                renderBottomActions config id log model
            else
                text ""
    in
        div [ class [ EBottom ] ] [ actions ]


menu : Config msg -> Logs.ID -> Logs.Log -> Model -> Attribute msg
menu config id log model =
    if (isEntryEditing id model) then
        menuEditingEntry config id
    else
        case log.content of
            Logs.NormalContent _ ->
                menuNormalEntry config id

            Logs.Encrypted ->
                menuEncryptedEntry config id


menuEditingEntry : Config msg -> Logs.ID -> Attribute msg
menuEditingEntry { toMsg, menuAttr } id =
    menuAttr
        [ [ ( ContextMenu.item "Apply", toMsg (ApplyEditing id) )
          , ( ContextMenu.item "Cancel", toMsg (LeaveEditing id) )
          ]
        ]


menuNormalEntry : Config msg -> Logs.ID -> Attribute msg
menuNormalEntry { toMsg, onEncrypt, onHide, onDelete, menuAttr } id =
    menuAttr
        [ [ ( ContextMenu.item "Edit", toMsg (EnterEditing id) )
          , ( ContextMenu.item "Encrypt", onEncrypt id )
          , ( ContextMenu.item "Hide", onHide id )
          , ( ContextMenu.item "Delete", onDelete id )
          ]
        ]


menuEncryptedEntry : Config msg -> Logs.ID -> Attribute msg
menuEncryptedEntry { onHide, onDelete, menuAttr } id =
    menuAttr
        [ [ ( ContextMenu.item "Hide", onHide id )
          , ( ContextMenu.item "Delete", onDelete id )
          ]
        ]


getLogsfromDateHelper :
    Dict Logs.ID Logs.Log
    -> Logs.Date
    -> Logs.ID
    -> List ( Logs.ID, Logs.Log )
    -> List ( Logs.ID, Logs.Log )
getLogsfromDateHelper logs k v a =
    case Dict.get v logs of
        Just log ->
            a ++ [ ( v, log ) ]

        Nothing ->
            a


getLogsfromDate : Logs.Model -> List ( Logs.ID, Logs.Log )
getLogsfromDate logs =
    Dict.foldr (getLogsfromDateHelper logs.logs) [] logs.drawOrder


render : Config msg -> Logs.Data -> List (Html msg)
render config { format, raw } =
    case format of
        Just format ->
            case format of
                LocalLoginFormat data ->
                    [ addr (\_ -> noOp config) data.from
                    , text " logged in as "
                    , user data.user
                    ]

                RemoteLoginFormat { into } ->
                    [ text "Logged into "
                    , addr (\_ -> noOp config) into
                    ]

                ConnectionFormat { nip, from, to } ->
                    [ addr (\_ -> noOp config) nip
                    , text " bounced connection from "
                    , addr (\_ -> noOp config) from
                    , text " to "
                    , addr (\_ -> noOp config) to
                    ]

                DownloadByFormat { filename, nip } ->
                    [ text "File "
                    , file filename
                    , text " downloaded by "
                    , file nip
                    ]

                DownloadFromFormat { filename, nip } ->
                    [ text "File "
                    , file filename
                    , text " downloaded from "
                    , addr (\_ -> noOp config) nip
                    ]

        Nothing ->
            [ text raw ]
