#!/bin/bash

# switch hyperthreading on again
echo 1 > /sys/devices/system/cpu/cpu4/online
echo 1 > /sys/devices/system/cpu/cpu5/online
echo 1 > /sys/devices/system/cpu/cpu6/online
echo 1 > /sys/devices/system/cpu/cpu7/online

# switch turbo boost on again
wrmsr --all 0x1a0 0x850089

# set variable CPU frequency
echo 400000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo 400000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
echo 400000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
echo 400000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
echo 400000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq
echo 400000 > /sys/devices/system/cpu/cpu5/cpufreq/scaling_min_freq
echo 400000 > /sys/devices/system/cpu/cpu6/cpufreq/scaling_min_freq
echo 400000 > /sys/devices/system/cpu/cpu7/cpufreq/scaling_min_freq
echo 4200000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 4200000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
echo 4200000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
echo 4200000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq
echo 4200000 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq
echo 4200000 > /sys/devices/system/cpu/cpu5/cpufreq/scaling_max_freq
echo 4200000 > /sys/devices/system/cpu/cpu6/cpufreq/scaling_max_freq
echo 4200000 > /sys/devices/system/cpu/cpu7/cpufreq/scaling_max_freq

# switch off DPMS
xset +dpms

# provide some advice on how to use cset
echo "Now reset your dedicated CPU set:"
echo
echo "cset shield --reset"
