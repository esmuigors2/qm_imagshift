# qm_imagshift
Bash scripts for producing geometries shifted along the imaginary modes.

## orca_imagshift.sh
A bash script to produce geometries shifted along the imaginary modes, for reoptimization in <a href=https://https://orcaforum.kofo.mpg.de>ORCA</a>
## gaus_imagshift.sh
A bash script to produce geometries shifted along the imaginary modes, for reoptimization in <a href=https://https://gaussian.com>Gaussian</a>

## Dependencies
sed

gawk

for gaus_imagshift.sh, <a href="https://github.com/esmuigors2/findmingeom">findmingeom</a>

## How to use
orca_imagshift.sh orca_output_file.out multiplier

gaus_imagshift.sh gaus_output_file.out multiplier

Multiplier is used to multiply the normal mode coordinates before adding them  to the optimized geometry. The result can be closer or further from equilibrium, so please check the result in Avogadro or elsewhere to ensure that the initial geometry for the reoptimization is not meaningless.

## Effect
A file named orca_output_file_shifted.xyz or gaus_output_file_shifted.xyz, respectively, is created in the same directory.
It is an XYZ file, i.e. it _does contain_ the number-of-atoms line and the title line. For inserting into the input file, You must delete first two lines.

## Purpose
Sometimes after the geometry optimization we arrive at the saddle point instead of a minimum (an unpleasant surprise, especially on Fridays). To check for this, You should include Freq keyword into Your optimizations. It does not. however, solve the problem of having produced the saddle-point geometry and not the optimum one.

For this, I created this script. We take the coordinates of the imaginary mode or modes, multiply them with a multiplier and add them to the geometry at the stationary point from the calculation. The resulting geometry can be then used to start a new optimization. Yes, the dimensions of the normal mode coordinates is different than the Cartesians used for the geometry itself (because they are normalized by dividing by the square of effective mass). However, there is some hope it will result in some useful initial guess for the geometry.
