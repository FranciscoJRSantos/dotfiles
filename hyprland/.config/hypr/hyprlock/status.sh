#!/usr/bin/env bash

############ Variables ############
enable_battery=false
battery_charging=false
battery_path=""

####### Check availability ########
for battery in /sys/class/power_supply/*BAT*; do
  if [[ -f "$battery/uevent" ]]; then
    enable_battery=true
    battery_path="$battery"
    if [[ $(cat "$battery_path/status") == "Charging" ]]; then
      battery_charging=true
    fi
    break
  fi
done

############# Output #############
if [[ $enable_battery == true && -n "$battery_path" ]]; then
  if [[ $battery_charging == true ]]; then
    echo -n "(+) "
  fi
  echo -n "$(cat "$battery_path/capacity")%"
  if [[ $battery_charging == false ]]; then
    echo -n " remaining"
  fi
fi

echo ''
