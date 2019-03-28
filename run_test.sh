#!/bin/bash

timestamp=$(date +%H%M%S)
mkdir -p ./tests/output/$1/$timestamp
uw-sim --nogui -Gtest_num=$1 kirsch.uwp
ted_to_bmp ./tests/res$1_sim.ted
mv ./tests/res$1_sim.ted ./tests/output/$1/$timestamp/sim.ted
mv ./tests/res$1_sim.bmp ./tests/output/$1/$timestamp/sim.bmp
diff_ted ./tests/res$1_spec.ted ./tests/output/$1/$timestamp/sim.ted > ./tests/output/$1/$timestamp/diff.ted
diff_ted_to_bmp ./tests/res$1_spec.ted ./tests/output/$1/$timestamp/sim.ted ./tests/output/$1/$timestamp/diff.bmp