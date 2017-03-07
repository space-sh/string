#
# Copyright 2016-2017 Blockie AB
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

#==================
# _TEST_STRING_TRIM()
#
#
#==================
_TEST_STRING_TRIM()
{
    SPACE_DEP="STRING_TRIM PRINT"

    local s="Hello World !"
    local S="Hello World !
"
    local s1="    Hello World !   "
    local s2="		Hello World !	"
    local s3="  		  Hello World !  	  	 "
    local s4="	  	    	  	Hello World !  	  	 		    "
    local s5="	  	    	  	Hello World !
		   "

    STRING_TRIM "s1"

    if [ "${s}" != "${s1}" ]; then
        PRINT "Could not trim s1." "error"
        PRINT "Expected: '${s}' got '${s1}'"
        return 1
    fi

    STRING_TRIM "s2"

    if [ "${s}" != "${s2}" ]; then
        PRINT "Could not trim s2." "error"
        PRINT "Expected: '${s}' got '${s2}'"
        return 1
    fi

    STRING_TRIM "s3"

    if [ "${s}" != "${s3}" ]; then
        PRINT "Could not trim s3." "error"
        PRINT "Expected: '${s}' got '${s3}'"
        return 1
    fi

    STRING_TRIM "s4"

    if [ "${s}" != "${s4}" ]; then
        PRINT "Could not trim s4." "error"
        PRINT "Expected: '${s}' got '${s4}'"
        return 1
    fi

    STRING_TRIM "s5"

    if [ "${S}" != "${s5}" ]; then
        PRINT "Could not trim s5." "error"
        PRINT "Expected: '${S}' got '${s5}'"
        return 1
    fi
}

#===================
# _TEST_STRING_SUBST
#
#
#===================
_TEST_STRING_SUBST()
{
    SPACE_DEP="STRING_SUBST PRINT"

    local text="This is a _long_ text.	Containing some special characters? \\
It is.		-Yes__!\@#'zzz'	
."
    local text1="This is a !!!long!!! text.	Containing some special characters? \\
It is.		-Yes!!!!!!!\@#'zzz'	
."
    local text2="Thisis a _long_ text.	Containing some special characters? \\
It is.		-Yes__!\@#'zzz'	
."
    local text3="Thisisa_long_text.	Containingsomespecialcharacters?\\
Itis.		-Yes__!\@#'zzz'	
."
    local text4="This is a _long_ text.	Containing some special characters? \\It is.		-Yes__!\@#'zzz'	."

    local s="${text}"
    STRING_SUBST "s" "_" "!!!" "1"

    if [ "${s}" != "${text1}" ]; then
        PRINT "Could not subst text1." "error"
        PRINT "Expected: '${text1}' got '${s}'"
        return 1
    fi

    local s="${text}"
    STRING_SUBST "s" " " ""

    if [ "${s}" != "${text2}" ]; then
        PRINT "Could not subst text2." "error"
        PRINT "Expected: '${text2}' got '${s}'"
        return 1
    fi

    local s="${text}"
    STRING_SUBST "s" " " "" "1"

    if [ "${s}" != "${text3}" ]; then
        PRINT "Could not subst text3." "error"
        PRINT "Expected: '${text3}' got '${s}'"
        return 1
    fi

    local s="${text}"
    STRING_SUBST "s" "
" "" "1"

    if [ "${s}" != "${text4}" ]; then
        PRINT "Could not subst text4." "error"
        PRINT "Expected: '${text4}' got '${s}'"
        return 1
    fi
}

#===================
# _TEST_STRING_INDEXOF
#
#
#===================
_TEST_STRING_INDEXOF()
{
    SPACE_DEP="STRING_INDEXOF PRINT"

    local text="This is a _long_ text.	Containing some special characters?
It is.		-Yes__!\@#'zzz'	
."

    local i=
    STRING_INDEXOF "_long_" "${text}" "i"

    if [ "${i}" -ne 10 ]; then
        PRINT "Could not find substring _long_, got $i" "error"
        return 1
    fi

    STRING_INDEXOF "-Yes" "${text}" "i"
    if [ "${i}" -ne 67 ]; then
        PRINT "Could not find substring -Yes, got $i" "error"
        return 1
    fi

    STRING_INDEXOF "-No" "${text}" "i"
    if [ "${i}" -ne -1 ]; then
        PRINT "Could not not find substring -No, at $i" "error"
        return 1
    fi
    STRING_INDEXOF "This" "${text}"
}

#===================
# _TEST_STRING_ESCAPE
#
#
#===================
_TEST_STRING_ESCAPE()
{
    SPACE_DEP="STRING_ESCAPE PRINT"

    local text='A test "of quotes" and $variables \${abcd} $(ls)'
    local text1='A test \"of quotes\" and \$variables \\\${abcd} \$\(ls\)'
    local text2='A test \\\"of quotes\\\" and \\\$variables \\\\\${abcd} \\\$\\\(ls\\\)'
    local text3='A test \\\\\"of quotes\\\\\" and \\\\\$variables \\\\\\\${abcd} \\\\\$\\\\\(ls\\\\\)'
    local text4='A test \"of quotes\" and $variables \${abcd} $(ls)'
    local text5='A test \"of quotes\" and $variables \${abcd} $\(ls)'

    local s="${text}"
    STRING_ESCAPE "s"

    if [ "${s}" != "${text1}" ]; then
        PRINT "Could not escape to text1." "error"
        PRINT "Expected: '${text1}' got '${s}'"
        return 1
    fi

    STRING_ESCAPE "s"

    if [ "${s}" != "${text2}" ]; then
        PRINT "Could not escape to text2." "error"
        PRINT "Expected: '${text2}' got '${s}'"
        return 1
    fi

    STRING_ESCAPE "s"

    if [ "${s}" != "${text3}" ]; then
        PRINT "Could not escape to text3." "error"
        PRINT "Expected: '${text3}' got '${s}'"
        return 1
    fi

    local s="${text}"
    STRING_ESCAPE "s" '"'

    if [ "${s}" != "${text4}" ]; then
        PRINT "Could not escape to text4." "error"
        PRINT "Expected: '${text4}' got '${s}'"
        return 1
    fi

    local s="${text}"
    STRING_ESCAPE "s" '"('

    if [ "${s}" != "${text5}" ]; then
        PRINT "Could not escape to text5." "error"
        PRINT "Expected: '${text5}' got '${s}'"
        return 1
    fi
}

#===================
# _TEST_STRING_ITEM_GET
#
#
#===================
_TEST_STRING_ITEM_GET()
{
    SPACE_DEP="STRING_ITEM_GET STRING_ITEM_COUNT PRINT"

    local text="item0 item1 item2 item3
item4"

    local i=
    STRING_ITEM_COUNT "${text}" "i"

    if [ "${i}" -ne 5 ]; then
        PRINT "Could not count items in text." "error"
        return 1
    fi

    local s=
    STRING_ITEM_GET "${text}" "0" "s"

    if [ "${s}" != "item0" ]; then
        PRINT "Could not count get item 0 in text." "error"
        return 1
    fi

    local s=
    STRING_ITEM_GET "${text}" "3" "s"

    if [ "${s}" != "item3" ]; then
        PRINT "Could not count get item 3 in text." "error"
        return 1
    fi

    local s=
    STRING_ITEM_GET "${text}" "4" "s"

    if [ "${s}" != "item4" ]; then
        PRINT "Could not count get item 4 in text." "error"
        return 1
    fi
}
