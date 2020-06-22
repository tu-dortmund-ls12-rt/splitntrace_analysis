#!/bin/bash

END_ADDR=$1
BUILDPATH=$2
DBG_FILE=$3

binary=$DBG_FILE

SOURCE_FILES=($(find $BUILDPATH -maxdepth 1 \( -name "lib*.o" -or -name "app*.o" \) -not -name "*.ld.o"))
NUM_SOURCE_FULES=${#SOURCE_FILES[@]}
for i in $(seq 0 $(($NUM_SOURCE_FULES-1)));
do
    RESULT_SECTIONS[$i]=""
    echo "${SOURCE_FILES[$i]}"
done

LAST_VALID_SOURCE=0
LAST_VALID_ADDR=0


    SYMBOL_TABLE=($(aarch64-linux-gnu-nm $binary | sort))
    EL_COUNT=${#SYMBOL_TABLE[@]}
    EL_COUNT=$((EL_COUNT / 3))
    for i in $(seq 0 $(($EL_COUNT-1)));
    do
        SYMBOL_ADDR=${SYMBOL_TABLE[$((i*3))]}
        SYMBOL_NAME=${SYMBOL_TABLE[$((i*3+2))]}
        
        if [ "$SYMBOL_ADDR" != "" ];
        then
            #try to find the source of the symbol
            for x in ${!SOURCE_FILES[@]};
            do
                RESULT_LINE=$(aarch64-linux-gnu-nm ${SOURCE_FILES[$x]} | grep "[0-9a-f][0-9a-f]* .* $SYMBOL_NAME")
                if [ "$RESULT_LINE" != "" ]
                then
                    echo "Found $SYMBOL_NAME in ${SOURCE_FILES[$x]}"
                    if [ $x == $LAST_VALID_SOURCE ]
                    then
                        #Just updathe info since this is coherent anyway
                        LAST_VALID_ADDR=$SYMBOL_ADDR
                    else
                        #this means, the current address finally closes the last sequence
                        if [ "${RESULT_SECTIONS[$LAST_VALID_SOURCE]}" == "" ];
                        then
                            RESULT_SECTIONS[$LAST_VALID_SOURCE]="0x$SYMBOL_ADDR"
                        else
                            RESULT_SECTIONS[$LAST_VALID_SOURCE]="${RESULT_SECTIONS[$LAST_VALID_SOURCE]}, 0x$SYMBOL_ADDR"
                        fi
                        #and also opens the next sequence
                        if [ "${RESULT_SECTIONS[$x]}" == "" ];
                        then
                            RESULT_SECTIONS[$x]="0x$SYMBOL_ADDR"
                        else
                            RESULT_SECTIONS[$x]="${RESULT_SECTIONS[$x]}, 0x$SYMBOL_ADDR"
                        fi
                        LAST_VALID_SOURCE=$x
                    fi
                fi
            done
        fi
    done

    RESULT_SECTIONS[$LAST_VALID_SOURCE]="${RESULT_SECTIONS[$LAST_VALID_SOURCE]}, 0x$END_ADDR"
    
    SECTION_VECTOR=""
    NAME_VECTOR=""
    
    for i in $(seq 0 $(($NUM_SOURCE_FULES-1)));
    do
        if [ "${RESULT_SECTIONS[$i]}" != "" ];
        then
            if [ "$NAME_VECTOR" == "" ];
            then
                NAME_VECTOR="\" ${SOURCE_FILES[$i]}\""
            else
                NAME_VECTOR="$NAME_VECTOR, \" ${SOURCE_FILES[$i]}\""
            fi
            if [ "$SECTION_VECTOR" == "" ];
            then
                SECTION_VECTOR="c(${RESULT_SECTIONS[$i]})"
            else
                SECTION_VECTOR="$SECTION_VECTOR, c(${RESULT_SECTIONS[$i]})"
            fi
        fi
    done
    
    echo "lib_names <- c($NAME_VECTOR)" > vec.R
    echo "lib_sections <- list($SECTION_VECTOR)" >> vec.R
