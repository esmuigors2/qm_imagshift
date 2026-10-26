#!/bin/bash

# Setting the multiplier for the normal mode coordinates before adding them to the XYZ
[ -n "$2" ] && shifmul="$2" || shifmul='0.1'
# Self-explanatory lines:
[ -n "$(grep -i -e '^ *!.*Opt' $1)" ] && [ -z "$(grep 'HURRAY' $1)" ] && echo "Warning: the optimization has not converged!"
natoms=$(gawk '/Number of atoms/{print $NF; exit}' $1)
# Getting the last XYZ coordinates:
echo -e "$natoms\n   original geometry" > /tmp/normalmode_orca_$$_last.xyz
sed -n '/CARTESIAN COORDINATES (ANGSTROEM)/{:a;N;/\n *$/!ba;x;d};${x;p}' $1 | sed '1,2d;$d' >> /tmp/normalmode_orca_$$_last.xyz && echo "Last geometry extracted!"
[ $(wc -l /tmp/normalmode_orca_$$_last.xyz) -eq 0 ] && echo "The molecule geometry was not successfully extracted! Aborting..." && exit 2
grep -e 'imaginary mode' $1
# Getting the ordinal numbers of the imaginary nodes:
imaginaries=($(sed -n '/VIBRATIONAL FREQUENCIES/{:a;/imaginary mode/{s@:.*@@;s@ *@@;p};N;/^ *\n *$/!{s@^.*\n@@;ba}}' $1))
[ ${#imaginaries[@]} -eq 0 ] && echo "No imaginary nodes found! Aborting..." && exit 3
# Getting all the normal modes:
normalmodes="$(sed -n '/NORMAL MODES/{:a;/[0-9]/{/[a-zA_Z]/!p};N;/^ *\n *$/!{s@^.*\n@@;ba}}' $1)" && echo "Normal modes extracted!"
# Selecting the imaginary normal modes, printing them to separate files, applying the shift to the last XYZ coordinates
for ima in $(seq 1 ${#imaginaries[@]}); do
    echo "Processing imaginary mode ${ima}..."
    [ -f /tmp/normalmode_orca_$$_shifted.xyz ] && rm /tmp/normalmode_orca_$$_last.xyz && mv /tmp/normalmode_orca_$$_shifted.xyz /tmp/normalmode_orca_$$_last.xyz
    im=$((ima-1))
    # I have tried an alternative way to rearrange the normal mode coords into XYZ; it turned out to produce much more radical shifts, hence that must be the wrong way, and what is below is the right way:
    echo "$normalmodes" | gawk '/ '"${imaginaries[$im]}"' [^.]*$/ || / '"${imaginaries[$im]}"'$/ {j=0; for(i=1;i<NF;i++) {if($i ~ '"${imaginaries[$im]}"') j=i }; for(i=0;i<3*'"$natoms"';++i) {getline; print $(j+1)}}' | sed 'N;N;s@\n@   @g' > /tmp/normalmode_orca_$$_${im}.tmp
    shift_coords.py /tmp/normalmode_orca_$$_last.xyz /tmp/normalmode_orca_$$_${im}.tmp /tmp/normalmode_orca_$$_shifted.xyz $shifmul
done
# Moving the file to the $PWD and removing the temporary files if successful
cp /tmp/normalmode_orca_$$_shifted.xyz ${1%.out}_shifted.xyz && rm /tmp/normalmode_orca_$$_* && echo "The shifted geometry saved in headless XYZ ${1%.out}_shifted.xyz"
