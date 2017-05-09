module Apps.LogViewer.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Css exposing (asPairs)
import Css.Common exposing (elasticClass)
import Game.Shared exposing (..)
import Game.Models exposing (GameModel)
import Game.Servers.Filesystem.Models exposing (FilePath)
import Apps.Instances.Models as Instance exposing (InstanceID)
import Apps.Context as Context
import Apps.LogViewer.Messages exposing (Msg(..))
import Apps.LogViewer.Models exposing (Model, LogViewer, getState, LogViewerEntry, LogEventMsg(..))
import Apps.LogViewer.Context.Models exposing (Context(..))
import Apps.LogViewer.Style exposing (Classes(..))
import Date exposing (Date, fromTime)
import Date.Format as DateFormat exposing (format)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "logvw"


styles : List Css.Mixin -> Attribute Msg
styles =
    Css.asPairs >> style



-- VIEW WRAPPER


renderAddr : IP -> List (Html Msg)
renderAddr addr =
    if (addr == localhost) then
        [ span [ class [ IcoHome, ColorLocal ] ] []
        , text " "
        , span [ class [ IdLocal, ColorLocal ] ] [ text localhost ]
        ]
    else
        [ span [ class [ IcoCrosshair, ColorRemote ] ] []
        , text " "
        , span [ class [ IdMe, ColorRemote ] ] [ text addr ]
        ]


renderUser : ServerUser -> List (Html Msg)
renderUser user =
    if (user == root) then
        [ span [ class [ IcoUser, ColorRoot ] ] []
        , text " "
        , span [ class [ IdRoot, ColorRoot ] ] [ text user ]
        ]
    else
        [ span [ class [ IcoUser ] ] []
        , text " "
        , span [] [ text user ]
        ]


renderButtons : List Classes -> List (Html Msg)
renderButtons btns =
    btns
        |> List.map (\d -> [ text " ", span [ class [ d ] ] [] ])
        |> List.concat
        |> List.tail
        |> Maybe.withDefault []


renderMsg : LogEventMsg -> Html Msg
renderMsg msg =
    (case msg of
        LogIn addr user ->
            div [ class [ EData ] ]
                (renderAddr addr
                    ++ [ span [] [ text " logged in as " ] ]
                    ++ renderUser user
                )

        Connetion actor src dest ->
            div [ class [ EData ] ]
                (renderAddr actor
                    ++ [ span [] [ text " bounced connection from " ]
                       , span [ class [ IcoCrosshair, ColorRemote ] ] []
                       , text " "
                       , span [ class [ IdMe, ColorRemote ] ] [ text src ]
                       , span [] [ text " to " ]
                       , span [ class [ IcoDangerous, ColorDangerous ] ] []
                       , text " "
                       , span [ class [ IdOther, ColorDangerous ] ] [ text dest ]
                       ]
                )

        ExternalAcess whom aswho ->
            div [ class [ EData, BoxifyMe ] ]
                (renderUser whom
                    ++ [ span [] [ text " logged in as " ] ]
                    ++ renderUser aswho
                )

        WrongA ->
            div [ class [ EData ] ] []

        WrongB ->
            div [ class [ EData ] ] []
    )


renderTopActions : LogEventMsg -> Html Msg
renderTopActions msg =
    div [ class [ ETActMini ] ]
        (case msg of
            LogIn addr user ->
                renderButtons [ BtnEdit ]

            Connetion actor src dest ->
                renderButtons [ BtnUser, BtnEdit ]

            ExternalAcess whom aswho ->
                []

            WrongA ->
                renderButtons [ BtnLock ]

            WrongB ->
                renderButtons [ BtnLock ]
        )


renderBottomActions : LogEventMsg -> Html Msg
renderBottomActions msg =
    div [ class [ EAct ] ]
        (case msg of
            LogIn addr user ->
                []

            Connetion actor src dest ->
                renderButtons [ IcoUser, BtnView, BtnEdit, BtnDelete ]

            ExternalAcess whom aswho ->
                renderButtons [ BtnApply, BtnCancel ]

            WrongA ->
                []

            WrongB ->
                renderButtons [ BtnView, BtnUnlock ]
        )


attachVisibility : Bool -> Attribute msg
attachVisibility status =
    attribute "data-expanded"
        (if (status) then
            "1"
         else
            "0"
        )


renderEntry : Date.Date -> Bool -> LogEventMsg -> Html Msg
renderEntry timestamp fullvisible msg =
    div [ class [ Entry ] ]
        [ div [ class [ ETop ] ]
            [ div [] [ text (DateFormat.format "%d/%m/%Y - %H:%M:%S" timestamp) ]
            , div [ elasticClass ] []
            , renderTopActions msg
            ]
        , renderMsg msg
        , div [ class [ EBottom ] ]
            [ renderBottomActions msg
            , div
                [ class [ CasedBtnExpand, EToggler ]
                , attachVisibility fullvisible
                ]
                []
            ]
        ]


renderEntryList : List LogViewerEntry -> List (Html Msg)
renderEntryList list =
    List.map (\n -> (renderEntry n.timestamp n.visibility n.message)) list



-- END OF THAT


view : Model -> InstanceID -> GameModel -> Html Msg
view model id game =
    let
        logvw =
            getState model id
    in
        div []
            ([ div [ class [ HeaderBar ] ]
                [ div [ class [ ETAct ] ]
                    [ span [ class [ BtnUser ] ] []
                    , text " "
                    , span [ class [ BtnEdit ] ] []
                    , text " "
                    , span [ class [ BtnView ] ] []
                    ]
                , div [ class [ ETFilter ] ]
                    [ div [ class [ BtnFilter ] ] []
                    , div [ class [ ETFBar ] ]
                        [ input [ placeholder "Search..." ] []
                        ]
                    ]
                ]
             ]
                ++ renderEntryList
                    [ { timestamp = (Date.fromTime 0)
                      , visibility = True
                      , message = (LogIn "174.57.204.104" root)
                      }
                    , { timestamp = (Date.fromTime 0)
                      , visibility = True
                      , message = (Connetion localhost "174.57.204.104" "209.43.107.189")
                      }
                    , LogViewerEntry (Date.fromTime 0) True (WrongA)
                    , LogViewerEntry (Date.fromTime 0) True (WrongB)
                    , LogViewerEntry (Date.fromTime 0) True (ExternalAcess "NOTME" root)
                    ]
            )
