#!/bin/sh
if [ $# -ne 1 ]; then
    echo "Usage: $0 [binary]"
    exit 1
fi
# generate crashes directory
mkdir -p crashes
# loop forever
i=0
# generate tests
while [ true ]
do
    grammarinator-generate -p output/JavaScriptUnparser.py -l output/JavaScriptUnlexer.py -r program -d 10 -n 300 -o tests/test.js
    retVal=$?
    if [ $retVal -ne 0 ]; then
        echo "Error"
        exit $retVal
    fi
    echo "Generated tests"
    sed -i -e "s/debugger//g" /home/tests/*
    grep debugger /home/tests/*
    retVal=$?
    if [ $retVal -ne 1 ]; then
        echo "Error removing string debugger from tests"
        exit $retVal
    fi
    # get rid of infinite loops
    sed -i -e "s/for(;;*)//g" /home/tests/*
    for f in /home/tests/*
    do
        echo "Processing $f file..."
        # take action on each file. $f store current file name
        ./$1 $f
        retVal=$?
        # if segmentation fault log it
        if [ $retVal -eq 139 ]; then
            mv $f crashes/$f
            echo "Found crash!"
            i=$((i+1))
        else
            rm $f
        fi
    done
    for k in {1..5}
    do
        echo "========================================"
    done
    echo "$i crashes found"
    for k in {1..5}
    do
        echo "========================================"
    done
done