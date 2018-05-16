port module Utils.Ports.Leaflet
    exposing
        ( LeafletSub(..)
        , InstanceId
        , Coordinates
        , Zoom
        , Envelope
        , subscribe
        , init
        , center
        )

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Json.Decode.Pipeline exposing (decode, required)
import Utils.Json.Decode exposing (commonError)


type alias InstanceId =
    String


type alias Coordinates =
    { lat : Float
    , lng : Float
    }


type alias Zoom =
    Int


type LeafletSub
    = Click Coordinates
    | Unknown


type alias Envelope flow =
    ( InstanceId, flow )


type LeafletCmd
    = Init
    | Center Coordinates Zoom


init : InstanceId -> Cmd msg
init id =
    Init |> cmd id |> portOutput


center : InstanceId -> Coordinates -> Zoom -> Cmd msg
center id coords zoom =
    Center coords zoom |> cmd id |> portOutput


subscribe : (Envelope LeafletSub -> msg) -> Sub msg
subscribe toMsg =
    portInput (toSub >> toMsg)



-- internals


port portInput : (Decode.Value -> msg) -> Sub msg


port portOutput : Encode.Value -> Cmd msg


cmd : InstanceId -> LeafletCmd -> Encode.Value
cmd id lCmd =
    case lCmd of
        Init ->
            encode id "init" []

        Center { lat, lng } zoom ->
            encode id "center" <|
                [ ( "lat", Encode.float lat )
                , ( "lng", Encode.float lng )
                , ( "zoom", Encode.int zoom )
                ]


encode : String -> String -> List ( String, Encode.Value ) -> Encode.Value
encode id cmd_ etc =
    Encode.object <|
        [ ( "id", Encode.string id )
        , ( "cmd", Encode.string cmd_ )
        ]
            ++ etc


toSub : Decode.Value -> Envelope LeafletSub
toSub value =
    let
        sub_ =
            case Decode.decodeValue subDecoder value of
                Ok val ->
                    val

                Err msg ->
                    let
                        _ =
                            Debug.log "⚠ Leaflet invalid sub: " msg
                    in
                        Unknown

        instance_ =
            case Decode.decodeValue instanceDecoder value of
                Ok instanceId ->
                    instanceId

                Err msg ->
                    let
                        _ =
                            Debug.log "⚠ Leaflet invalid instance: " msg
                    in
                        ""
    in
        ( instance_, sub_ )


instanceDecoder : Decoder String
instanceDecoder =
    Decode.field "id" Decode.string


subDecoder : Decoder LeafletSub
subDecoder =
    let
        click =
            decode
                Coordinates
                |> required "lat" Decode.float
                |> required "lng" Decode.float
                |> Decode.map Click

        byType t =
            case t of
                "click" ->
                    click

                _ ->
                    Decode.fail <| commonError "unknown sub type" t

        typeField =
            Decode.field "sub" Decode.string
    in
        Decode.andThen byType typeField
