function F()
{
   local FILE
   local PATTERN

   echo -n "Enter files to search:"
   read FILE

   echo -n "Enter string to search:"
   read PATTERN

   set -f

   for filetype in $FILE
   do
      find . -not \( -path ./.svn -prune \) -name "$filetype" -type f -exec grep -n "$PATTERN" {} /dev/null \;
   done

   set +f
}

function WC()
{
   local FILE
      
   echo -n "Enter file patterns to count:"
   read FILE

   find . -name "$FILE" | xargs wc -l
}
