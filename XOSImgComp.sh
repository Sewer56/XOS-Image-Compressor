#!/bin/sh

#  XOS Image Compressor: A fetcher, updater & wrapper for JPG/PNG compression utilities.
#  Copyright (C) 2016 - Seweryn Sz. / Sewer56lol
#
#  XOS Image Compressor is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#  An original copy of the GPL v3 license can be found inside LICENSE.md.

###############################
## ?88,  88P d8888b  .d888b, ##
##  `?8bd8P'd8P' ?88 ?8b,    ##
##  d8P?8b, 88b  d88   `?8b  ##
## d8P' `?8b`?8888P'`?888P'  ##
###############################
## XOS -halogenos.org - WIP  ##
###############################

## Declare the Working Variable
WORKING_DIRECTORY="${0%/*}"
CPU_CORES="$((`nproc`-1))"
WINE="wine"
SCRIPT_PATH="$0"
clear

## Script Init Control Variables
DEPENDENCY_ARRAY=("advdef" "optipng" "pngcrush" "pngquant" "zopflipng" )
SYSTEM_DEPENDENCY_ARRAY=("tput" "wine")
NONFREEDEPENDENCY_ARRAY=("pngout" "TruePNG.exe" "pingo.exe")
NONFREE_STATUS=N
HAS_DEPENDENCIES=Y
HAS_SYSTEM_DEPENDENCIES=Y;

## Script SETTINGS/CONTROL VARIABLES
COMPRESSION_LEVEL=2
JPEG_LOSSY_MODE=0
LOSSY_MODE=0
STRIP_MODE=1
FREE_MODE=0
QUANT_MODE=1

## Shell In-Replacement Colours For Text - Sewer Palette
ColourReset=`tput sgr0`
ColourReset2=`tput sgr0` ##Used if one wants to later change UI colours by a simple regex replace
ColourStandout=`tput smso`
ColourNameText=`tput setaf 3`
ColourLabel=`tput setaf 3`
ColourTrack=`tput setaf 6`
ColourTrack2=`tput setaf 5`
ColourItem=`tput setaf 2`
ColourBold=`tput bold`
ColourWarning=`tput setaf 15`
ColourInfo=`tput setaf 10`
ColourInfoSub=`tput setaf 10`

## Shell In-Replacement for All Text Colours!
AllColourReset="tput sgr0"
AllColourBold="tput bold"
AllColourWarning="tput setaf 15"
AllColourInfo="tput setaf 10"

## Misc
ISSUESSTRING="If you have any issues then try running the updater script again & updating"

## For When input is a directory
Images=()
OldDirectorySize=0
NewDirectorySize=0
AmountOfFiles=0
FilesProcessed=0

CompareSize(){
  if [[ -f "${Input}.new" ]]; then
    local NewSize=$(stat -c %s "${Input}.new")
    if [[ $NewSize -lt $PreviousSize ]]; then
      rm -rf "${Input}"
      mv "${Input}.new" "${Input}"
    else
      rm -rf "${Input}.new"
    fi
  fi
}

## Compressor Size Comparison Wrapper
SizeWrapper() {
  local PreviousSize=$(stat -c %s "${Input}")
  $1 "${Input}" "${Input}.new" &> /dev/null
  CompareSize
}


## Set extra flags for options
SetExtraFlags() {
  if [[ ${STRIP_MODE} -eq 0 ]]; then
    TruePNGStripMetadata=""
    PNGOutStripMetadata="-k1"
    ECTStripMetadata=""
    JPEGOptimStripMetadata=""
    JPEGArchiveStripMetadata=""
  fi
}

## Default flags
TruePNGStripMetadata="/md remove all"
PNGOutStripMetadata="-k0"
ECTStripMetadata="-strip"
JPEGOptimStripMetadata="--strip-all"
JPEGArchiveStripMetadata="--strip"


## Brute Force Section
CompressZopfliPNG () { SizeWrapper "$WORKING_DIRECTORY/bin/zopflipng -m -y --filters=01234mepb --lossy_8bit --lossy_transparent" &> /dev/null; }
CompressADVDef () { $WORKING_DIRECTORY/bin/advdef -z4 "${Input}" &> /dev/null; }
CompressTruePNG() { $WINE cmd.exe /c $WORKING_DIRECTORY/bin/TruePNG.exe "${Input}" "/zc9 /zm1-9 /zs0,1,3 /fe /a1 /i0 ${TruePNGStripMetadata}" &> /dev/null; }
CompressPNGOut() { $WORKING_DIRECTORY/bin/pngout -k0 ${PNGOutStripMetadata} "${Input}" &> /dev/null; }
CompressPNGCrush() { SizeWrapper "$WORKING_DIRECTORY/bin/pngcrush -brute -blacken "${Input}" "${Input}.new"" &> /dev/null; }
CompressOptiPNG() { $WORKING_DIRECTORY/bin/optipng -o7 "${Input}" &> /dev/null; }


## Default Section
CompressPingo() { if [ ${STRIP_MODE} -eq 1 ]; then $WINE "$WORKING_DIRECTORY/bin/Pingo.exe" -s7 "${Input}" &> /dev/null; fi }
CompressPNGQuant() { if [ ${QUANT_MODE} -eq 1 ]; then "$WORKING_DIRECTORY/bin/pngquant" --skip-if-larger --output "${Input}.new.pngquant" --quality 100-100 --speed 1 "${Input}" &> /dev/null; PNGQuantReductionCheck; fi }
CompressPNGQuantLossy() { if [ ${QUANT_MODE} -eq 1 ]; then "$WORKING_DIRECTORY/bin/pngquant" --skip-if-larger --output "${Input}.new.pngquant" --quality 93-100 --speed 1 "${Input}" &> /dev/null; PNGQuantReductionCheck; fi }
CompressPNGQuantLooseLossy() { if [ ${QUANT_MODE} -eq 1 ]; then "$WORKING_DIRECTORY/bin/pngquant" --skip-if-larger --output "${Input}.new.pngquant" --quality 70-100 --speed 1 "${Input}" &> /dev/null; PNGQuantReductionCheck; fi }
CompressECTFast() { "$WORKING_DIRECTORY/bin/ect" -3 ${ECTStripMetadata} -quiet "${Input}" &> /dev/null;}
CompressECTMax() { "$WORKING_DIRECTORY/bin/ect" -8 ${ECTStripMetadata} -quiet --allfilters-b "${Input}" &> /dev/null;}
CompressECT() { "$WORKING_DIRECTORY/bin/ect" -8 ${ECTStripMetadata} -quiet "${Input}" &> /dev/null;}

## JPEG Section
CompressJPEGOptim() { "$WORKING_DIRECTORY/bin/jpegoptim" ${JPEGOptimStripMetadata} "${Input}" &> /dev/null; }
CompressJPEGArchive() { SizeWrapper "$WORKING_DIRECTORY/bin/jpegrecompress --min 100 --max 100 --accurate -m smallfry ${JPEGArchiveStripMetadata} -Q"; }
CompressJPEGArchiveLossy() { SizeWrapper "$WORKING_DIRECTORY/bin/jpegrecompress --quality veryhigh --accurate --method smallfry ${JPEGArchiveStripMetadata} -Q"; }

## Extra
PNGQuantReductionCheck() {
  if [[ -f "${Input}.new.pngquant" ]]; then
    rm -rf "${Input}"
    mv "${Input}.new.pngquant" "${Input}" &> /dev/null
  fi
}

CompressionLevelOne(){
  if [[ ${Input##*.} == jpg ]] || [[ ${Input##*.} == jpeg ]]; then
    case "$FREE_MODE" in
      0 ) CompressPingo; CompressJPEGOptim; if [[ $JPEG_LOSSY_MODE == 1 ]]; then CompressJPEGArchiveLossy; else CompressJPEGArchive; fi;;
      1 ) CompressJPEGOptim; if [[ $JPEG_LOSSY_MODE == 1 ]]; then CompressJPEGArchiveLossy; else CompressJPEGArchive; fi;;
    esac
    return
  fi

  ## Pingo does not overwrite on failure to compress more.
  case "$LOSSY_MODE" in
    0 ) CompressPNGQuant;;
    1 ) CompressPNGQuantLossy;;
    2 ) CompressPNGQuantLooseLossy;;
  esac
  case "$FREE_MODE" in
    0 ) CompressPingo; CompressECTFast;;
    1 ) CompressECTFast;;
  esac
}

CompressionLevelTwo(){
  if [[ ${Input##*.} == jpg ]] || [[ ${Input##*.} == jpeg ]]; then
    case "$FREE_MODE" in
      0 ) CompressPingo; CompressJPEGOptim; if [[ $JPEG_LOSSY_MODE == 1 ]]; then CompressJPEGArchiveLossy; else CompressJPEGArchive; fi;;
      1 ) CompressJPEGOptim; if [[ $JPEG_LOSSY_MODE == 1 ]]; then CompressJPEGArchiveLossy; else CompressJPEGArchive; fi;;
    esac
    return
  fi

  case "$LOSSY_MODE" in
    0 ) CompressPNGQuant;;
    1 ) CompressPNGQuantLossy;;
    2 ) CompressPNGQuantLooseLossy;;
  esac
  case "$FREE_MODE" in
    0 ) CompressPingo; CompressECT;;
    1 ) CompressECT;;
  esac
}

CompressionLevelThree(){
  if [[ ${Input##*.} == jpg ]] || [[ ${Input##*.} == jpeg ]]; then
    case "$FREE_MODE" in
      0 ) CompressPingo; CompressJPEGOptim; if [[ $JPEG_LOSSY_MODE == 1 ]]; then CompressJPEGArchiveLossy; else CompressJPEGArchive; fi;;
      1 ) CompressJPEGOptim; if [[ $JPEG_LOSSY_MODE == 1 ]]; then CompressJPEGArchiveLossy; else CompressJPEGArchive; fi;;
    esac
    return
  fi

  case "$LOSSY_MODE" in
    0 ) CompressPNGQuant;;
    1 ) CompressPNGQuantLossy;;
    2 ) CompressPNGQuantLooseLossy;;
  esac
  case "$FREE_MODE" in
    0 ) CompressPingo; CompressECTMax;;
    1 ) CompressECTMax;;
  esac
}

CompressionLevelFour(){
  if [[ ${Input##*.} == jpg ]] || [[ ${Input##*.} == jpeg ]]; then
    case "$FREE_MODE" in
      0 ) CompressPingo; CompressJPEGOptim; if [[ $JPEG_LOSSY_MODE == 1 ]]; then CompressJPEGArchiveLossy; else CompressJPEGArchive; fi;;
      1 ) CompressJPEGOptim; if [[ $JPEG_LOSSY_MODE == 1 ]]; then CompressJPEGArchiveLossy; else CompressJPEGArchive; fi;;
    esac
    return
  fi

  case "$LOSSY_MODE" in
    0 ) CompressPNGQuant;;
    1 ) CompressPNGQuantLossy;;
    2 ) CompressPNGQuantLooseLossy;;
  esac
  case "$FREE_MODE" in
    0 ) CompressPingo; CompressPNGOut; CompressTruePNG;;
  esac
  CompressECTMax
  CompressZopfliPNG
  CompressPNGCrush
  CompressOptiPNG
  CompressADVDef
}

CompressionPath(){
  SetExtraFlags
  case "$COMPRESSION_LEVEL" in
    1 ) CompressionLevelOne;;
    2 ) CompressionLevelTwo;;
    3 ) CompressionLevelThree;;
    4 ) CompressionLevelFour;;
  esac
}

CompressImage () {
  ## Measuring Size Before and The Size Difference
  ## $1 - Image File
  local Input="$1"
  local FileName=${Input##*/}

  local OriginalSize=$(stat -c %s "${Input}")

  ## Determine Compression Path and execute it. ## Actual Compression Goes Here.
  CompressionPath

  ## Measuring Size After and The Size Difference
  local NewSize=$(stat -c %s "${Input}")
  local SizeDiff=$((${OriginalSize} - ${NewSize}))

  if [[ SizeDiff -eq 0 ]]; then local SizePercentage="00.000";
  else local SizePercentage=$(echo "scale = 4; (( (${SizeDiff}/${OriginalSize})*100 ))" | bc | rev | cut -c 2- | rev); fi

  ## Namelength struct:
  ## 38 - originally intended length
  ## 132 max terminal size for layout

  ## Append invisible chars if the length of the current image file does not equal length of the max.
  if [[ ${#FilesProcessed} -lt ${#AmountOfFiles} ]]; then printf -v FilesProcessed "%${#AmountOfFiles}d" ${FilesProcessed}; fi

  if [[ `tput cols` -ge "132" ]]; then
    ## Dynamically adjust filename
    local Namelength=$((49 - $ReservedForCount + (`tput cols` - 132) ))
    if [[ ${#FileName} -gt $((Namelength)) ]]; then local FileName="$(echo "${Input##*/}" | cut -c1-$Namelength )..."; fi
    echo "${ColourInfo}($FilesProcessed/$AmountOfFiles)${ColourReset} | ${ColourInfoSub}File:${ColourReset} ${ColourReset2}$(printf "%$(($Namelength + 4))s" "${FileName}")${ColourReset} | ${ColourInfoSub}New Size:${ColourReset} ${ColourReset2}$(printf '%7s' $NewSize)${ColourReset} | ${ColourInfoSub}Bytes Saved:${ColourReset} ${ColourReset2}$(printf '%7s' $SizeDiff)${ColourReset} | ${ColourInfoSub}Percentage Saved:${ColourReset} ${ColourReset2}[$(printf '%6s' "${SizePercentage}")%]${ColourReset}"
  elif [[ `tput cols` -ge "96" ]]; then
    local Namelength=$((26 - $ReservedForCount + (`tput cols` - 89) ))
    if [[ ${#FileName} -gt $((Namelength)) ]]; then local FileName="$(echo "${Input##*/}" | cut -c1-$Namelength )..."; fi
    echo "${ColourInfo}($FilesProcessed/$AmountOfFiles)${ColourReset} | ${ColourInfoSub}File:${ColourReset} ${ColourReset2}$(printf "%$(($Namelength + 4))s" "${FileName}")${ColourReset} | ${ColourInfoSub}Bytes Saved:${ColourReset} ${ColourReset2}$(printf '%7s' $SizeDiff)${ColourReset} | ${ColourInfoSub}Percentage Saved:${ColourReset} ${ColourReset2}[$(printf '%6s' "${SizePercentage}")%]${ColourReset}"
  elif [[ `tput cols` -ge "73" ]]; then
    ## Shorter version for even lesser sized terminals.
    local Namelength=$((26 - $ReservedForCount + (`tput cols` - 66) ))
    if [[ ${#FileName} -gt $((Namelength)) ]]; then local FileName="$(echo "${Input##*/}" | cut -c1-$Namelength )..."; fi
    echo "${ColourInfo}($FilesProcessed/$AmountOfFiles)${ColourReset} | ${ColourInfoSub}File:${ColourReset} ${ColourReset2}$(printf "%$(($Namelength + 4))s" "${FileName}")${ColourReset} | ${ColourInfoSub}Percentage Saved:${ColourReset} ${ColourReset2}[$(printf '%6s' "${SizePercentage}")%]${ColourReset}"
  elif [[ `tput cols` -ge "51" ]]; then
    ## Shorter version for the lessest of terminals.
    local Namelength=$((26 - $ReservedForCount + (`tput cols` - 57) ))
    if [[ ${#FileName} -gt $((Namelength)) ]]; then local FileName="$(echo "${Input##*/}" | cut -c1-$Namelength )..."; fi
    echo "${ColourInfo}($FilesProcessed/$AmountOfFiles)${ColourReset} | ${ColourInfoSub}File:${ColourReset} ${ColourReset2}$(printf "%$(($Namelength + 4))s" "${FileName}")${ColourReset} | ${ColourWarning}% Saved:${ColourReset} ${ColourReset2}[$(printf '%6s' "${SizePercentage}")%]${ColourReset}"
  elif [[ `tput cols` -ge "44" ]]; then
    ## Shorter version for the lessest-est of terminals.
    local Namelength=$((26 - $ReservedForCount + (`tput cols` - 30) ))
    if [[ ${#FileName} -gt $((Namelength)) ]]; then local FileName="$(echo "${Input##*/}" | cut -c1-$Namelength )..."; fi
    echo "${ColourInfo}($FilesProcessed/$AmountOfFiles)${ColourReset} | ${ColourInfoSub}File:${ColourReset} ${ColourReset2}$(printf "%$(($Namelength + 4))s" "${FileName}")${ColourReset} | ${ColourReset2}[$(printf '%6s' "${SizePercentage}")%]${ColourReset}"
  else
    ## Shorter version for the lessest-est-est of terminals.
    local Namelength=$((26 - $ReservedForCount + (`tput cols` - 27) ))
    if [[ ${#FileName} -gt $((Namelength)) ]]; then local FileName="$(echo "${Input##*/}" | cut -c1-$Namelength )..."; fi
    echo "${ColourInfo}File:${ColourReset} ${ColourReset2}$(printf "%$(($Namelength + 4))s" "${FileName}")${ColourReset}"
  fi
}

CoreControl () {
  while [ `jobs | wc -l` -ge $CPU_CORES ]
  do
     sleep 1
  done
}

IdentifyInput () {
  if [[ -d ${UserInput} ]]; then
    ## Populate Images Array with Images
    OLDIFS=$IFS; IFS=$'\n'; for CompressImage in $(find ${UserInput} -name '*.png' -o -name '*.jpg' -o -name '*.jpeg'); do AmountOfFiles=$((AmountOfFiles + 1)); OldDirectorySize="$((${OldDirectorySize} + `stat -c %s "${CompressImage}"`))"; Images=("${Images[@]}" "$CompressImage"); done; IFS=$OLDIFS
    ## Reserved for file count in output / Length of the amount of files. ## 6 represents spaces, brackets and slashes.
    ReservedForCount=$(((${#AmountOfFiles}*2) + 6))

    for ((x=0; x<${#Images[@]}; x++))
    do
      CoreControl
      FilesProcessed=$((${FilesProcessed} + 1))
      CompressImage "${Images[x]}" &
    done

    ## Wait for all the BG Tasks to complete
    wait
    OLDIFS=$IFS; IFS=$'\n'; for CalculateTotalSize in $(find ${UserInput} -name '*.png' -o -name '*.jpg' -o -name '*.jpeg'); do NewDirectorySize="$((${NewDirectorySize} + `stat -c %s "${CalculateTotalSize}"`))"; done; IFS=$OLDIFS
    echo ""
    local SizeDiff=$((${OldDirectorySize} - ${NewDirectorySize}))
    if [[ SizeDiff -eq 0 ]]; then
      local SizePercentage="00.000"
    else
      local SizePercentage=$(echo "scale = 4; (( (${SizeDiff}/${OldDirectorySize})*100 ))" | bc | rev | cut -c 2- | rev)
    fi
    CenterTextHighlight "${ColourInfo}----------------------------${ColourReset}"
    CenterTextHighlight "${ColourInfo}Total Bytes Saved | ${ColourReset}$(printf '%8s' ${SizeDiff})"
    CenterTextHighlight "${ColourInfo} Percentage Saved | ${ColourReset}$(printf '%7s' ${SizePercentage})%"
    CenterTextHighlight "${ColourInfo}----------------------------${ColourReset}"
    exit

  #################################################################################################################
  elif [[ ! ${UserInput##*.} == png ]] && [[ ! ${UserInput##*.} == jpg ]] && [[ ! ${UserInput##*.} == jpeg ]]; then
    echo "Invalid File Path/Directory! Supported formats are .png, .jpg, .jpeg"
    exit

  elif [[ -f ${UserInput} ]]; then
    ## Input is a file
    AmountOfFiles=1
    FilesProcessed=1
    ReservedForCount=8
    CompressImage "$UserInput"
    exit
  else
    echo "User's input file/directory is not valid"
    exit
  fi
}

Center_Help_Vertical() {
  ## -12 lines as this is the amount of lines that is echoed afterward.
  if [[ $HAS_DEPENDENCIES == N ]] || [[ $HAS_SYSTEM_DEPENDENCIES == N ]]; then
    AmountOfEchoes=`awk '/##STARTSTARTSTART/,/##ENDENDEND/' "${SCRIPT_PATH}" | grep -e 'echo ' -e CenterText | wc -l`
  else
    AmountOfEchoes=`awk '/##STARTSTARTSTART/,/##ENDENDEND/' "${SCRIPT_PATH}" | grep -e 'echo ' -e CenterText | grep -v "then CenterTextHighlight" | grep -v "then CenterTextStandout" | wc -l`
  fi
  ArgsHeight=$(((`tput lines` - $AmountOfEchoes) / 2))
  for ((x=0; x<=$ArgsHeight; x++)); do
    echo ""
  done
}

  ## Calculates the alignment for argument descriptions.
Center_Help_Horizontal() {
  ArgsWidth=$((`tput cols` / 3))
  local IssuesTextLength=${#ISSUESSTRING}
  local TerminalWidth=$(tput cols)
  local TextSpan=$((($TerminalWidth + $IssuesTextLength) / 2))
  ArgsSpacing=$(($TextSpan - $IssuesTextLength))
}

CenterText(){
  local TextLength=${#1}
  local TerminalWidth=$(tput cols)
  local TextSpan=$((($TerminalWidth + $TextLength) / 2))
  printf "%${TextSpan}s\n" "$1"
}

## 1ST TPUT EXPANSION
## This is for tput being used ONCE to set and reset text.
CenterTextHighlight(){
  ## 11 characters are added because the expansion of tput will make 11 invisible characters.
  local TextLength=$((${#1} + 11))
  local TerminalWidth=$(tput cols)
  local TextSpan=$((($TerminalWidth + $TextLength) / 2))
  printf "%${TextSpan}s\n" "$1"
}

## 2ND TPUT EXPANSION
## This is for tput being used ONCE to set and reset text.
CenterTextStandout(){
  ## 10 characters are added because the expansion of tput will make 10 invisible characters.
  local TextLength=$((${#1} + 10))
  local TerminalWidth=$(tput cols)
  local TextSpan=$((($TerminalWidth + $TextLength) / 2))
  printf "%${TextSpan}s\n" "$1"
}

## NOTE: ARGUMENTS ARE ALIGNED TO THE ISSUES LINE, IF LINE CHANGES PLEASE REALIGN ARGUMENTS.

## START and END ARE JUST FOR MY AWKING PLEASURE, DO NOT BE OFFENDED :P
Display_Help() {
  ##STARTSTARTSTART
  Center_Help_Vertical ## Spaces to center message.
  Center_Help_Horizontal ## Spaces to center message args.
  echo ""
  CenterTextHighlight "${ColourInfo}XOS Image Compressor v0.69${ColourReset}"
  echo ""
  CenterTextHighlight "To compress simply specify ${ColourInfo}an image or directory${ColourReset} as an argument"
  echo ""
  CenterText "$ISSUESSTRING"
  CenterTextHighlight "Accepted file extensions: ${ColourInfo}png, jpg, jpeg${ColourReset}"
  echo ""

  ## The first printf offsets the text to begin at the same point as the 'if you have any issues' text
  echo "$(printf "%$(($ArgsSpacing))s" "")${ColourInfo}$(printf "%13s" "--c") ${ColourReset}| Compression level (1-4). Fast, Standard, Max & Brute Force"
  echo "$(printf "%$(($ArgsSpacing))s" "")${ColourInfo}$(printf "%13s" "--deps") ${ColourReset}| Check Utility and System Dependencies"
  echo "$(printf "%$(($ArgsSpacing))s" "")${ColourInfo}$(printf "%13s" "--lossy") ${ColourReset}| Reduce palette (pngquant) to 256 colours if Quality >= 70%"
  echo "$(printf "%$(($ArgsSpacing))s" "")${ColourInfo}$(printf "%13s" "--noquant") ${ColourReset}| Do not perform quantization. (PNGQuant -Q 100 can be lossy)"
  echo "$(printf "%$(($ArgsSpacing))s" "")${ColourInfo}$(printf "%13s" "--nostrip") ${ColourReset}| Do not strip metadata from the images."
  echo "$(printf "%$(($ArgsSpacing))s" "")${ColourInfo}$(printf "%13s" "--lossy-trans") ${ColourReset}| Reduce palette (pngquant) to 256 colours if Quality >= 93%"
  echo "$(printf "%$(($ArgsSpacing))s" "")${ColourInfo}$(printf "%13s" "--jpeg-lossy") ${ColourReset}| Target 93% Quality for JPEG images (default: 100% lossless)"
  echo "$(printf "%$(($ArgsSpacing))s" "")${ColourInfo}$(printf "%13s" "--stallman") ${ColourReset}| Do not use nonfree software even if installed by the updater"
  echo "$(printf "%$(($ArgsSpacing))s" "")${ColourInfo}$(printf "%13s" "--WSL") ${ColourReset}| Use if using Windows Subsystem for Linux (Creators of Later)"
  echo ""
  if [ $NONFREE_STATUS == "N" ]; then CenterTextHighlight "Status: ${ColourInfo}Free Software Only${ColourReset}"; else CenterTextHighlight "Status: ${ColourInfo}Using Non-Free Software${ColourReset}"; fi
  if [ $HAS_SYSTEM_DEPENDENCIES == "N" ]; then CenterTextStandout "${ColourStandout}Dependencies not found${ColourReset}"; elif [ $HAS_SYSTEM_DEPENDENCIES == "N" ]; then CenterTextStandout "${ColourStandout}System Dependencies not found${ColourReset}"; fi
  echo ""
  CenterTextHighlight "Examples of recommended usage & extra info available with: ${ColourInfo}--tips${ColourReset} argument"
  echo ""
  ##ENDENDEND
}

## Check for installed utilities
CheckCommands() {
  for NonfreeDependency in ${NONFREEDEPENDENCY_ARRAY[@]}; do
    ## Check if the user has nonfree software installed.
    if [[ -f "$WORKING_DIRECTORY/bin/$NonfreeDependency" ]]; then NONFREE_STATUS=Y; fi
  done
  for Dependency in ${DEPENDENCY_ARRAY[@]}; do
    ## Check if the user has free software installed.
    if [[ ! -f "$WORKING_DIRECTORY/bin/$Dependency" ]]; then HAS_DEPENDENCIES=N; fi
  done
  for Dependency in ${SYSTEM_DEPENDENCY_ARRAY[@]}; do
    ## Check if the user has system software installed.
    if command "$Dependency" &> /dev/null ; then HAS_SYSTEM_DEPENDENCIES=N; fi
  done
}

Center_Deps_Vertical() {
  AmountOfEchoes=`awk '/###DEPSDEPSDEPS/,/###ENDDEPSDEPSDEPS/' "${SCRIPT_PATH}" | grep -e 'echo' -e "CenterText" | wc -l`
  ## Compensate for the amount of system dependencies being tested in echoes.
  NondependencyExtraEchoes=$((${#NONFREEDEPENDENCY_ARRAY[@]} - 1))
  DependencyExtraEchoes=$((${#DEPENDENCY_ARRAY[@]} - 1))
  SystemDependencyExtraEchoes=$((${#SYSTEM_DEPENDENCY_ARRAY[@]} - 1))
  AmountOfEchoes=$((${AmountOfEchoes} + $NondependencyExtraEchoes + $SystemDependencyExtraEchoes + $DependencyExtraEchoes))
  ArgsHeight=$(((`tput lines` - $AmountOfEchoes) / 2))
  for ((x=0; x<=$ArgsHeight; x++)); do
    echo ""
  done
}

PrintDependencies() {
  Center_Deps_Vertical
  CenterTerminal=$((`tput cols` / 2))
  ###DEPSDEPSDEPS
  CenterTextHighlight "${ColourInfo}Free Dependencies${ColourReset}"
  for Dependency in ${DEPENDENCY_ARRAY[@]}; do
    ## Check if the user has free software installed.
    if [[ -f "$WORKING_DIRECTORY/bin/$Dependency" ]]; then echo "${ColourNameText}$(printf "%${CenterTerminal}s" "$Dependency ")${ColourReset}| Found"; else echo "${ColourNameText}$(printf "%${CenterTerminal}s" "$Dependency ")${ColourReset}| Not Found"; fi
  done
  echo ""
  CenterTextHighlight "${ColourInfo}Non-free Dependencies${ColourReset}"
  for NonfreeDependency in ${NONFREEDEPENDENCY_ARRAY[@]}; do
    ## Check if the user has nonfree software installed.
    if [[ -f "$WORKING_DIRECTORY/bin/$NonfreeDependency" ]]; then echo "${ColourNameText}$(printf "%${CenterTerminal}s" "$NonfreeDependency ")${ColourReset}| Found"; else echo "${ColourNameText}$(printf "%${CenterTerminal}s" "$NonfreeDependency ")${ColourReset}| Not Found"; fi
  done
  echo ""
  CenterTextHighlight "${ColourInfo}System Dependencies${ColourReset}"
  for Dependency in ${SYSTEM_DEPENDENCY_ARRAY[@]}; do
    ## Check if the user has system software installed.
    if ! command "$Dependency" &> /dev/null ; then echo "${ColourNameText}$(printf "%${CenterTerminal}s" "$Dependency ")${ColourReset}| Found"; else echo "${ColourNameText}$(printf "%${CenterTerminal}s" "$Dependency ")${ColourReset}| Not Found"; fi
  done
  read
  exit
  ###ENDDEPSDEPSDEPS
}

Center_Deps_Vertical() {
  AmountOfEchoes=`awk '/##TIPSTIPSTIPS/,/##ENDTIPSTIPSTIPS/' "${SCRIPT_PATH}" | grep -e 'echo' -e "CenterText" | wc -l`
  ## Compensate for the amount of system dependencies being tested in echoes.
  ArgsHeight=$(((`tput lines` - $AmountOfEchoes) / 2))
  for ((x=0; x<=$ArgsHeight; x++)); do
    echo ""
  done
}

PrintTips() {
  Center_Deps_Vertical ## Spaces to center message.
  ##TIPSTIPSTIPS
  echo ""
  CenterTextHighlight "${ColourInfo}Extra Help & Tips${ColourReset}"
  echo ""
  CenterTextHighlight "Use ${ColourInfo}--lossy-trans${ColourReset} for small items (e.g. App icons) for max compression at almost perfect visual transparency"
  CenterTextHighlight "Mode ${ColourInfo}--c4${ColourReset} is very time consuming for little and most of the time no actual return over 'Maximum', use only for testing"
  CenterTextHighlight "Mode ${ColourInfo}--c3${ColourReset} usually takes around 3-5 times as long as mode -c2 for limited but notable benefit, use for final optimisation"
  CenterTextHighlight "Mode ${ColourInfo}--lossy${ColourReset} is only recommended if your only aim is to save space, it's not visually transparent"
  CenterTextHighlight "If ${ColourInfo}--stallman${ColourReset} is enabled then the utility will not use PNGOut, Pingo or TruePNG"
  echo ""
  CenterTextHighlight "${ColourInfo}Pingo${ColourReset} (soon open source) is new and highly experimental, if Wine sends out an error message stating"
  CenterText "that Pingo crashes then try running this script with --pingofix(1/0) to (enable/disable) a workaround"
  echo ""
  CenterTextHighlight "${ColourInfo}>> By default the utility performs lossless compression <<${ColourReset}"
  ##ENDTIPSTIPSTIPS
  read
  exit
}

## Argument Handler ! IDK How people normally do it, so I'll do it my own way.
if [[ $# -eq 0 ]]; then
  CheckCommands
  Display_Help
  read
  exit
fi

for Argument in "$@"
do
  if [[ -d $Argument ]] || [[ -f $Argument ]]; then UserInput="$Argument"; fi
  if [[ $Argument == "--c"* ]]; then COMPRESSION_LEVEL=${Argument: -1}; fi
  if [[ $Argument == "--deps"* ]]; then PrintDependencies; fi
  if [[ $Argument == "--tips"* ]]; then PrintTips; fi
  if [[ $Argument == "--lossy" ]]; then LOSSY_MODE=2; fi
  if [[ $Argument == "--nostrip"* ]]; then STRIP_MODE=0; fi
  if [[ $Argument == "--noquant"* ]]; then QUANT_MODE=0; fi
  if [[ $Argument == "--jpeg-lossy" ]]; then JPEG_LOSSY_MODE=1; fi
  if [[ $Argument == "--pingofix1" ]]; then regedit "$WORKING_DIRECTORY/winescripts/DisableCrashDialog.REG"; elif [[ $Argument == "--pingofix0" ]]; then regedit "$WORKING_DIRECTORY/winescripts/EnableCrashDialog.REG"; fi
  if [[ $Argument == "--lossy-trans" ]]; then LOSSY_MODE=1; fi
  if [[ $Argument == "--stallman" ]]; then FREE_MODE=1; fi
  if [[ $Argument == "--WSL" ]]; then WINE=""; fi
done

IdentifyInput
exit
