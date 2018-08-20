# structure_optimization
In order to optimize the lattice constants and the whole crystal structure, we usually perform many DFT runs
and plot the energy for each structure.  I find that annoying and time consuming. The goal here is to write
a script which would automatically generate multiple structure files, perform DFT calculation obtain the 
converged value of energy and store it to some file.

# How to Run this code 

Here are the files you need before you use this script

* struct file with original lattice constants with name a0c0.struct
* a0c0.inM file for the relaxation of the internal parameter
* Of course this script optimize.sh
* If you are submitting to cluster then you need a submit script in which the path to Wien2k executible is defined.

# TO DO LIST FOR THIS SCRIPT

* Check the length of a_new and c_new and find if it's equal to original a and c
   >>>
    ** Because wien2k very specific about the character length in struct file.
    
    ** may be I should put a counter here 
    
    ** Remember ${#var} will give you the length of the var
    
    ** So a simple if statement should do the job.
    
    >>>
* I am assuming after one job finishes the flag in inm remains MSR1a check it out.
    ** That assumption turned out to be false. So I later put a checker for it. 
* More realistic one would be to find the minimum itself instead of having an Energy.dat file
    ** But that would take little bit long time.

