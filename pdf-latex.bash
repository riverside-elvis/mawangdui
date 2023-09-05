# Pre-process markdown to insert latex before generating the PDF.
BOOK_START=0
BOOK_END=0
SEC_ENTER=0
SEC_EXIT=0
SSEC_ENTER=0
SSEC_EXIT=0
PARA_ENTER=0
PARA_EXIT=0
DEBUG=0

function format_line() {
    if [[ "$line" =~ ^［ ]]; then
        echo "\\Large $line  "
    elif [[ "$line" =~ ^（ ]]; then
        echo "\\Large $line  "
    elif [[ "$line" =~ ^[[:upper:]] ]]; then
        echo "\\small $line  "
    elif [[ "$line" =~ ^[[:lower:]] ]]; then
        echo "\\small $line  "
    elif [[ "$line" =~ ^[[:punct:]] ]]; then
        echo "\\small $line  "
    else
        echo "\\Large $line  "
    fi
}

while IFS= read -r line; do

    if [[ $BOOK_END -eq 1 ]]; then
        echo "$line"
        continue
    fi

    if [[ "$line" =~ ^#[[:space:]] ]]; then
        if [[ $SEC_ENTER -eq 1 ]]; then
            SEC_EXIT=1
            if [[ $DEBUG -eq 1 ]]; then echo "%SEC-EXIT"; fi
        fi
        if [[ $PARA_EXIT -eq 1 ]]; then
            if [[ $DEBUG -eq 1 ]]; then echo "%SEC-PARA-EXIT"; fi
            echo
            echo "\\egroup"
        fi
        if [[ $BOOK_START -eq 1 ]]; then
            BOOK_END=1
            if [[ $DEBUG -eq 1 ]]; then echo "%BOOK-END"; fi
        fi
        if [[ "$line" =~ Appendix ]]; then
            BOOK_END=1
            echo "$line"
            continue
        fi
        if [[ "$line" =~ Part ]]; then
            BOOK_START=1
            if [[ $DEBUG -eq 1 ]]; then echo "%BOOK-START"; fi
            BOOK_END=0
        fi
        echo "$line"
        SEC_ENTER=1
        if [[ $DEBUG -eq 1 ]]; then echo "%SEC-ENTER"; fi
        SEC_EXIT=0
        PARA_ENTER=0
        PARA_EXIT=0
        continue
    fi

    if [[ "$line" =~ ^##[[:space:]] ]]; then
        if [[ $SSEC_ENTER -eq 1 ]]; then
            SSEC_ENTER=0
            if [[ $PARA_EXIT -eq 1 ]]; then
                if [[ $DEBUG -eq 1 ]]; then echo "%SSEC-PARA-EXIT"; fi
                echo "\\ast$~$\\ast$~$\\ast"
                echo
                echo "\\egroup"
            else
                SSEC_EXIT=1
                if [[ $DEBUG -eq 1 ]]; then echo "%SSEC-EXIT"; fi
            fi
        fi
        echo "$line"
        SSEC_ENTER=1
        if [[ $DEBUG -eq 1 ]]; then echo "%SSEC-ENTER"; fi
        SSEC_EXIT=0
        PARA_ENTER=0
        PARA_EXIT=0
        continue
    fi

    if [[ $BOOK_START -eq 0 ]]; then
        echo "$line"
        continue
    fi

    if [[ "$line" = "" ]]; then
        if [[ $PARA_ENTER -eq 1 ]]; then
            PARA_ENTER=0
            PARA_EXIT=1
            if [[ $DEBUG -eq 1 ]]; then echo "%PARA-EXIT"; fi
        fi
        echo "$line"
        continue
    fi

    # Not a header and not a blank line.

    if [[ $PARA_ENTER -eq 0 ]]; then
        PARA_ENTER=1
        if [[ $PARA_EXIT -eq 1 ]]; then
            PARA_EXIT=0
            if [[ $DEBUG -eq 1 ]]; then echo "%PARA-EXIT-ENTER"; fi
            echo
            echo "\\egroup"
            echo "\\bgroup\\centering\\filbreak"
            format_line "$line"
            continue
        else
            if [[ $DEBUG -eq 1 ]]; then echo "%PARA-ENTER"; fi
            echo "\\bgroup\\centering\\filbreak"
            format_line "$line"
            continue
        fi
    fi

    format_line "$line"
    continue

done < "$1"
