#!/bin/bash

# switch off turbo boost
wrmsr --all 0x1a0 0x4000850089

# set fixed CPU frequency
echo 1900000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 1900000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
echo 1900000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
echo 1900000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
echo 1900000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
echo 1900000 > /sys/devices/system/cpu/cpu5/cpufreq/scaling_min_freq
echo 1900000 > /sys/devices/system/cpu/cpu6/cpufreq/scaling_min_freq
echo 1900000 > /sys/devices/system/cpu/cpu7/cpufreq/scaling_min_freq
echo 1900000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 1900000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
echo 1900000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
echo 1900000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq
echo 1900000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
echo 1900000 > /sys/devices/system/cpu/cpu5/cpufreq/scaling_max_freq
echo 1900000 > /sys/devices/system/cpu/cpu6/cpufreq/scaling_max_freq
echo 1900000 > /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq

# switch off hyperthreading
echo 0 > /sys/devices/system/cpu/cpu4/online
echo 0 > /sys/devices/system/cpu/cpu5/online
echo 0 > /sys/devices/system/cpu/cpu6/online
echo 0 > /sys/devices/system/cpu/cpu7/online

# switch off DPMS
xset -dpms

# provide some advice on how to use cset
echo "Now create a dedicated CPU set for your benchmarks:"
echo
echo "cset shield --kthread on --cpu 3"
echo "cset set --list"
echo "cset shield --user=simonisv --group=domain^users --exec bash -- -c \"./benchmarks/bash/run-java-deflate.sh -o /tmp/i7-8650U-1900MHz-deflate-my-corretto11-2020-07-06 -j corretto-11-opt/images/jdk/bin/java -n corretto11 ./data/silesia/*[^b]\""
