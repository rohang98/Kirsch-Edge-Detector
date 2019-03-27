#!/bin/bash

uw-sim --nogui -Gtest_num=$1 kirsch.uwp
ted_to_bmp ./tests/res$1_sim.ted

