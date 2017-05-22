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

##ROOTMODE
if [[ $EUID -ne 0 ]]; then
  if [[ ! -d "/opt/mozjpeg" ]]; then
    clear
    echo "You do not have mozjpeg installed which is a dependency of one of the utilities (jpeg-recompress)."
    echo "Root will be required to make install mozjpeg, you will get a prompt asking for the root password after compilation."
    echo "This is just to let you know :), operation will resume in 15 seconds."
    sleep 15s
  fi
fi

## Declare the Working Variables
WORKING_DIRECTORY="${PWD}"
CPU_CORES="$((`nproc`+1))"
SCRIPT_PATH="$0"
HAS_DEPENDENCIES=Y
clear

## Updater Configuration
declare -a DEPENDENCY_ARRAY=("tput" "wget" "git" "gcc" "nasm" "boost");
declare -a NONFREE_SOFTWARE_TARGETS=("$WORKING_DIRECTORY/bin/TruePNG.exe" "$WORKING_DIRECTORY/bin/pngout");
ENABLE_NONFREE=N
UPDATE=N

## Shell In-Replacement Colours For Text - Sewer Palette
ColourReset=`tput sgr0`
ColourStandout=`tput smso`
ColourNameText=`tput setaf 3`
ColourBold=`tput bold`
ColourWarning=`tput setaf 15`
ColourInfo=`tput setaf 10`

## For center spacing consider expansion of tput, Reset + Warning = 22 chars / 2 = 11 spaces offset

## Shell In-Replacement for All Text Colours!
AllColourReset="tput sgr0"
AllColourBold="tput bold"
AllColourWarning="tput setaf 15"
AllColourInfo="tput setaf 10"

## Misc
ISSUESSTRING="If you have any issues then you may likely be missing one of these dependencies..."

BuildZopfliPNG() {
  echo "${ColourWarning}Building zopflipng-git${ColourReset}"
  echo "==> Cloning zopflipng"
  if [[ ! -d "$WORKING_DIRECTORY/Sources/ZopfliPNG/" ]]; then
    mkdir -p "$WORKING_DIRECTORY/Sources/ZopfliPNG/" 
    git clone -q https://github.com/google/zopfli.git "$WORKING_DIRECTORY/Sources/ZopfliPNG/"
  fi
  cd "$WORKING_DIRECTORY/Sources/ZopfliPNG/"
  echo "==> Compiling zopflipng"
  make -j$CPU_CORES zopflipng 
  echo "==> Moving binary"
  mv "$WORKING_DIRECTORY/Sources/ZopfliPNG/zopflipng" "$WORKING_DIRECTORY/bin/"
  echo "==> Cleaning up"
  make -j$CPU_CORES clean 
}

CheckZopfliPNG() {
  if [[ -d "$WORKING_DIRECTORY/Sources/ZopfliPNG/" ]]; then
    UpdateZopfliPNG
  elif [[ ! -f "$WORKING_DIRECTORY/bin/zopflipng" ]]; then
    BuildZopfliPNG
  else
    BuildZopfliPNG
  fi
  cd "$WORKING_DIRECTORY"
}

UpdateZopfliPNG() {
  echo "${ColourWarning}Checking for ZopfliPNG update (git)${ColourReset}"
  cd "$WORKING_DIRECTORY/Sources/ZopfliPNG/"

  echo "==> Fetching from origin"
  git fetch origin

  echo "==> Looking for new commits via the git log"
  reslog=$(git log HEAD..origin/master --oneline)
  if [[ "${reslog}" != "" ]] ; then
    echo "==> Merging"
    git merge origin/master
    echo "==> Building"
    make -j$CPU_CORES zopflipng 
    echo "==> Moving binary"
    mv "$WORKING_DIRECTORY/Sources/ZopfliPNG/zopflipng" "$WORKING_DIRECTORY/bin/"
    echo "==> Making clean"
    make -j$CPU_CORES clean 
  else
    echo "==> No changes, not updating"
    if [ ! -f "$WORKING_DIRECTORY/bin/zopflipng" ]; then
      echo "==> ${ColourInfo}Sources present but no binary, recompiling."
      BuildZopfliPNG
    fi
  fi
  cd "$WORKING_DIRECTORY"
}

BuildECT() {
  echo "${ColourWarning}Building ect-git${ColourReset}"
  echo "==> Cloning ect"
  if [[ ! -d "$WORKING_DIRECTORY/Sources/ect/" ]]; then
    mkdir -p "$WORKING_DIRECTORY/Sources/ect/" 
    git clone -q https://github.com/fhanau/Efficient-Compression-Tool.git "$WORKING_DIRECTORY/Sources/ect/"
  fi
  cd "$WORKING_DIRECTORY/Sources/ect/src/"
  echo "==> Compiling ect (non-multithreaded compilation)"
  make 
  echo "==> Moving binary"
  mv "$WORKING_DIRECTORY/Sources/ect/ECT" "$WORKING_DIRECTORY/bin/ect"
  echo "==> Cleaning up"
  make -j$CPU_CORES clean 
}

CheckECT() {
  if [[ -d "$WORKING_DIRECTORY/Sources/ect/" ]]; then
    UpdateECT
  elif [[ ! -f "$WORKING_DIRECTORY/bin/ect" ]]; then
    BuildECT
  else
    BuildECT
  fi
  cd "$WORKING_DIRECTORY"
}

UpdateECT() {
  echo "${ColourWarning}Checking for ect update (git)${ColourReset}"
  cd "$WORKING_DIRECTORY/Sources/ect/"

  echo "==> Fetching from origin"
  git fetch origin

  echo "==> Looking for new commits via the git log"
  reslog=$(git log HEAD..origin/master --oneline)
  if [[ "${reslog}" != "" ]] ; then
    echo "==> Merging"
    git merge origin/master
    cd "$WORKING_DIRECTORY/Sources/ect/src/"
    echo "==> Building"
    make -j$CPU_CORES 
    echo "==> Moving binary"
    mv "$WORKING_DIRECTORY/Sources/ect/src/ect" "$WORKING_DIRECTORY/bin/"
    echo "==> Making clean"
    make -j$CPU_CORES clean 
  else
    echo "==> No changes, not updating"
    if [ ! -f "$WORKING_DIRECTORY/bin/ect" ]; then
      echo "==> ${ColourInfo}Sources present but no binary, recompiling."
      BuildECT
    fi
  fi
  cd "$WORKING_DIRECTORY"
}

FetchPNGCrush() {
  echo "${ColourWarning}Fetching PNGCrush (sf)${ColourReset}"
  mkdir -p "$WORKING_DIRECTORY/Sources/PNGCrush" 
  cd "$WORKING_DIRECTORY/Sources/PNGCrush"

  ##Note: At the time of writing this was actually not the 'latest' source, but has been marked so by the author.
  echo "==> Downloading latest source"
  if [ -f "PNGCrush.7z" ]; then
    echo "==> PNGCrush previously downloaded"
    wget --content-disposition -O PNGCrush.7z.1 "https://sourceforge.net/projects/pmt/files/latest/download?source=files" 
    MD5Orig="$(md5sum "PNGCrush.7z" | cut -d ' ' -f 1)"
    MD5New="$(md5sum "PNGCrush.7z.1" | cut -d ' ' -f 1)"
    if [ ! $MD5Orig == $MD5New ]; then
      echo "==> MD5 of both ZIPs do not match, recompiling!"
      rm -rf "PNGCrush.7z"
      mv "PNGCrush.7z.1" "PNGCrush.7z"
      BuildPNGCrush
    else
      echo "==> MD5 of both ZIPs match, no update is needed"
      rm -rf "PNGCrush.7z.1"
      if [ ! -f "$WORKING_DIRECTORY/bin/pngcrush" ]; then
        echo "==> ${ColourInfo}Sources present but no binary, recompiling."
        BuildPNGCrush
      fi
      return
    fi
  else
    wget --content-disposition -O PNGCrush.7z "https://sourceforge.net/projects/pmt/files/latest/download?source=files" 
    BuildPNGCrush
  fi

  cd "$WORKING_DIRECTORY"
}

BuildPNGCrush(){
  echo "${ColourWarning}Building PNGCrush (sf)${ColourReset}"
  cd "$WORKING_DIRECTORY/Sources/PNGCrush"

  echo "==> Decompressing Sources"
  7z e "PNGCrush.7z" 
  cd pngcrush*
  echo "==> Compiling PNGCrush"
  make -j$CPU_CORES pngcrush 
  echo "==> Moving binary"
  mv "pngcrush" "$WORKING_DIRECTORY/bin/"
  rm -rf $PWD 

  cd "$WORKING_DIRECTORY"
}

BuildADVComp() {
  echo "${ColourWarning}Building advcomp-git${ColourReset}"
  echo "==> Cloning advcomp"
  if [[ ! -d "$WORKING_DIRECTORY/Sources/advcomp/" ]]; then
    mkdir -p "$WORKING_DIRECTORY/Sources/advcomp/" 
    git clone -q https://github.com/amadvance/advancecomp.git "$WORKING_DIRECTORY/Sources/advcomp/"
  fi
  cd "$WORKING_DIRECTORY/Sources/advcomp/"
  echo "==> Configuring advcomp"
  ./autogen.sh 
  ## This repetition of autogen is actually intended, for some reason autogen in this project creates files needed by autogen itself, whoops...
  ./autogen.sh 
  ./configure 
  echo "==> Compiling advcomp"
  make -j$CPU_CORES 
  echo "==> Moving binaries"
  mv "$WORKING_DIRECTORY/Sources/advcomp/advdef" "$WORKING_DIRECTORY/bin/"
  mv "$WORKING_DIRECTORY/Sources/advcomp/advpng" "$WORKING_DIRECTORY/bin/"
  echo "==> Cleaning up"
  make -j$CPU_CORES clean 
}

CheckADVComp() {
  if [[ -d "$WORKING_DIRECTORY/Sources/advcomp/" ]]; then
    UpdateADVComp
  ## Not interested in advpng. It is a bonus.
  elif [[ ! -f "$WORKING_DIRECTORY/bin/advdef" ]]; then
    BuildADVComp
  else
    BuildADVComp
  fi
  cd "$WORKING_DIRECTORY"
}

UpdateADVComp() {
  echo "${ColourWarning}Checking for advcomp update (git)${ColourReset}"
  cd "$WORKING_DIRECTORY/Sources/advcomp/"

  echo "==> Fetching from origin"
  git fetch origin

  echo "==> Looking for new commits via the git log"
  reslog=$(git log HEAD..origin/master --oneline)
  if [[ "${reslog}" != "" ]] ; then
    echo "==> Merging"
    git merge origin/master
    echo "==> Building"
    make -j$CPU_CORES zopflipng 
    echo "==> Moving binaries"
    mv "$WORKING_DIRECTORY/Sources/advcomp/advdef" "$WORKING_DIRECTORY/bin/"
    mv "$WORKING_DIRECTORY/Sources/advcomp/advpng" "$WORKING_DIRECTORY/bin/"
    echo "==> Making clean"
    make -j$CPU_CORES clean 
  else
    echo "==> No changes, not updating"
    ## Not interested in advpng. It is a bonus to keep it.
    if [ ! -f "$WORKING_DIRECTORY/bin/advdef" ]; then
      echo "==> ${ColourInfo}Sources present but no binary, recompiling."
      BuildADVComp
    fi
  fi
  cd "$WORKING_DIRECTORY"
}


FetchOptiPNG() {
  echo "${ColourWarning}Fetching OptiPNG (sf)${ColourReset}"
  mkdir -p "$WORKING_DIRECTORY/Sources/OptiPNG" 
  cd "$WORKING_DIRECTORY/Sources/OptiPNG"

  ##Note: At the time of writing this was actually not the 'latest' source, but has been marked so by the author.
  echo "==> Downloading latest source"
  if [ -f "OptiPNG.tar.xz" ]; then
    echo "==> OptiPNG previously downloaded"
    wget --content-disposition -O OptiPNG.tar.xz.1 "https://sourceforge.net/projects/optipng/files/OptiPNG/optipng-0.7.6/optipng-0.7.6.tar.gz/download" 
    MD5Orig="$(md5sum "OptiPNG.tar.xz" | cut -d ' ' -f 1)"
    MD5New="$(md5sum "OptiPNG.tar.xz.1" | cut -d ' ' -f 1)"
    if [ ! $MD5Orig == $MD5New ]; then
      echo "==> MD5 of both ZIPs do not match, recompiling!"
      rm -rf "OptiPNG.tar.xz"
      mv "OptiPNG.tar.xz.1" "OptiPNG.tar.xz"
      BuildOptiPNG
    else
      echo "==> MD5 of both ZIPs match, no update is needed"
      rm -rf "OptiPNG.tar.xz.1"
      if [ ! -f "$WORKING_DIRECTORY/bin/optipng" ]; then
        echo "==> ${ColourInfo}Sources present but no binary, recompiling."
        BuildOptiPNG
      fi
      return
    fi
  else
    wget --content-disposition -O OptiPNG.tar.xz "https://sourceforge.net/projects/optipng/files/OptiPNG/optipng-0.7.6/optipng-0.7.6.tar.gz/download" 
    BuildOptiPNG
  fi

  cd "$WORKING_DIRECTORY"
}

BuildOptiPNG(){
  echo "${ColourWarning}Building OptiPNG${ColourReset}"
  cd "$WORKING_DIRECTORY/Sources/OptiPNG"
  echo "==> Decompressing sources"
  tar xf "OptiPNG.tar.xz" 
  cd optipng*
  echo "==> Compiling OptiPNG"
  ./configure 
  make -j$CPU_CORES 
  echo "==> Moving binary"
  mv "src/optipng/optipng" "$WORKING_DIRECTORY/bin/"
  rm -rf $PWD 

  cd "$WORKING_DIRECTORY"
}

GetPNGOut(){
  echo "${ColourWarning}Obtaining PNGOut${ColourReset}"
  if [ -f "$WORKING_DIRECTORY/bin/pngout" ]; then
    echo "==> PNGOut previously downloaded, no need to redownload"
    echo "${ColourInfo}No static link exists for latest build, if it is outdated consider updating manually and sending a pull request${ColourReset}"
    return
  fi
  mkdir -p "$WORKING_DIRECTORY/tmp/" 
  cd "$WORKING_DIRECTORY/tmp/"

  ## No static link exists for latest build, must be updated manually.
  echo "==> Downloading latest binary"
  wget -O pngout.tar.gz "http://static.jonof.id.au/dl/kenutils/pngout-20150319-linux-static.tar.gz" 
  tar xf "pngout.tar.gz" 
  mv "pngout"*"/x86_64/pngout-static" "$WORKING_DIRECTORY/bin/pngout"
  rm -rf "$WORKING_DIRECTORY/tmp/"
  cd "$WORKING_DIRECTORY"
}

GetTruePNG(){
  echo "${ColourWarning}Obtaining TruePNG${ColourReset}"
  if [ -f "$WORKING_DIRECTORY/bin/TruePNG.exe" ]; then
    echo "==> TruePNG previously downloaded, no need to redownload"
    echo "${ColourInfo}No static link exists for latest build, if it is outdated consider updating manually and sending a pull request${ColourReset}"
    return
  fi
  mkdir -p "$WORKING_DIRECTORY/tmp/" 
  cd "$WORKING_DIRECTORY/tmp/"

  ## No static link exists for latest build, must be updated manually.
  echo "==> Downloading latest binary"
  wget -O truepng.zip "http://x128.ho.ua/clicks/clicks.php?uri=TruePNG_0622.zip" 
  unzip truepng.zip 
  mv "TruePNG.exe" "$WORKING_DIRECTORY/bin/"
  rm -rf "$WORKING_DIRECTORY/tmp/"
  cd "$WORKING_DIRECTORY"
}

GetPingo(){
  echo "${ColourWarning}Obtaining Pingo${ColourReset}"
  mkdir -p "$WORKING_DIRECTORY/Sources/Pingo/" 
  cd "$WORKING_DIRECTORY/Sources/Pingo/"
  ## No static link exists for latest build, must be updated manually.
  if [ -f "$WORKING_DIRECTORY/bin/pingo.exe" ]; then
    echo "==> Pingo previously downloaded"
    wget -O pingo.zip.1 "https://css-ig.net/downloads/pingo.zip" 
    MD5Orig="$(md5sum "pingo.zip" | cut -d ' ' -f 1)"
    MD5New="$(md5sum "pingo.zip.1" | cut -d ' ' -f 1)"
    if [ ! $MD5Orig == $MD5New ]; then
      echo "==> MD5 of both ZIPs do not match, replacing with new version!"
      rm -rf "pingo.zip"
      mv "pingo.zip.1" "pingo.zip"
    else
      echo "==> MD5 of both ZIPs match, no update is needed"
      rm -rf "pingo.zip.1"
      return
    fi
    return
  else
    echo "==> Downloading latest binary"
    wget -O pingo.zip "https://css-ig.net/downloads/pingo.zip" 
    unzip pingo.zip 
    mv "pingo.exe" "$WORKING_DIRECTORY/bin/"
    cd "$WORKING_DIRECTORY"
  fi
}

BuildPNGQuant() {
  echo "${ColourWarning}Building pngquant-git${ColourReset}"
  echo "==> Cloning pngquant"
  if [[ ! -d "$WORKING_DIRECTORY/Sources/pngquant/" ]]; then
    mkdir -p "$WORKING_DIRECTORY/Sources/pngquant/" 
    git clone -q https://github.com/pornel/pngquant.git "$WORKING_DIRECTORY/Sources/pngquant/"
  fi
  cd "$WORKING_DIRECTORY/Sources/pngquant/"
  echo "==> Compiling pngquant"
  make -j$CPU_CORES 
  echo "==> Moving binary"
  mv "$WORKING_DIRECTORY/Sources/pngquant/pngquant" "$WORKING_DIRECTORY/bin/"
  echo "==> Cleaning up"
  make -j$CPU_CORES clean 
}

CheckPNGQuant() {
  if [[ -d "$WORKING_DIRECTORY/Sources/pngquant/" ]]; then
    UpdatePNGQuant
  elif [[ ! -f "$WORKING_DIRECTORY/bin/pngquant" ]]; then
    BuildPNGQuant
  else
    BuildPNGQuant
  fi
  cd "$WORKING_DIRECTORY"
}

UpdatePNGQuant() {
  echo "${ColourWarning}Checking for pngquant update (git)${ColourReset}"
  cd "$WORKING_DIRECTORY/Sources/pngquant/"

  echo "==> Fetching from origin"
  git fetch origin

  echo "==> Looking for new commits via the git log"
  reslog=$(git log HEAD..origin/master --oneline)
  if [[ "${reslog}" != "" ]] ; then
    echo "==> Merging"
    git merge origin/master
    echo "==> Building"
    make -j$CPU_CORES 
    echo "==> Moving binary"
    mv "$WORKING_DIRECTORY/Sources/pngquant/pngquant" "$WORKING_DIRECTORY/bin/"
    echo "==> Making clean"
    make -j$CPU_CORES clean 
  else
    echo "==> No changes, not updating"
    if [ ! -f "$WORKING_DIRECTORY/bin/pngquant" ]; then
      echo "==> ${ColourInfo}Sources present but no binary, recompiling."
      BuildPNGQuant
    fi
  fi
  cd "$WORKING_DIRECTORY"
}

FetchJPEGTran() {
  echo "${ColourWarning}Fetching JPEGTran${ColourReset}"
  mkdir -p "$WORKING_DIRECTORY/Sources/JPEGTran" 
  cd "$WORKING_DIRECTORY/Sources/JPEGTran"

  ##Note: At the time of writing this was actually not the 'latest' source, but has been marked so by the author.
  echo "==> Downloading source from nonstatic link"
  wget --content-disposition -O JPEGTran.tar.gz "http://www.infai.org/jpeg/files?get=jpegsrc.v9b.tar.gz" 
  tar xf "JPEGTran.tar.gz" 
  cd jpeg*/
  echo "==> Configuring"
  autoreconf 
  ./configure 
  echo "==> Building"
  make -j$CPU_CORES 
  echo "==> Moving binary"
  mv "jpegtran" "$WORKING_DIRECTORY/bin/"
  echo "==> Making clean"
  make -j$CPU_CORES clean 
  cd "$WORKING_DIRECTORY"
}

BuildJPEGOptim() {
  echo "${ColourWarning}Building jpegoptim-git${ColourReset}"
  echo "==> Cloning jpegoptim"
  if [[ ! -d "$WORKING_DIRECTORY/Sources/jpegoptim/" ]]; then
    mkdir -p "$WORKING_DIRECTORY/Sources/jpegoptim/" 
    git clone -q https://github.com/tjko/jpegoptim.git "$WORKING_DIRECTORY/Sources/jpegoptim/"
  fi
  cd "$WORKING_DIRECTORY/Sources/jpegoptim/"
  echo "==> Configuring jpegoptim"
  ./configure 
  echo "==> Compiling jpegoptim"
  make -j$CPU_CORES 
  echo "==> Moving binary"
  mv "$WORKING_DIRECTORY/Sources/jpegoptim/jpegoptim" "$WORKING_DIRECTORY/bin/"
  echo "==> Cleaning up"
  make -j$CPU_CORES clean 
}

CheckJPEGOptim() {
  if [[ -d "$WORKING_DIRECTORY/Sources/jpegoptim/" ]]; then
    UpdateJPEGOptim
  elif [[ ! -f "$WORKING_DIRECTORY/bin/jpegoptim" ]]; then
    BuildJPEGOptim
  else
    BuildJPEGOptim
  fi
  cd "$WORKING_DIRECTORY"
}

UpdateJPEGOptim() {
  echo "${ColourWarning}Checking for jpegoptim update (git)${ColourReset}"
  cd "$WORKING_DIRECTORY/Sources/jpegoptim/"

  echo "==> Fetching from origin"
  git fetch origin

  echo "==> Looking for new commits via the git log"
  reslog=$(git log HEAD..origin/master --oneline)
  if [[ "${reslog}" != "" ]] ; then
    echo "==> Merging"
    git merge origin/master
    echo "==> Building"
    make -j$CPU_CORES 
    echo "==> Moving binary"
    mv "$WORKING_DIRECTORY/Sources/jpegoptim/jpegoptim" "$WORKING_DIRECTORY/bin/"
    echo "==> Making clean"
    make -j$CPU_CORES clean 
  else
    echo "==> No changes, not updating"
    if [ ! -f "$WORKING_DIRECTORY/bin/jpegoptim" ]; then
      echo "==> ${ColourInfo}Sources present but no binary, recompiling."
      BuildJPEGOptim
    fi
  fi
  cd "$WORKING_DIRECTORY"
}

BuildJPEGRecompress() {
  echo "${ColourWarning}Building jpegarchive${ColourReset}"
  echo "==> Cloning jpeg-archive"
  if [[ ! -d "$WORKING_DIRECTORY/Sources/jpegarchive/" ]]; then
    mkdir -p "$WORKING_DIRECTORY/Sources/jpegarchive/" 
    git clone -q https://github.com/danielgtaylor/jpeg-archive.git "$WORKING_DIRECTORY/Sources/jpegarchive/"
  fi
  cd "$WORKING_DIRECTORY/Sources/jpegarchive/"
  if [[ ! -d "/opt/mozjpeg" ]]; then
    echo "==> Cloning mozjpeg dependency"
    git clone https://github.com/mozilla/mozjpeg.git "mozjpeg"
    cd "mozjpeg"
    autoreconf --force --install 
    ./configure --with-jpeg8 
    make 
    echo "==> Installing mozjpeg as a (dependency of JPEGrecompress)"
    sudo make install 
  fi
  echo "==> Compiling jpegarchive"
  make -j$CPU_CORES 
  echo "==> Moving binary"
  mv "$WORKING_DIRECTORY/Sources/jpegarchive/jpeg-recompress" "$WORKING_DIRECTORY/bin/jpegrecompress"
  echo "==> Cleaning up"
  make -j$CPU_CORES clean 
}

CheckJPEGRecompress() {
  if [[ -d "$WORKING_DIRECTORY/Sources/jpegarchive/" ]]; then
    UpdateJPEGRecompress
  elif [[ ! -f "$WORKING_DIRECTORY/bin/jpegrecompress" ]]; then
    BuildJPEGRecompress
  else
    BuildJPEGRecompress
  fi
  cd "$WORKING_DIRECTORY"
}

UpdateJPEGRecompress() {
  echo "${ColourWarning}Checking for jpegarchive update (git)${ColourReset}"
  cd "$WORKING_DIRECTORY/Sources/jpegarchive/"

  echo "==> Fetching from origin"
  git fetch origin

  echo "==> Looking for new commits via the git log"
  reslog=$(git log HEAD..origin/master --oneline)
  if [[ "${reslog}" != "" ]] ; then
    echo "==> Merging"
    git merge origin/master
    echo "==> Building"
    make -j$CPU_CORES 
    echo "==> Moving binary"
    mv "$WORKING_DIRECTORY/Sources/jpegarchive/jpegrecompress" "$WORKING_DIRECTORY/bin/"
    echo "==> Making clean"
    make -j$CPU_CORES clean 
  else
    echo "==> No changes, not updating"
    if [ ! -f "$WORKING_DIRECTORY/bin/jpegarchive" ]; then
      echo "==> ${ColourInfo}Sources present but no binary, recompiling."
      BuildJPEGRecompress
    fi
  fi
  cd "$WORKING_DIRECTORY"
}

Center_Help_Vertical() {
  if [[ $HAS_DEPENDENCIES == N ]]; then
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

## NOTE: ARGUMENTS ARE ALIGNED TO THE ISSUES LINE, IF LINE CHANGES PLEASE REALIGN ARGUMENTS.
## START and END ARE JUST FOR MY AWKING PLEASURE, DO NOT BE OFFENDED :P
Display_Help() {
  ##STARTSTARTSTART
  Center_Help_Vertical
  Center_Help_Horizontal
  echo ""
  CenterTextHighlight "${ColourInfo}XOS Image Compressor v0.69${ColourReset}"
  echo ""
  CenterTextHighlight "To run the updater simply specify the ${ColourInfo}--update${ColourReset} argument"
  echo ""
  CenterText "$ISSUESSTRING"
  CenterTextHighlight "Dependencies: ${ColourInfo}tput, wget, git, gcc, nasm, boost${ColourReset}"
  echo ""
  ## The first printf offsets the text to begin at the same point as the 'if you have any issues' text
  echo "$(printf "%$(($ArgsSpacing))s" "")${ColourInfo}$(printf "%16s" "--update") ${ColourReset}| Run the updater"
  echo "$(printf "%$(($ArgsSpacing))s" "")${ColourInfo}$(printf "%16s" "--cleanup") ${ColourReset}| Remove the software sources folder to free up space"
  echo "$(printf "%$(($ArgsSpacing))s" "")${ColourInfo}$(printf "%16s" "--enable-nonfree") ${ColourReset}| Enables non free (as in Stallman) packages. (PNGOut & TruePNG)"
  echo "$(printf "%$(($ArgsSpacing))s" "")${ColourInfo}$(printf "%16s" "--remove-nonfree") ${ColourReset}| Removes non free (as in Stallman) packages. (PNGOut & TruePNG)"
  echo ""
  if [ $HAS_DEPENDENCIES == "N" ]; then CenterTextStandout "${ColourStandout}Dependencies not found${ColourReset}"; fi
  ##ENDENDEND
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

## Check for installed dependencies
CheckCommands() {
  for Dependency in ${DEPENDENCY_ARRAY[@]}; do
    ## True if command does not exist. Looks for exit code non-zero.
    if command "$Dependency"  ; then HAS_DEPENDENCIES=N; fi
  done
}

## Argument Handler ! IDK How people normally do it, so I'll do it my own way.
if [[ $# -eq 0 ]]; then
  CheckCommands
  Display_Help;
  read
  exit
fi

for Argument in "$@"
do
  if [[ $Argument == "--enable-nonfree" ]]; then ENABLE_NONFREE=Y; fi
  if [[ $Argument == "--remove-nonfree" ]]; then for Nonfree in $NONFREE_SOFTWARE_TARGETS; do rm -rf $Nonfree; done fi
  if [[ $Argument == "--update" ]]; then UPDATE=Y; fi
  if [[ $Argument == "--cleanup" ]]; then rm -rf "$WORKING_DIRECTORY/Sources/"; fi
  if [[ $Argument == "--help" ]]; then Display_Help; read; exit; fi
  if [[ $Argument == "--h" ]]; then Display_Help; read; exit; fi
  if [[ $Argument == "-help" ]]; then Display_Help; read; exit; fi
done

if [[ $UPDATE == Y ]]; then
  ## Create the initial directories on update operation. (Safe - mkdir doesn't override, faster than checking)
  mkdir -p "$WORKING_DIRECTORY/Sources/" 
  mkdir -p "$WORKING_DIRECTORY/bin/" 

  if [[ $ENABLE_NONFREE == Y ]]; then GetPNGOut; GetTruePNG; GetPingo; fi
  CheckZopfliPNG
  CheckECT
  CheckADVComp
  CheckJPEGRecompress
  CheckPNGQuant
  FetchPNGCrush
  #FetchJPEGTran ## Disabled, use it if you want, it's staying here for any adventurer intending to use this in the future.
  CheckJPEGOptim
  FetchOptiPNG
fi
exit
