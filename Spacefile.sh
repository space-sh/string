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
    # shellcheck disable=SC2034
    local __sopriv=
    eval "__sopriv=\"\${${1}}\""
    while true; do
        eval "${1}=\"\${$1#\"\${$1%%[! ]*}\"}\""
        eval "${1}=\"\${$1%\"\${$1##*[! ]}\"}\""
        eval "${1}=\"\${$1#\"\${$1%%[!$'\t']*}\"}\""
        eval "${1}=\"\${$1%\"\${$1##*[!$'\t']}\"}\""
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
    local __varname="${1}"
    local __string=
    eval "__string=\"\${$1}\""
    shift

    local __subst="${1}"
    shift

    local __replace="${1}"
    shift

    local __global="${1:-0}"
    shift $(( $# > 0 ? 1 : 0 ))

    local __lstring=
    local __rstring=
    local __tag="___SpaceGalWasHere___"
    # First replace with the obscure tag.
    # This is to not end up in forever loop subst in subst.
    while true; do
        __lstring="${__string%%${__subst}*}"
        if [ "${__lstring}" = "${__string}" ]; then
            # No more matches.
            break
        fi
        __rstring="${__string#*${__subst}}"
        __string="${__lstring}${__tag}${__rstring}"
        if [ "${__global}" -ne 1 ]; then
            break
        fi
    done
    while true; do
        __lstring="${__string%%${__tag}*}"
        if [ "${__lstring}" = "${__string}" ]; then
            # No more matches.
            break
        fi
        __rstring="${__string#*${__tag}}"
        __string="${__lstring}${__replace}${__rstring}"
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
#   $3: optional variable name to store index value to. -1 whensub string  not found.
#
# Returns:
#   0: if sub string found and no $3 variable name is given.
#   1: if sub string not found and no $3 variable name is given.
#
#=============
STRING_INDEXOF()
{
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
        else
            return 1
        fi
    fi

    if [ -n "${varname}" ]; then
        eval "${varname}=\"${#rest}\""
    fi
    return 0
}
