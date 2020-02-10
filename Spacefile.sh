#
# Copyright 2017 Blockie AB
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


# Disable warning about local keyword
# shellcheck disable=SC2039

#============
# STRING_TRIM
#
# Trim whitespace (spaces and tabs) from a string left and right in place.
#
# Parameters:
#   $1: the name of the variable to trim.
#
# Returns:
#   non-zero if string error
#
#============
STRING_TRIM()
{
    SPACE_SIGNATURE="varname"

    # shellcheck disable=SC2034
    local __sopriv=
    eval "__sopriv=\"\${${1}}\""
    # shellcheck disable=SC2034
    local __tab="	"
    while true; do
        eval "${1}=\"\${$1#\"\${$1%%[! ]*}\"}\""
        eval "${1}=\"\${$1%\"\${$1##*[! ]}\"}\""
        eval "${1}=\"\${$1#\"\${$1%%[!\$__tab]*}\"}\""
        eval "${1}=\"\${$1%\"\${$1##*[!\$__tab]}\"}\""
        if eval "[ \"\${${1}}\" = \"\${__sopriv}\" ]"; then
            break
        fi
        eval "__sopriv=\"\${${1}}\""
    done
}


# Disable warning about local keyword
# shellcheck disable=SC2039

#=============
# STRING_SUBST
#
# Substitute text in place.
#
# Parameters:
#   $1: variable name to substitute in.
#   $2: text to substitute away.
#   $3: text to insert in place.
#   $4: global, set to "1" to substitute all occurrences.
#
#=============
STRING_SUBST()
{
    SPACE_SIGNATURE="varname match replace [global]"

    local __varname="${1}"
    local __rstring=
    eval "__rstring=\"\${$1}\""
    shift

    local __subst="${1}"
    shift

    local __replace="${1}"
    shift

    local __global="${1:-0}"
    shift $(( $# > 0 ? 1 : 0 ))

    local __lstring=
    local __string=""
    while true; do
        __lstring="${__rstring%%${__subst}*}"
        if [ "${__lstring}" = "${__rstring}" ]; then
            __string="${__string}${__rstring}"
            break
        fi
        __string="${__string}${__lstring}${__replace}"
        __rstring="${__rstring#*${__subst}}"
        if [ "${__global}" -ne 1 ]; then
            __string="${__string}${__rstring}"
            break
        fi
    done
    eval "${__varname}=\"\${__string}\""
}

# Disable warning about local keyword
# shellcheck disable=SC2039

#=============
# STRING_INDEXOF
#
# Find the first index of sub string in string.
#
# Parameters:
#   $1: sub string to search for.
#   $2: string to search in.
#   $3: optional variable name to store index value to. -1 when sub string not found.
#
# Returns:
#   0: if sub string found, 1 otherwise.
#
#=============
STRING_INDEXOF()
{
    SPACE_SIGNATURE="substring string [outvarname]"

    local substr="${1}"
    shift

    local string="${1}"
    shift

    local varname="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    local rest="${string%%${substr}*}"

    if [ "${rest}" = "${string}" ]; then
        if [ -n "${varname}" ]; then
            eval "${varname}=\"-1\""
        fi
        return 1
    fi

    if [ -n "${varname}" ]; then
        eval "${varname}=\"${#rest}\""
    fi
    return 0
}


# Disable warning about local keyword usage
# shellcheck disable=SC2039

#=============
# STRING_ESCAPE
#
# Escape in place up the occurrences of quotes, dollar signs, parenthesis, etc.
#
# It is optional which of ", $, (, ), <, >, |, &, / to escape.
#
# Parameters:
#   $1: Name of the variable to escape up, in place.
#   $2: Optional which characters to escape, defaults to '"$'.
#
#=============
STRING_ESCAPE()
{
    SPACE_SIGNATURE="varname [escapes]"
    # shellcheck disable=SC2034
    SPACE_DEP="_STRING_ESCAPE"

    local ___char=
    for ___char in \" \$ \( \) \< \> \| \& \/; do
        case "${2-\"\$}" in
            *${___char}*)
                _STRING_ESCAPE "${1}" "${___char}"
                ;;
        esac
    done
}


# Disable warning about local keyword
# shellcheck disable=2039

#===============
# _STRING_ESCAPE
#
# Helper function.
#
# Parameters:
#   $1: name of variable to escape
#   $2: character to escape.
#
#===============
_STRING_ESCAPE()
{
    local __right=
    local __result=""
    eval "__right=\$${1}"
    local __left=
    while true; do
        # Cut from right up until last occurrence of char.
        __left="${__right%%${2}*}"
        if [ "${__left}" = "${__right}" ]; then
            # Done
            __result="${__result}${__left}"
            break
        fi
        __right="${__right#$__left}"
        # This seems to be necessary the remove the escapes properly.
        __right="${__right#*${2}}"
        # Now cut away from right all escapes, one by one..
        local __escapes=""
        local __left2=
        while true; do
            __left2="${__left%[\\]}"
            if [ "${__left2}" = "${__left}" ]; then
                # No more escapes
                break
            fi
            # Escape encountered
            __escapes="${__escapes}\\"
            __left="${__left2}"
        done
        # Double the number of escapes and add one.
        __result="${__result}${__left}${__escapes}${__escapes}\\${2}"
    done
    eval "${1}=\${__result}"
}


# Disable warning about local keyword
# shellcheck disable=2039

#==================
# STRING_ITEM_COUNT
#
# Count all items in a string, split on current IFS.
#
# Parameters:
#   $1: string to count items in.
#   $2: variable name to store count in
#
#==================
STRING_ITEM_COUNT()
{
    SPACE_SIGNATURE="string outvarname"

    local __s="${1}"
    shift

    local __outvar="${1}"
    shift

    local __item=
    local __count=0
    for __item in ${__s}; do
        __count=$((__count+1))
    done
    eval "${__outvar}=\"\${__count}\""
}


# Disable warning about local keyword
# shellcheck disable=2039

#================
# STRING_ITEM_GET
#
# Get an item in a string by it's index,
# where string is split on the current IFS.
#
# Parameters:
#   $1: string to get item from.
#   $2: index of item to get.
#   $3: variable name to store item to.
#
#================
STRING_ITEM_GET()
{
    # shellcheck disable=2034
    SPACE_SIGNATURE="string itemindex outvarname"

    local __s="${1}"
    shift

    local __index="${1}"
    shift

    local __outvar="${1}"
    shift

    local __item=
    local __count=0
    for __item in ${__s}; do
        if [ "${__count}" -eq "${__index}" ]; then
            eval "${__outvar}=\"\${__item}\""
            break
        fi
        __count=$((__count+1))
    done
}


# Disable warning about local keyword usage
# shellcheck disable=SC2039

#====================
# STRING_ITEM_INDEXOF
#
# Find the first index of item in string.
# Items are split on current IFS.
#
# Parameters:
#   $1: string to lookup item in.
#   $2: string of item to find.
#   $3: variable name to store item index in, -1 when not found (optional).
#
# Returns:
#   0: if item found, 1 otherwise.
#
#====================
STRING_ITEM_INDEXOF()
{
    # shellcheck disable=SC2034
    SPACE_SIGNATURE="string item [outvarname]"

    local __s="${1}"
    shift

    local __item="${1}"
    shift

    local __outvar="${1-}"
    shift $(( $# > 0 ? 1 : 0 ))

    local __item2=
    local __count=0
    for __item2 in ${__s}; do
        if [ "${__item}" = "${__item2}" ]; then
            if [ -n "${__outvar}" ]; then
                eval "${__outvar}=\"\${__count}\""
            fi
            return 0
        fi
        __count=$((__count+1))
    done
    if [ -n "${__outvar}" ]; then
        eval "${__outvar}=\"-1\""
    fi
    return 1
}

#============
# STRING_LPAD
#
# Left pad a string with a given character, in place.
#
# Parameters:
#   $1: the name of the variable to trim.
#   $2: the character to pad with
#   $3: the final length of the string
#
# Returns:
#   zero
#
#============
STRING_LPAD()
{
    SPACE_SIGNATURE="varname char length"

    local __char="${2}"
    local __length="${3}"

    # shellcheck disable=SC2034
    local __sopriv=
    eval "__sopriv=\"\${${1}}\""
    while [ "${#__sopriv}" -lt "${__length}" ]; do
        __sopriv="${__char}${__sopriv}"
    done
    eval "${1}=\"\${__sopriv}\""
}

#============
# STRING_RPAD
#
# Right pad a string with a given character, in place.
#
# Parameters:
#   $1: the name of the variable to trim.
#   $2: the character to pad with
#   $3: the final length of the string
#
# Returns:
#   zero
#
#============
STRING_RPAD()
{
    SPACE_SIGNATURE="varname char length"

    local __char="${2}"
    local __length="${3}"

    # shellcheck disable=SC2034
    local __sopriv=
    eval "__sopriv=\"\${${1}}\""
    while [ "${#__sopriv}" -lt "${__length}" ]; do
        __sopriv="${__sopriv}${__char}"
    done
    eval "${1}=\"\${__sopriv}\""
}

# TODO: add tests for this
#============
# STRING_SUBSTR
#
# Get a substring by index (positive or negative) and a length.
# If index and length are out of bounds then empty string is returned.
#
# Parameters:
#   $1: the name of the variable to get single char from
#   $2: index, the numeric index of the char, negative values count from the end of string as -1 = last char
#   $3: length, number of chars to get. If "" then take rest of line. If negative then count from the end of the string where -1 cuts away the last char.
#   $4: variable name to store character in, empty string if index out of bounds.
#
# Returns:
#   zero
#
#============
STRING_SUBSTR()
{
    SPACE_SIGNATURE="varname index length:0 outvarname"
    SPACE_DEP="STRING_REPEAT"

    # shellcheck disable=SC2034
    local __sopriv=
    eval "__sopriv=\"\${${1}}\""
    shift

    local __index="${1}"
    shift

    local __length="${1}"
    shift

    local __outvar="${1}"
    shift

    local __strlength="${#__sopriv}"

    if [ "${__index}" -lt 0 ]; then
        __index=$((__strlength+__index))
    fi

    if [ "${__index}" -ge 0 ]; then
        if [ "${__length}" = "" ]; then
            __length=$((__strlength-__index))
        fi

        if [ "${__length}" -lt 0 ]; then
            __length=$((__strlength-__index+__length))
        fi

        if [ "$((__index+__length))" -le "${#__sopriv}" ]; then
            local __wildcard=
            STRING_REPEAT "?" "${__index}" "" "__wildcard"
            local __substr="${__sopriv#${__wildcard}}"
            STRING_REPEAT "?" "$((${#__substr}-__length))" "" "__wildcard"
            __substr="${__substr%${__wildcard}}"
            eval "${__outvar}=\"\${__substr}\""
            return 0
        fi

    fi

    eval "${__outvar}=\"\""
}

# TODO: add tests for this
#============
# STRING_REPEAT
#
# Repeat a string x times.
#
# Parameters:
#   $1: the string to repeat
#   $2: count, the number of times to repeat the string
#   $3: separator, string separator between repeated string
#   $4: variable name to store string to
#
# Returns:
#   zero
#
#============
STRING_REPEAT()
{
    SPACE_SIGNATURE="string count separator:0 outvarname"

    local __string="${1}"
    shift

    local __count="${1}"
    shift

    local __separator="${1}"
    shift

    local __outvar="${1}"
    shift

    local __repeatedstring=""
    while [ "${__count}" -gt 0 ]; do
        __count=$((__count-1))
        __repeatedstring="${__repeatedstring}${__string}"
        if [ "${__count}" -gt 0 ]; then
            __repeatedstring="${__repeatedstring}${__separator}"
        fi
    done

    eval "${__outvar}=\"\${__repeatedstring}\""
}

# TODO: add tests for this
#============
# STRING_HASH
#
# Hash a string using a native sha256 program
#
# Parameters:
#   $1: the string to hash
#   $2: variable name to store hash into
#
# Returns:
#   0: on success
#   1: if no sha256 binary found on system
#
#============
STRING_HASH()
{
    SPACE_SIGNATURE="str"

    local __str="${1}"
    shift

    local __outvar="${1}"
    shift

    local SHASUMBIN=
    if command -v sha256sum >/dev/null; then
        SHASUMBIN="sha256sum"
    elif command -v shasum >/dev/null; then
        SHASUMBIN="shasum -a 256"
    fi

    if [ -z "${SHASUMBIN}" ]; then
        return 1
    fi

    local __hash=
    __hash=$(printf "%s\\n" "${__str}" |${SHASUMBIN}) || { return 1; }
    __hash="${__hash%%[ ]*}"
    eval "${__outvar}=\"\${__hash}\""
}
