#!/bin/zsh

#set -x

# Put your dev account information into these variables
# The email address of your developer account

dev_account="danil.korotenko@gmail.com"

# The team id
dev_team="QBPW9LPK8E"

dev_keychain_label="xcode-notarize"

dev_keychain_file="/Users/danilkorotenko/Library/Keychains/login.keychain-db"

typeset target_to_notorize="";         export target_to_notorize
typeset target_type="";                export target_type
typeset create_archive=0;              export create_archive

# functions requeststatus
# $1: requestUUID
function requeststatus()
{
    requestUUID=${1?:"need a request UUID"}
    req_status=$(xcrun notarytool info "$requestUUID" \
        --keychain ${dev_keychain_file} \
        --keychain-profile "${dev_keychain_label}" \
            | awk -F ': ' '/status:/ { print $2; }' )
    echo "$req_status"
}

function requestLog()
{
    requestUUID=${1?:"need a request UUID"}
    req_status=$(xcrun notarytool log "$requestUUID" \
        --keychain ${dev_keychain_file} \
        --keychain-profile "${dev_keychain_label}")
    echo "$req_status"
}

# function notarizefile
# $1: path to file to notarize, $2: identifier
function notarizefile()
{
    filepath=${1:?"need a filepath"}
    identifier=${2:?"need an identifier"}

    # upload file
    echo "## Uploading $filepath for notarization"
    notaryToolSubmitOutput=$(xcrun notarytool submit --keychain ${dev_keychain_file} --keychain-profile "${dev_keychain_label}" "${filepath}" 2>&1)
    echo "notarytool output:"
    echo $notaryToolSubmitOutput

    requestUUID=$(echo $notaryToolSubmitOutput \
                  | awk '/id:/ {a=$0} END{print a}' | awk '/id:/ { print $NF; }' )

    echo "Notarization RequestUUID: ${requestUUID}"

    if [[ ${requestUUID} == "" ]]; then
        echo "could not upload for notarization"
        exit 1
    fi

    # wait for status to be not "in progress" any more

    xcrun notarytool wait "$requestUUID" \
        --keychain ${dev_keychain_file} \
        --keychain-profile "${dev_keychain_label}"

    xcrun notarytool info "${requestUUID}" \
        --keychain ${dev_keychain_file} \
        --keychain-profile "${dev_keychain_label}"

    request_status=$(requeststatus "${requestUUID}")

    # print status information
    echo

    if [[ ${request_status} != "Accepted" ]]; then
        echo "## Could not notarize $filepath"
        echo "## Requesting notarize log"
        requestLog "${requestUUID}"
        exit 1
    fi
}

# function create_archive
# $1: path to target, $2: path to archive
function create_archive
{
    src_path=${1:?"need a src_path"}
    dst_path=${2:?"need an dst_path"}
    /usr/bin/ditto -c -k --keepParent ${src_path} ${dst_path}
}

# function staple_target
# $1: path to target
function staple_target
{
    src_path=${1:?"need a src_path"}
    # staple result
    echo "## Stapling ${src_path}"
    xcrun stapler staple "${src_path}"
}

function help 
{
    echo "Usage: ${1} [-h] [-i <path>] [-t <pkg|app>] [-a] [-c]"
    echo "  -h - this help screen"
    echo "  -i - input path"
    echo "  -t - target type [app]"
    echo "  -c - create zip archive"
    echo "  -b - brand name (short small)"
}

# Notarize target App
#
# Command line options processing
#
while getopts "haci:t:b:" opt; do
    case $opt in
        h)
            help ${0}; exit 0
            ;;
        i)
            target_to_notorize=$OPTARG
            ;;
        t)
            target_type=$OPTARG
            ;;
        c)
            create_archive=1
            ;;
        b)
            brand_name=$OPTARG
            ;;
        \?)
            help ${0}; exit 1
            ;;
    esac
done

if [[ ${target_to_notorize} == "" ]]; then
    echo "## Target was not specified."
    help ${0}; exit 1
fi

#
# Checking the target path
#
if [ ! -e ${target_to_notorize} ]
then
    echo "## Couldn't find ${target_to_notorize}. Please set correct path to target."
    help ${0}; exit 1
fi

echo "## Notarize target type:${target_type}, path:${target_to_notorize}"

local _target_to_notorize=${target_to_notorize}

if [[ "${target_type}" == "app" ]]; then
    echo "## Pack target to archive ${target_to_notorize}.zip"
    _target_to_notorize="${target_to_notorize}.zip"
    create_archive "${target_to_notorize}" "${target_to_notorize}.zip"
fi

identifier="com.danilkorotenko.EpubZip"
notarizefile "${_target_to_notorize}" "${identifier}"

if [[ "${target_type}" == "app" ]]; then
    echo "## Removing archive ${target_to_notorize}.zip"
    rm -f "${target_to_notorize}.zip"
fi

# Staple result
echo "## Stapling ${target_to_notorize}"
xcrun stapler staple "${target_to_notorize}"

# Create result archive
if [[ create_archive -eq 1 ]]; then
    echo "## Pack result to archive ${target_to_notorize}.zip"
    create_archive "${target_to_notorize}" "${target_to_notorize}.zip"
fi

echo '## Done!'

exit 0
