#!/bin/bash

# Setting the multiplier for the normal mode coordinates before adding them to the XYZ
[ -n "$2" ] && shifmul="$2" || shifmul="0.2"
# Getting the last XYZ coordinates:
findmingeom -xlj "$totlines" -a /tmp/normalmode_gaus_$$_last.xyz "$1"
natoms=$(gawk '/NAtoms=/{print $2; exit}' "$1")
# Getting all the normal modes:
numimag="$(gawk '/imaginary frequencies \(negative Sig/{print $2}' "$1")"
imaginaries=($(seq 1 $numimag))
[ ${#imaginaries[@]} -eq 0 ] && echo "No imaginary nodes found! Aborting..." && exit 3
# Getting all the normal modes:
normalmodes="$(sed -n '/imaginary frequencies (negative Sig/,/^ *$/p' "$1" | sed '1,7d;$d')" && echo "Normal modes extracted!"
# Selecting the imaginary normal modes, printing them to separate files, applying the shift to the last XYZ coordinates
for ima in $(seq 1 ${#imaginaries[@]}); do
    echo "Processing imaginary mode ${ima}..."
    [ -f /tmp/normalmode_gaus_$$_shifted.xyz ] && rm /tmp/normalmode_gaus_$$_last.xyz && mv /tmp/normalmode_gaus_$$_shifted.xyz /tmp/normalmode_gaus_$$_last.xyz
    im=$((ima-1))
    echo "$normalmodes" | gawk '/ '"${imaginaries[$im]}"' [^.]*$/ || / '"${imaginaries[$im]}"'$/ {j=0; for(i=1;i<NF+1;i++) {if($i ~ '"${imaginaries[$im]}"') j=i }; for(i=0;i<6;++i) {getline}; for(i=0;i<'"$natoms"';++i) {getline; print $((j-1)*3+3)"  "$((j-1)*3+4)"  "$((j-1)*3+5)}}' > /tmp/normalmode_gaus_$$_${im}.tmp
    #less /tmp/normalmode_gaus_$$_${im}.tmp
    #less /tmp/normalmode_gaus_$$_last.xyz
    shift_coords.py /tmp/normalmode_gaus_$$_last.xyz /tmp/normalmode_gaus_$$_${im}.tmp /tmp/normalmode_gaus_$$_shifted.xyz $shifmul
done
# Moving the file to the $PWD and removing the temporary files if successful
cp /tmp/normalmode_gaus_$$_shifted.xyz ${1%.out}_shifted.xyz && rm /tmp/normalmode_gaus_$$_* && echo "The shifted geometry saved in XYZ ${1%.out}_shifted.xyz"


