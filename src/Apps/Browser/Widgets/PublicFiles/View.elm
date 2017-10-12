module Apps.Browser.Widgets.PublicFiles.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.CssHelpers
import Game.Servers.Filesystem.Shared exposing (ForeignFileBox, Mime(..))
import Apps.Browser.Resources exposing (Classes(..), prefix)
import Apps.Browser.Pages.CommonActions exposing (CommonActions(..))
import Apps.Browser.Widgets.PublicFiles.Model exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


file : ForeignFileBox -> Html msg
file me =
    me.mime
        |> mimeModules
        |> List.map
            (\( name, ver ) ->
                name
                    ++ " -> VER: "
                    ++ toString ver
                    |> text
                    |> List.singleton
                    |> li []
            )
        |> ul []
        |> List.singleton
        |> (::) (span [] [ text me.name ])
        |> li []


publicFiles : Model -> Html msg
publicFiles model =
    ul [] <|
        List.map file model


mimeModules : Mime -> List ( String, Int )
mimeModules mime =
    List.filterMap
        (\( a, b ) ->
            case b.version of
                Just b ->
                    Just ( a, b )

                Nothing ->
                    Nothing
        )
    <|
        case mime of
            Cracker { bruteForce, overFlow } ->
                [ ( "Bruteforce", bruteForce )
                , ( "Overflow", overFlow )
                ]

            Firewall { active, passive } ->
                [ ( "Active", active )
                , ( "Passive", passive )
                ]

            Exploit { ftp, ssh } ->
                [ ( "FTP", ftp )
                , ( "SSH", ssh )
                ]

            Hasher { password } ->
                [ ( "Password", password ) ]

            LogForger { create, edit } ->
                [ ( "Create", create )
                , ( "Edit", edit )
                ]

            LogRecover { recover } ->
                [ ( "Recover", recover ) ]

            Encryptor { file, log, connection, process } ->
                [ ( "File", file )
                , ( "Log", log )
                , ( "Connections", connection )
                , ( "Process", process )
                ]

            Decryptor { file, log, connection, process } ->
                [ ( "File", file )
                , ( "Log", log )
                , ( "Connections", connection )
                , ( "Process", process )
                ]

            Anymap { geo, net } ->
                [ ( "Geo", geo )
                , ( "Net", net )
                ]

            _ ->
                []
