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
# Trim whitespace (spaces and tabs) from a string left and right.
#
# Parameters:
#   $1: the name of the variable to trim.
#
# Expects:
#   $1: The variable should be set with the value to trim.
#       This variable is directly trimmed on.
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
#   0: if sub string found and no $3 variable name is given.
#   1: if sub string not found and no $3 variable name is given.
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
            return 0
        else
            return 1
        fi
    fi

    if [ -n "${varname}" ]; then
        eval "${varname}=\"${#rest}\""
    fi
    return 0
}

#=============
# STRING_ESCAPE
#
# Escape in place up the occurrences of quotes, dollar signs and parenthesis.
#
# It is optional which of ", $, ( and ) to escape.
#
# Parameters:
#   $1: Name of the variable to escape up, in place.
#   $2: Optional which characters to escape, defaults to '"$()'.
#
#=============
STRING_ESCAPE()
{
    SPACE_SIGNATURE="varname [escapes]"
    SPACE_DEP="_STRING_ESCAPE"

    case "${2-\"\$\(\)}" in
        *\"*)
            _STRING_ESCAPE "${1}" '"'
            ;;
    esac
    case "${2-\"\$\(\)}" in
        *\$*)
            _STRING_ESCAPE "${1}" '$'
            ;;
    esac
    case "${2-\"\$\(\)}" in
        *\(*)
            _STRING_ESCAPE "${1}" '('
            ;;
    esac
    case "${2-\"\$\(\)}" in
        *\)*)
            _STRING_ESCAPE "${1}" ')'
            ;;
    esac
}

#===============
# _STRING_ESCAPE
#
# Helper function.
#
#===============
_STRING_ESCAPE()
{
    # shellcheck disable=2034
    SPACE_DEP="STRING_SUBST"

    STRING_SUBST "${1}" "${2}" "\\${2}" "1"
    STRING_SUBST "${1}" '\\\\'${2} '\\\'${2} "1"
}

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
