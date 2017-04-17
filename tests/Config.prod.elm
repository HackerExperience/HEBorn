module Config exposing (..)

{- Config values for test env (used on CI server).
   There's no easy way to read external input on Elm, so you probably want
   to copy this file into `Config.elm` after checkout.
-}


baseFuzzRuns =
    100
