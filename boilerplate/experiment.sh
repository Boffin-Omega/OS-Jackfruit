#!/bin/bash

for i in {1..3}; do
    echo "run $i : nice=0 vs nice=10 (concurrent)"

    START_A=$(date +%s)
    sudo ./engine start t5expA_$i ../rootfs-alpha "/cpu_hog 10" --nice 0

    START_B=$(date +%s)
    sudo ./engine start t5expB_$i ../rootfs-beta "/cpu_hog 10" --nice 10

    DONE_A=0
    DONE_B=0

    while true; do
        OUT=$(sudo ./engine ps)

        if [ $DONE_A -eq 0 ] && ! echo "$OUT" | grep t5expA_$i | grep -q running; then
            END_A=$(date +%s)
            TIME_A=$((END_A - START_A))
            echo "t5expA_$i (nice=0) finished in ${TIME_A}s"
            DONE_A=1
        fi

        if [ $DONE_B -eq 0 ] && ! echo "$OUT" | grep t5expB_$i | grep -q running; then
            END_B=$(date +%s)
            TIME_B=$((END_B - START_B))
            echo "t5expB_$i (nice=10) finished in ${TIME_B}s"
            DONE_B=1
        fi

        if [ $DONE_A -eq 1 ] && [ $DONE_B -eq 1 ]; then
            break
        fi

        sleep 1
    done

    echo ""
done