# String manipulation module | [![build status](https://gitlab.com/space-sh/string/badges/master/build.svg)](https://gitlab.com/space-sh/string/commits/master)


# Functions 

## STRING\_TRIM()  
  
  
  
Trim whitespace (spaces and tabs) from a string left and right.  
  
### Parameters:  
- $1: the name of the variable to trim.  
  
### Expects:  
- $1: The variable should be set with the value to trim.  
- This variable is directly trimmed on.  
  
### Returns:  
- non-zero if string error  
  
  
  
## STRING\_SUBST()  
  
  
  
Substitute text in place.  
  
### Parameters:  
- $1: variable name to substitute in.  
- $2: text to substitute away.  
- $3: text to insert in place.  
- $4: global, set to "1" to substitute all occurrences.  
  
  
  
## STRING\_INDEXOF()  
  
  
  
Find the first index of sub string in string.  
  
### Parameters:  
- $1: sub string to search for.  
- $2: string to search in.  
- $3: optional variable name to store index value to. -1 when sub string not found.  
  
### Returns:  
- 0: if sub string found and no $3 variable name is given.  
- 1: if sub string not found and no $3 variable name is given.  
  
  
  
## STRING\_ESCAPE()  
  
  
  
Escape in place up the occurrences of quotes, dollar signs and parenthesis.  
  
It is optional which of ", $, ( and ) to escape.  
  
### Parameters:  
- $1: Name of the variable to escape up, in place.  
- $2: Optional which characters to escape, defaults to '"$()'.  
  
  
  
## \_STRING\_ESCAPE()  
  
  
  
Helper function.  
  
  
  
## STRING\_ITEM\_COUNT()  
  
  
  
Count all items in a string, split on current IFS.  
  
### Parameters:  
- $1: string to count items in.  
- $2: variable name to store count in  
  
  
  
## STRING\_ITEM\_GET()  
  
  
  
Get an item in a string by it's index,  
where string is split on the current IFS.  
  
### Parameters:  
- $1: string to get item from.  
- $2: index of item to get.  
- $3: variable name to store item to.  
  
  
  
