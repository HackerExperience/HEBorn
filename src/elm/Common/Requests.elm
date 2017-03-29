module Common.Requests exposing (..)

import Task
import Json.Encode

import Requests.Models exposing (RequestPayloadArgs(..), RequestPayload)

msgToCmd msg =
    Task.perform (always msg) (Task.succeed ())


encodeRequest : RequestPayload -> String
encodeRequest payload =
    Json.Encode.encode 0
      (Json.Encode.object
          [ ("topic", Json.Encode.string payload.topic)
          , ("args", encodeArgs payload.args )
          ])

encodeArgs : RequestPayloadArgs -> Json.Encode.Value
encodeArgs args =
    case args of
        RequestUsernamePayload payloadArgs ->
            Json.Encode.object
                [ ("user", Json.Encode.string payloadArgs.user)
                , ("password", Json.Encode.string payloadArgs.password)]
        RequestEmailVerificationPayload payloadArgs ->
            Json.Encode.object
                [ ("email", Json.Encode.string payloadArgs.email )]
