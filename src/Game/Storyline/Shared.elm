module Game.Storyline.Shared exposing (..)

import Dict exposing (Dict)
import Time exposing (Time)


type alias ContactId =
    String


type alias PastEmails =
    Dict Time PastEmail


type PastEmail
    = FromContact Reply
    | FromPlayer Reply


type Reply
    = AboutThat
    | BackThanks
    | DownloadCracker1 SomeIP
    | Downloaded
    | HellYeah
    | NastyVirus1
    | NothingNow
    | WatchIADoing
    | Welcome
    | YeahRight


type alias SomeIP =
    String


type Objective
    = DownloadCracker
    | VirusInquiry
    | CleanUp
    | Grandmadness


type Step
    = Tutorial_SetupPC
    | Tutorial_DownloadCracker


type Quest
    = Tutorial


type alias About =
    { nick : String
    , picture : String
    }
