#!/bin/bash

# Is able to search the following types of files
# pdf
# txt
# html
# epub
#
# Cannot yet search
# mobi
# djvu
# cbr (probably for forever since it's images)
# rtf
# fb2
# docx
# doc
# odf


### Collects search terms and directory
echo "Enter directory to recursively search"
read library
echo "Enter search terms separated by commas"
read terms
grepterms=${terms//,/\|}
zipterms=${terms//,/\\n}
outputfile=~/$(date "+Search_from_%F_%H%M%S").txt



### Move to the library directory to make output less verbose
cd "$library"



### Performs the appropriate grep according to filetype and outputs to file
find_terms() {
    if [[ "$1" =~ .*\.pdf ]]; then
        pdfgrep -Hi "$grepterms" "$1" >> $outputfile
    elif [[ "$1" =~ .*\.(txt|html) ]]; then 
        grep -HiE "$grepterms" "$1" >> $outputfile
    elif [[ "$1" =~ .*\.epub ]]; then
        epubresults=$(zipgrep -i "$zipterms" "$1")
        if [[ "$epubresults" != "" ]]; then
            epubreturn="$1\n$epubresults"
            echo $epubreturn >> $outputfile
        fi
    fi
}



### To avoid problems with wildcards, globbing, or spaces in file names
IFS=$'\n'; set -f



### For loop recursively iterates the directory for valid files
for f in $(find ./ -iregex ".*\.\(pdf\|html\|txt\|epub\)"); do
    find_terms $f
done



### To avoid problems with wildcards, globbing, or spaces in file names
unset IFS; set +f
