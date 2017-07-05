module Css.Gradients exposing (..)

import Css exposing (Style, backgroundImage, linearGradient2, toBottom, stop, stop2, hex, pct)


-- AUTO Generated from: https://raw.githubusercontent.com/ghosh/uiGradients/master/gradients.json
-- replaced "name": "([\w ]*) with "name": "\E$1
-- replaced "(\w*) (\w) with ""$1\U$2
-- used regex: /^\s*{\s*"name": "([\' \w0-9]*)",\s*"colors": \["#([a-f0-9]*)", "#([a-f0-9]*)", "#([a-f0-9]*)"\]\s*},?/g
-- and with fewer color samples


gradient2 : String -> String -> Style
gradient2 c1 c2 =
    backgroundImage <|
        linearGradient2 toBottom (stop <| hex c1) (stop <| hex c2) []


gradient3 : String -> String -> String -> Style
gradient3 c1 c2 c3 =
    backgroundImage <|
        linearGradient2 toBottom (stop2 (hex c1) (pct 0)) (stop2 (hex c2) (pct 0)) [ (stop <| hex c3) ]


sel : Style
sel =
    gradient2 "00467F" "A5CC82"


dimigo : Style
dimigo =
    gradient2 "ec008c" "fc6767"


purpleLove : Style
purpleLove =
    gradient2 "cc2b5e" "753a88"


sexyBlue : Style
sexyBlue =
    gradient2 "2193b0" "6dd5ed"


blooker20 : Style
blooker20 =
    gradient2 "e65c00" "F9D423"


seaBlue : Style
seaBlue =
    gradient2 "2b5876" "4e4376"


nimvelo : Style
nimvelo =
    gradient2 "314755" "26a0da"


hazel : Style
hazel =
    gradient3 "77A1D3" "79CBCA" "E684AE"


noonToDusk : Style
noonToDusk =
    gradient2 "ff6e7f" "bfe9ff"


youtube : Style
youtube =
    gradient2 "e52d27" "b31217"


rown : Style
rown =
    gradient2 "603813" "b29f94"


harmonicEnergy : Style
harmonicEnergy =
    gradient2 "16A085" "F4D03F"


playingWithReds : Style
playingWithReds =
    gradient2 "D31027" "EA384D"


sunnyDays : Style
sunnyDays =
    gradient2 "EDE574" "E1F5C4"


greenBeach : Style
greenBeach =
    gradient2 "02AAB0" "00CDAC"


intuitivePurple : Style
intuitivePurple =
    gradient2 "DA22FF" "9733EE"


emeraldWater : Style
emeraldWater =
    gradient2 "348F50" "56B4D3"


lemonTwist : Style
lemonTwist =
    gradient2 "3CA55C" "B5AC49"


monteCarlo : Style
monteCarlo =
    gradient3 "CC95C0" "DBD4B4" "7AA1D2"


horizon : Style
horizon =
    gradient2 "003973" "E5E5BE"


roseWater : Style
roseWater =
    gradient2 "E55D87" "5FC3E4"


frozen : Style
frozen =
    gradient2 "403B4A" "E7E9BB"


mangoPulp : Style
mangoPulp =
    gradient2 "F09819" "EDDE5D"


bloodyMary : Style
bloodyMary =
    gradient2 "FF512F" "DD2476"


aubergine : Style
aubergine =
    gradient2 "AA076B" "61045F"


aquaMarine : Style
aquaMarine =
    gradient2 "1A2980" "26D0CE"


sunrise : Style
sunrise =
    gradient2 "FF512F" "F09819"


purpleParadise : Style
purpleParadise =
    gradient2 "1D2B64" "F8CDDA"


stripe : Style
stripe =
    gradient3 "1FA2FF" "12D8FA" "A6FFCB"


seaWeed : Style
seaWeed =
    gradient2 "4CB8C4" "3CD3AD"


pinky : Style
pinky =
    gradient2 "DD5E89" "F7BB97"


cherry : Style
cherry =
    gradient2 "EB3349" "F45C43"


mojito : Style
mojito =
    gradient2 "1D976C" "93F9B9"


juicyOrange : Style
juicyOrange =
    gradient2 "FF8008" "FFC837"


mirage : Style
mirage =
    gradient2 "16222A" "3A6073"


steelGray : Style
steelGray =
    gradient2 "1F1C2C" "928DAB"


kashmir : Style
kashmir =
    gradient2 "614385" "516395"


electricViolet : Style
electricViolet =
    gradient2 "4776E6" "8E54E9"


veniceBlue : Style
veniceBlue =
    gradient2 "085078" "85D8CE"


boraBora : Style
boraBora =
    gradient2 "2BC0E4" "EAECC6"


moss : Style
moss =
    gradient2 "134E5E" "71B280"


shroomHaze : Style
shroomHaze =
    gradient2 "5C258D" "4389A2"


mystic : Style
mystic =
    gradient2 "757F9A" "D7DDE8"


midnightCity : Style
midnightCity =
    gradient2 "232526" "414345"


seaBlizz : Style
seaBlizz =
    gradient2 "1CD8D2" "93EDC7"


opa : Style
opa =
    gradient2 "3D7EAA" "FFE47A"


titanium : Style
titanium =
    gradient2 "283048" "859398"


mantle : Style
mantle =
    gradient2 "24C6DC" "514A9D"


dracula : Style
dracula =
    gradient2 "DC2424" "4A569D"


peach : Style
peach =
    gradient2 "ED4264" "FFEDBC"


moonrise : Style
moonrise =
    gradient2 "DAE2F8" "D6A4A4"


clouds : Style
clouds =
    gradient2 "ECE9E6" "FFFFFF"


stellar : Style
stellar =
    gradient2 "7474BF" "348AC7"


bourbon : Style
bourbon =
    gradient2 "EC6F66" "F3A183"


calmDarya : Style
calmDarya =
    gradient2 "5f2c82" "49a09d"


influenza : Style
influenza =
    gradient2 "C04848" "480048"


shrimpy : Style
shrimpy =
    gradient2 "e43a15" "e65245"


army : Style
army =
    gradient2 "414d0b" "727a17"


miaka : Style
miaka =
    gradient2 "FC354C" "0ABFBC"


pinotNoir : Style
pinotNoir =
    gradient2 "4b6cb7" "182848"


dayTripper : Style
dayTripper =
    gradient2 "f857a6" "ff5858"


namn : Style
namn =
    gradient2 "a73737" "7a2828"


blurryBeach : Style
blurryBeach =
    gradient2 "d53369" "cbad6d"


vasily : Style
vasily =
    gradient2 "e9d362" "333333"


aLostMemory : Style
aLostMemory =
    gradient2 "DE6262" "FFB88C"


petrichor : Style
petrichor =
    gradient2 "666600" "999966"


jonquil : Style
jonquil =
    gradient2 "FFEEEE" "DDEFBB"


siriusTamed : Style
siriusTamed =
    gradient2 "EFEFBB" "D4D3DD"


kyoto : Style
kyoto =
    gradient2 "c21500" "ffc500"


mistyMeadow : Style
mistyMeadow =
    gradient2 "215f00" "e4e4d9"


aqualicious : Style
aqualicious =
    gradient2 "50C9C3" "96DEDA"


moor : Style
moor =
    gradient2 "616161" "9bc5c3"


almost : Style
almost =
    gradient2 "ddd6f3" "faaca8"


foreverLost : Style
foreverLost =
    gradient2 "5D4157" "A8CABA"


winter : Style
winter =
    gradient2 "E6DADA" "274046"


autumn : Style
autumn =
    gradient2 "DAD299" "B0DAB9"


candy : Style
candy =
    gradient2 "D3959B" "BFE6BA"


reef : Style
reef =
    gradient2 "00d2ff" "3a7bd5"


theStrain : Style
theStrain =
    gradient2 "870000" "190A05"


dirtyFog : Style
dirtyFog =
    gradient2 "B993D6" "8CA6DB"


earthly : Style
earthly =
    gradient2 "649173" "DBD5A4"


virgin : Style
virgin =
    gradient2 "C9FFBF" "FFAFBD"


ash : Style
ash =
    gradient2 "606c88" "3f4c6b"


shadowNight : Style
shadowNight =
    gradient2 "000000" "53346D"


cherryblossoms : Style
cherryblossoms =
    gradient2 "FBD3E9" "BB377D"


parklife : Style
parklife =
    gradient2 "ADD100" "7B920A"


danceToForget : Style
danceToForget =
    gradient2 "FF4E50" "F9D423"


starfall : Style
starfall =
    gradient2 "F0C27B" "4B1248"


redMist : Style
redMist =
    gradient2 "000000" "e74c3c"


tealLove : Style
tealLove =
    gradient2 "AAFFA9" "11FFBD"


neonLife : Style
neonLife =
    gradient2 "B3FFAB" "12FFF7"


manOfSteel : Style
manOfSteel =
    gradient2 "780206" "061161"


amethyst : Style
amethyst =
    gradient2 "9D50BB" "6E48AA"


cheerUpEmoKid : Style
cheerUpEmoKid =
    gradient2 "556270" "FF6B6B"


shore : Style
shore =
    gradient2 "70e1f5" "ffd194"


facebookMessenger : Style
facebookMessenger =
    gradient2 "00c6ff" "0072ff"


soundcloud : Style
soundcloud =
    gradient2 "fe8c00" "f83600"


behongo : Style
behongo =
    gradient2 "52c234" "061700"


servquick : Style
servquick =
    gradient2 "485563" "29323c"


friday : Style
friday =
    gradient2 "83a4d4" "b6fbff"


martini : Style
martini =
    gradient2 "FDFC47" "24FE41"


metallicToad : Style
metallicToad =
    gradient2 "abbaab" "ffffff"


betweenTheClouds : Style
betweenTheClouds =
    gradient2 "73C8A9" "373B44"


crazyOrangeI : Style
crazyOrangeI =
    gradient2 "D38312" "A83279"


hersheys : Style
hersheys =
    gradient2 "1e130c" "9a8478"


talkingToMiceElf : Style
talkingToMiceElf =
    gradient2 "948E99" "2E1437"


purpleBliss : Style
purpleBliss =
    gradient2 "360033" "0b8793"


predawn : Style
predawn =
    gradient2 "FFA17F" "00223E"


endlessRiver : Style
endlessRiver =
    gradient2 "43cea2" "185a9d"


pastelOrangeAtTheSun : Style
pastelOrangeAtTheSun =
    gradient2 "ffb347" "ffcc33"


twitch : Style
twitch =
    gradient2 "6441A5" "2a0845"


atlas : Style
atlas =
    gradient3 "FEAC5E" "C779D0" "4BC0C8"


instagram : Style
instagram =
    gradient3 "833ab4" "fd1d1d" "fcb045"


flickr : Style
flickr =
    gradient2 "ff0084" "33001b"


vine : Style
vine =
    gradient2 "00bf8f" "001510"


turquoiseFlow : Style
turquoiseFlow =
    gradient2 "136a8a" "267871"


portrait : Style
portrait =
    gradient2 "8e9eab" "eef2f3"


virginAmerica : Style
virginAmerica =
    gradient2 "7b4397" "dc2430"


kokoCaramel : Style
kokoCaramel =
    gradient2 "D1913C" "FFD194"


freshTurboscent : Style
freshTurboscent =
    gradient2 "F1F2B5" "135058"


greenToDark : Style
greenToDark =
    gradient2 "6A9113" "141517"


ukraine : Style
ukraine =
    gradient2 "004FF9" "FFF94C"


curiosityBlue : Style
curiosityBlue =
    gradient2 "525252" "3d72b4"


darkKnight : Style
darkKnight =
    gradient2 "BA8B02" "181818"


piglet : Style
piglet =
    gradient2 "ee9ca7" "ffdde1"


lizard : Style
lizard =
    gradient2 "304352" "d7d2cc"


sagePersuasion : Style
sagePersuasion =
    gradient2 "CCCCB2" "757519"


betweenNightAndDay : Style
betweenNightAndDay =
    gradient2 "2c3e50" "3498db"


timber : Style
timber =
    gradient2 "fc00ff" "00dbde"


passion : Style
passion =
    gradient2 "e53935" "e35d5b"


clearSky : Style
clearSky =
    gradient2 "005C97" "363795"


masterCard : Style
masterCard =
    gradient2 "f46b45" "eea849"


backToEarth : Style
backToEarth =
    gradient2 "00C9FF" "92FE9D"


deepPurple : Style
deepPurple =
    gradient2 "673AB7" "512DA8"


littleLeaf : Style
littleLeaf =
    gradient2 "76b852" "8DC26F"


netflix : Style
netflix =
    gradient2 "8E0E00" "1F1C18"


lightOrange : Style
lightOrange =
    gradient2 "FFB75E" "ED8F03"


greenAndBlue : Style
greenAndBlue =
    gradient2 "c2e59c" "64b3f4"


poncho : Style
poncho =
    gradient2 "403A3E" "BE5869"


backToTheFuture : Style
backToTheFuture =
    gradient2 "C02425" "F0CB35"


blush : Style
blush =
    gradient2 "B24592" "F15F79"


inbox : Style
inbox =
    gradient2 "457fca" "5691c8"


purplin : Style
purplin =
    gradient2 "6a3093" "a044ff"


paleWood : Style
paleWood =
    gradient2 "eacda3" "d6ae7b"


haikus : Style
haikus =
    gradient2 "fd746c" "ff9068"


pizelex : Style
pizelex =
    gradient2 "114357" "F29492"


joomla : Style
joomla =
    gradient2 "1e3c72" "2a5298"


christmas : Style
christmas =
    gradient2 "2F7336" "AA3A38"


minnesotaVikings : Style
minnesotaVikings =
    gradient2 "5614B0" "DBD65C"


miamiDolphins : Style
miamiDolphins =
    gradient2 "4DA0B0" "D39D38"


forest : Style
forest =
    gradient2 "5A3F37" "2C7744"


nighthawk : Style
nighthawk =
    gradient2 "2980b9" "2c3e50"


superman : Style
superman =
    gradient2 "0099F7" "F11712"


suzy : Style
suzy =
    gradient2 "834d9b" "d04ed6"


darkSkies : Style
darkSkies =
    gradient2 "4B79A1" "283E51"


deepSpace : Style
deepSpace =
    gradient2 "000000" "434343"


decent : Style
decent =
    gradient2 "4CA1AF" "C4E0E5"


colorsOfSky : Style
colorsOfSky =
    gradient2 "E0EAFC" "CFDEF3"


purpleWhite : Style
purpleWhite =
    gradient2 "BA5370" "F4E2D8"


ali : Style
ali =
    gradient2 "ff4b1f" "1fddff"


alihossein : Style
alihossein =
    gradient2 "f7ff00" "db36a4"


shahabi : Style
shahabi =
    gradient2 "a80077" "66ff00"


redOcean : Style
redOcean =
    gradient2 "1D4350" "A43931"


tranquil : Style
tranquil =
    gradient2 "EECDA3" "EF629F"


transfile : Style
transfile =
    gradient2 "16BFFD" "CB3066"


sylvia : Style
sylvia =
    gradient2 "ff4b1f" "ff9068"


sweetMorning : Style
sweetMorning =
    gradient2 "FF5F6D" "FFC371"


politics : Style
politics =
    gradient2 "2196f3" "f44336"


brightVault : Style
brightVault =
    gradient2 "00d2ff" "928DAB"


solidVault : Style
solidVault =
    gradient2 "3a7bd5" "3a6073"


sunset : Style
sunset =
    gradient2 "0B486B" "F56217"


grapefruitSunset : Style
grapefruitSunset =
    gradient2 "e96443" "904e95"


deepSeaSpace : Style
deepSeaSpace =
    gradient2 "2C3E50" "4CA1AF"


dusk : Style
dusk =
    gradient2 "2C3E50" "FD746C"


minimalRed : Style
minimalRed =
    gradient2 "F00000" "DC281E"


royal : Style
royal =
    gradient2 "141E30" "243B55"


mauve : Style
mauve =
    gradient2 "42275a" "734b6d"


frost : Style
frost =
    gradient2 "000428" "004e92"


lush : Style
lush =
    gradient2 "56ab2f" "a8e063"


firewatch : Style
firewatch =
    gradient2 "cb2d3e" "ef473a"


sherbert : Style
sherbert =
    gradient2 "f79d00" "64f38c"


bloodRed : Style
bloodRed =
    gradient2 "f85032" "e73827"


sunOnTheHorizon : Style
sunOnTheHorizon =
    gradient2 "fceabb" "f8b500"


iiitDelhi : Style
iiitDelhi =
    gradient2 "808080" "3fada8"


dusk2 : Style
dusk2 =
    gradient2 "ffd89b" "19547b"


fiftyShadesOfGrey : Style
fiftyShadesOfGrey =
    gradient2 "bdc3c7" "2c3e50"


dania : Style
dania =
    gradient2 "BE93C5" "7BC6CC"


limeade : Style
limeade =
    gradient2 "A1FFCE" "FAFFD1"


disco : Style
disco =
    gradient2 "4ECDC4" "556270"


loveCouple : Style
loveCouple =
    gradient2 "3a6186" "89253e"


azurePop : Style
azurePop =
    gradient2 "ef32d9" "89fffd"


nepal : Style
nepal =
    gradient2 "de6161" "2657eb"


cosmicFusion : Style
cosmicFusion =
    gradient2 "ff00cc" "333399"


snapchat : Style
snapchat =
    gradient2 "fffc00" "ffffff"


edsSunsetGradient : Style
edsSunsetGradient =
    gradient2 "ff7e5f" "feb47b"


bradyBradyFunFun : Style
bradyBradyFunFun =
    gradient2 "00c3ff" "ffff1c"


blackRose : Style
blackRose =
    gradient2 "f4c4f3" "fc67fa"


eightysPurple : Style
eightysPurple =
    gradient2 "41295a" "2F0743"


radar : Style
radar =
    gradient3 "A770EF" "CF8BF3" "FDB99B"


ibizaSunset : Style
ibizaSunset =
    gradient2 "ee0979" "ff6a00"


dawn : Style
dawn =
    gradient2 "F3904F" "3B4371"


mild : Style
mild =
    gradient2 "67B26F" "4ca2cd"


viceCity : Style
viceCity =
    gradient2 "3494E6" "EC6EAD"


jaipur : Style
jaipur =
    gradient2 "DBE6F6" "C5796D"


cocoaaIce : Style
cocoaaIce =
    gradient2 "c0c0aa" "1cefff"


easymed : Style
easymed =
    gradient2 "DCE35B" "45B649"


roseColoredLenses : Style
roseColoredLenses =
    gradient2 "E8CBC0" "636FA4"


whatLiesBeyond : Style
whatLiesBeyond =
    gradient2 "F0F2F0" "000C40"


roseanna : Style
roseanna =
    gradient2 "FFAFBD" "ffc3a0"


honeyDew : Style
honeyDew =
    gradient2 "43C6AC" "F8FFAE"


underTheLake : Style
underTheLake =
    gradient2 "093028" "237A57"


theBlueLagoon : Style
theBlueLagoon =
    gradient2 "43C6AC" "191654"


canYouFeelTheLoveTonight : Style
canYouFeelTheLoveTonight =
    gradient2 "4568DC" "B06AB3"


veryBlue : Style
veryBlue =
    gradient2 "0575E6" "021B79"


loveAndLiberty : Style
loveAndLiberty =
    gradient2 "200122" "6f0000"


orca : Style
orca =
    gradient2 "44A08D" "093637"


venice : Style
venice =
    gradient2 "6190E8" "A7BFE8"


pacificDream : Style
pacificDream =
    gradient2 "34e89e" "0f3443"


learningAndLeading : Style
learningAndLeading =
    gradient2 "F7971E" "FFD200"


celestial : Style
celestial =
    gradient2 "C33764" "1D2671"


purplepine : Style
purplepine =
    gradient2 "20002c" "cbb4d4"


shaLaLa : Style
shaLaLa =
    gradient2 "D66D75" "E29587"


mini : Style
mini =
    gradient2 "30E8BF" "FF8235"


maldives : Style
maldives =
    gradient2 "B2FEFA" "0ED2F7"


cinnamint : Style
cinnamint =
    gradient2 "4AC29A" "BDFFF3"


html : Style
html =
    gradient2 "E44D26" "F16529"


coal : Style
coal =
    gradient2 "EB5757" "000000"


sunkist : Style
sunkist =
    gradient2 "F2994A" "F2C94C"


blueSkies : Style
blueSkies =
    gradient2 "56CCF2" "2F80ED"


chittyChittyBangBang : Style
chittyChittyBangBang =
    gradient2 "007991" "78ffd6"


visionsOfGrandeur : Style
visionsOfGrandeur =
    gradient2 "000046" "1CB5E0"


crystalClear : Style
crystalClear =
    gradient2 "159957" "155799"


mello : Style
mello =
    gradient2 "c0392b" "8e44ad"


compareNow : Style
compareNow =
    gradient2 "EF3B36" "FFFFFF"


meridian : Style
meridian =
    gradient2 "283c86" "45a247"


relay : Style
relay =
    gradient3 "3A1C71" "D76D77" "FFAF7B"


alive : Style
alive =
    gradient2 "CB356B" "BD3F32"


scooter : Style
scooter =
    gradient2 "36D1DC" "5B86E5"


terminal : Style
terminal =
    gradient2 "000000" "0f9b0f"


telegram : Style
telegram =
    gradient2 "1c92d2" "f2fcfe"


crimsonTide : Style
crimsonTide =
    gradient2 "642B73" "C6426E"


socialive : Style
socialive =
    gradient2 "06beb6" "48b1bf"


subu : Style
subu =
    gradient3 "0cebeb" "20e3b2" "29ffc6"


shift : Style
shift =
    gradient3 "000000" "E5008D" "FF070B"


clot : Style
clot =
    gradient3 "070000" "4C0001" "070000"


brokenHearts : Style
brokenHearts =
    gradient2 "d9a7c7" "fffcdc"


kimobyIsTheNewBlue : Style
kimobyIsTheNewBlue =
    gradient2 "396afc" "2948ff"


dull : Style
dull =
    gradient2 "C9D6FF" "E2E2E2"


purpink : Style
purpink =
    gradient2 "7F00FF" "E100FF"


orangeCoral : Style
orangeCoral =
    gradient2 "ff9966" "ff5e62"


summer : Style
summer =
    gradient2 "22c1c3" "fdbb2d"


kingYna : Style
kingYna =
    gradient3 "1a2a6c" "b21f1f" "fdbb2d"


velvetSun : Style
velvetSun =
    gradient2 "e1eec3" "f05053"
