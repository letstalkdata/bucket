#!/bin/bash
name=$(hostname)
echo "executing code on $name"
i=10;
while (( $i > 0 )); do
	fname="testout"$i".txt"
	echo "Test created" > $fname
	sleep 2s
	i=$((i-1));
done

