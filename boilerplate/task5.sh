for i in {1..3}; do
    echo "run: $i : nice=0"
    time sudo ./engine run t5exp1_$i ../rootfs-alpha "/cpu_hog 10" --nice 0
    echo ""
done

for i in {1..3}; do
    echo "run $i : nice=10"
    time sudo ./engine run t5exp2_$i ../rootfs-alpha "/cpu_hog 10" --nice 10
    echo ""
done