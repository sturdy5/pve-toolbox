#!/bin/bash

# make sure there is exactly three arguments
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <lxc id> <directory> <mount point>"
  exit 1
fi

lxc_id=$1
directory=$2
mount_point=$3

# check to see if the directory exists
if [ ! -d "$directory" ]; then
  echo "Directory $directory does not exist"
  exit 1
fi

# check to see if the directory is already mounted into the lxc container
if grep -q "$directory" /etc/pve/lxc/$lxc_id.conf; then
  echo "Directory $directory is already mounted into lxc container $lxc_id"
  exit 0
fi

# figure out the next available mount point in the lxc container
# get the lines that start with mp and a number followed by a colon
mp_lines=$(grep -E "^mp[0-9]+:" /etc/pve/lxc/$lxc_id.conf | sort -V)
# if there are no lines that start with mp and a number followed by a colon, then the next available mount point is mp0
if [ -z "$mp_lines" ]; then
  next_mp_number=0
else
  # get the last line
  last_mp_line=$(echo "$mp_lines" | tail -n 1)
  # get the number after mp and before the colon
  last_mp_number=$(echo "$last_mp_line" | sed -E 's/^mp([0-9]+):.*/\1/')
  # increment the number by 1
  next_mp_number=$((last_mp_number + 1))
fi

# mount the directory into the lxc container
echo "Mounting directory $directory into lxc container $lxc_id"
pct set $lxc_id -mp$next_mp_number "$directory,$mount_point"

# restart the lxc container
echo "Restarting lxc container $lxc_id"
pct reboot $lxc_id
