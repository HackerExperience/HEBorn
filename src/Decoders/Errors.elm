module Decoders.Errors exposing (..)

import Json.Decode as Decode
    exposing
        ( Decoder
        , succeed
        , field
        , string
        )


-- WIP


data : Decoders String
data =
    field "message" generic


generic : Decoders String
generic =
    oneOf [ common, unexpected ]


{-| Most of the errors are commons.
-}
common : Decoders String
common =
    string


{-| Errors from bad requests.
-}
unexpected : Decoders String
unexpected =
    string
