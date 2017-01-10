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
    local __sopriv=
    eval "__sopriv=\"${1}\""
    while true; do
        eval "${1}=\"\${$1#\"\${$1%%[^ ]*}\"}\""
        eval "${1}=\"\${$1%\"\${$1##*[^ ]}\"}\""
        eval "${1}=\"\${$1#\"\${$1%%[^$'\t']*}\"}\""
        eval "${1}=\"\${$1%\"\${$1##*[^$'\t']}\"}\""
        if eval "[ \"\${${1}}\" = \"\${__sopriv}\" ]"; then
            break
        fi
        eval "__sopriv=\"\${${1}}\""
    done
}

#=============
# STRING_SUBST
#
# Substitute text in place.
#
# Parameters:
#   $1: variable name to substitute in.
#   $2: text to substitute.
#   $3: text to insert.
#
#=============
STRING_SUBST()
{
    eval "${1}=\${${1}//\${2}/\${3}}"
}
