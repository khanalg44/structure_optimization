#!/bin/bash

## Script to optimize the structural constants for any system within DFT

## README to use this script
## Files Needed to run this script
##      1. struct file with original lattice constants with name a0c0.struct
##      2. a0c0.inM file for the relaxation of the internal parameter
##      3. Of course this script optimize.sh
##      4. If you are submitting to cluster then a submit script 
##         where the path to Wien2k executible is defined.

function optimize()
    {
    JOBNAME=fs
    a_orig=`sed -n '4p' a0c0.struct |awk '{print $1}'`
    c_orig=`sed -n '4p' a0c0.struct |awk '{print $3}'`

    #Initialize the calculation once
    cp a0c0.struct ./${JOBNAME}.struct
    init_lapw -b -vxc 13 -numk 100 -rkmax 7 -ecut -6 
    sed -i 's/TOT/FOR/' ${JOBNAME}.in2
    sed -i 's/MSR1 /MSR1a/' ${JOBNAME}.inm
    cp ~/a.inM ${JOBNAME}.inM

    echo '# a c Ene '>>Energy.dat
    for a in -4 -2  ; do
        for c in -4 4 ; do
            case=a${a}c${c}
            # First calculate the new lattice constants
            a_new=`echo ${a_orig}+0.01*${a}*${a_orig}|bc`;
            c_new=`echo ${c_orig}+0.01*${c}*${c_orig}|bc`;
            # copy the original struct file to the new struct file
            cp a0c0.struct ${case}.struct
            # substitute the old lattice constants with new one
            sed -i "s&${a_orig}&${a_new}&g" ${case}.struct
            sed -i "s&${c_orig}&${c_new}&g" ${case}.struct
            # copy the new struct file to be consistent with the Name of the directory in this case JOBNAME
            mv ${case}.struct ${JOBNAME}.struct
            echo $case >>wnohup.dat

            # CHECK MSR1 flag
            msrflag=`less ${JOBNAME}.inm |head -1 |awk '{print $1}'`
            new_flag='MSR1a'
            if [ "$msrflag" != "MSR1a" ]
            then 
                sed -i "s&${msrflag} &${new_flag}&g" ${JOBNAME}.inm
            fi

            ##$WIENROOT/run_lapw -p -ec 0.000001 -cc 0.000001 -i 200 >>wnohup.dat
            $WIENROOT/run_lapw -p -i 100 >>wnohup.dat
            # save scf file for future
            cp ${JOBNAME}.scf ${case}.scf
            #calculate Energy from the scf file I am taking the average of last three iteration
            Ene_sum=`less ./${case}.scf |grep :ENE |awk '{print $9}' |tail -3 |paste -sd+ |bc -l `
            Ene=`echo ${Ene_sum}/3.0 |bc -l `
            # store the energy to a separate file Energy.dat
            echo $a $c ${Ene} >>Energy.dat
            rm ./*broyd*
            done
        done
    }

optimize


## TO DO LIST FOR THIS SCRIPT
# 1. Check the length of a_new and c_new and find if it's equal to original a and c
    # Because wien2k very specific about the character length in struct file.
    # may be I should put a counter here 
    # Remember ${#var} will give you the length of the var
    # So a simple if statement should do the job.
# 2. I am assuming after one job finishes the flag in inm remains MSR1a check it out.
    # That assumption turned out to be false. So I later put a checker for it. 
# 3. More realistic one would be to find the minimum itself instead of having an Energy.dat file
#    But that would take little bit long time.

