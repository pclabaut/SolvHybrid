# Content
This manual and package were written by Clabaut Paul alongside with the original article : Clabaut, P.; Schweitzer, B.; Götz, A. W.; Michel, C.; Steinmann, S. N. Solvation Free Energies and Adsorption Energies at the Metal/Water Interface from Hybrid QM-MM Simulations. J. Chem. Theory Comput. 2020. https://doi.org/10.1021/acs.jctc.0c00632.
. The manual should be used as operational guidelines but should not substitute to the reading of the corresponding article. The package aims at providing an easy-to-use tool to evaluate the adsorption free energy of any molecule on a Pt (111) surface and in water. Two other tools are provided: the first to compute the solvation energy of a whole surface, as used and discused in the article also; and the second to also obtain the adsorption free energy of a molecule on a surface, but whithout using the GAL17 forcefield, and can therefore be used for other surfaces, at the cost of a more limited accuracy.


# Dependancies:
 - Python2
 - Python package: numpy, periodic (pip install numpy; pip install periodic)
 - AMBER17 (patched) or the trunk version of AmberTools (Ensure tleap and its associated file and sander.MPI are in your path)
 - cm5pack (https://comp.chem.umn.edu/cm5pac/) (Ensure cm5pac.exe is in your path) NB: Matrix size "MAT" might need to be increased depending on the system size)
 - VASP with dDsC correction (for input files)

# Adaptation to your queuing system:

 - Adapt Lib/ambersub.j as a classical submission script header for your system
 - In both Function/8_heated_TI.sh and Function/8_heated_TI_bulk.sh, adapt the two lines:
        mpirun -np $COEUR $AMBERHOME/bin/sander.MPI -ng 2 -groupfile ${i}.group
        qsub ambersub.j

# Usage:

Three computation folder are available:
 - SolvHybrid to compute the solvation free energy of a molecule on a Pt (111) surface
 - SolvHybrid_surface to compute the solvation free energy of an entire surface.
 - SolvHybrid_GALfree to compute the solvation free energy of a molecule on a surface without using the GAL17 forcefield


## SolvHybrid and SolvHybrid_GALfree computations:

To use it, copy the provided base folder for the desired calculation as a working directory and replace the example input files by yours.
Three sets of input files (CONTCAR + OUTCAR) generated by VASP (5.X) with the dDsC correction are needed:
  - Bare surface (no adsorbate) 
  - Molecule alone in gas phase
  - Adsorbate on the surface

They should be put in the Input folder with the suffix _surf, _mol, and _ads respectively. Examples are provided in the distributed directory. Please note that the precise formatting of the supplied files is mandatory (including a title line, a "Selective dynamics" line, and direct coordinates).

After having adapted the instructions to your queuing system and provided the inputs, launch the computation from the root of the computation directory with 0_Launcher_TI_surface.sh to conduct the first TI (TI1, see the corresponding paper) and then 0_Launcher_TI_bulk.sh to conduct the second TI (TI2, see the corresponding paper). The two functions are independent and can be use in any order or relaunched independently.

During the computation, the progression can be monitored with :
./Functions/9_Heated_TI_surveilliance.sh TI_surface
or ./Functions/9_Heated_TI_surveilliance.sh TI_bulk
depending on the TI that needs surveillance.

When the computations are over, the results can be extracted with:
./Functions/10_analyse.sh TI_surface 3
and ./Functions/10_analyse.sh TI_bulk 1
Here, "3" is the default scaling factor by which the surface has been multiplied in the in-plane directions to build a supercell. If you changed it (see "How to modify SolvHybrid parameters"), adapt the number here. The molecule alone, in the TI2 transformation is not multiplied, hence the "1".

The results gathered by the program appear in the analyse.dat file.

If needed, the Reset_folder.sh function can reset the whole computation directory, except the input files.

To obtain the complete adsorption free energies, 4 contributions are required, following eq. 8 of the corresponding paper:
 - <img src="https://render.githubusercontent.com/render/math?math=%5CDelta_a%20E%5E%7Bvac%7D_%7Bdft%7D"> that must be manually computed from the OUTCAR files of VASP
 - <img src="https://render.githubusercontent.com/render/math?math=%5CDelta_a%20E%5E%7Bvac%7D_%7BMM%7D"> that can be computed from the MM gas phase computations whose results are in analyse.dat as "SP for X in gas phase".
 - <img src="https://render.githubusercontent.com/render/math?math=%5CDelta_%7B%7BTI%7D_1%7D"> G and <img src="https://render.githubusercontent.com/render/math?math=%5CDelta_%7B%7BTI%7D_2%7D"> G that are displayed in analyse.dat receptively as : "Delta G TI in surface for one molecule in kcal/mol" and "Delta G TI in bulk for one molecule in kcal/mol".
The complete adsorption free energy can then be obtain following the equation as <img src="https://render.githubusercontent.com/render/math?math=%5CDelta_a%20E%5E%7Bvac%7D_%7Bdft%7D%20-%20%5CDelta_a%20E%5E%7Bvac%7D_%7BMM%7D%20%2B%20%5CDelta_%7B%7BTI%7D_2%7D%20G%20-%20%5CDelta_%7B%7BTI%7D_1%7D%20G">

## SolvHybrid_surface

To use it, copy the provided base folder for the desired calculation as a working directory and replace the example input file by yours.
One set of input files (CONTCAR + OUTCAR) generated by VASP (5.X) with the dDsC correction is needed:
  - Bare surface (no adsorbate)

It should be put in the Input folder with the suffix _surf. Example is provided in the distributed directory. Please note that the precise formatting of the supplied file is mandatory (including a title line, a "Selective dynamics" line, and direct coordinates).

After having adapted the instructions to your queuing system and provided the inputs, launch the computation from the root of the computation directory with 0_Launcher_TI.sh to conduct the whole computation.

During the computation, the progression can be monitored with :
./Functions/9_Heated_TI_surveilliance.sh

When the computations are over, the results can be extracted with:
./Functions/10_analyse.sh 3
Here, "3" is the default scaling factor by which the surface has been multiplied to build a supercell. If you changed it (see "How to modify SolvHybrid parameters"), adapt the number here.

The complete solvation energy for the whole surface will be given in analyse.dat. Please note that this indeed the solvation energy of the inputed cell, not the one of the scaled up cell.

If needed, the Reset_folder.sh function can reset the whole computation directory, except the Input files.

# How to modify SolvHybrid parameters

SolvHybrid has been parameterized for reasonable setup and values, but nothing in it is preventing the modification of any MD-related parameters. Also, the parameters have been chosen to get rid of unconverged transformation as much as possible, but if you are confident enough with your system, the parameters can be changed to quicken the computations, or, in contrary, to make them even more carefully. This part is a general guidelines about where in the code you should switch values for fine tuning.

## Scalefactor for the supercell
The scaling of the cell to a supercell is used to ensure that the computation box is larger than the cut-off of the interactions (default amber cut-off: 8A). Then, if your cell is wider or smaller, you can adapt it to compute a box of suitable size.
That is done by changing only $scalefactor in 0_Launcher.sh or 0_Launcher_TI_surface.sh, and not forget to use the right number for the analysis function.

## Temperature
The final temperature of equilibration can be change, keeping in mind that the water model (TIP3P) hasn't been fit to deal with temperature far from room temperature. Also consider that the heating rate will change too since we fix the heating duration (please check next section to modify that).
That is done by changing temp0 in every heating template and equilibration template use. I recommend using ' sed -i 's/temp0 = 300.0/temp0 = XXX/g' Lib/* '

## Heating duration
If the molecule you are studying is specially large, the equilibration of some windows might be difficult. To avoid that, a simple solution is to extend the length of the heating phase to let more time for water to reorganize.
That is done by changing just the length of every heating template. I recommend using ' sed -i 's/100000/XXXXXX/g' Lib/* ', keeping in mind that is is a number of step, each of two fs.

## Equilibration/production time
For the same reasons, a longer equilibration time can be needed, even if, according to our testings, a slower heating leads to a greater reorganization than a longer equilibration. Also, it is possible to use a different portion of the NPT MD as production time for each windows.
The change in equilibration time is done by changing the duration in each equilibration template. I recommend using 'sed -i 's/nstlim = 150000/nstlim = XXX/g' Lib/* ', again, in number of steps of 2fs. The change of production time is done by modifying Functions/10_analyse.sh, changing 2000, that is 10 times the number or 500-step-spaced snapshots that are used to compute the average on $$dV/d\lambda$$ (so 2000 correspond to 200 snapshots, so 100000 steps, so 200 ps). Remember that the same function is used to compute the average for the two different TI.

## Number of windows
The number of windows can be extend to improve, again, the convergence of the transformation, or reduce to gain computation time if you are confident enough. 
That is done by modifying the $windows variable in Functions/8_heated_TI.sh or 8_heated_TI_bulk.sh for any step you like. For linear-spaced windows, adjust the seq command to your liking, while for logarythmic-space windows, you should just replace the two "11" by the desired number of windows.

## Force-field
The force-field and Lennard-Jones values can be tuned just like for any amber computation, via modifying the leap instruction of each function accordingly. Nevertheless, we advocate for the greater caution in doing that, since certain steps of the transformations could become much more difficult to converge.

## Size of the water box
If the thickness of the water layer is insufficient to solvate completely your adsorbed molecule, is is possible to deepen it by changing 0_Launcher_TI_surface.sh, 0_Launcher_TI_bulk.sh or 0_Launcher_TI.sh for SolvHybrid_surface. The number to change is the last argument of ./Functions/3_waterbuilder.sh, that is 30.0 per default for 0_Launcher_TI_surface.sh and 0_Launcher_TI.sh where it is the depth, in angstrom of the layer; or 15.0 for 0_Launcher_TI_bulk.sh, where it is half the size in each direction of the water box that is built around the molecule alone.

## PME computation
The coulombic interactions are done, by default in real space to allow the use of the coulombic correction of the GAL17 forcefield. That can be reverse by removing this option in every template files, but this must absolutely be coupled with the extinction of the GAL17 correction.
This is done by removing the eedmeth option, which I recommend doing with ' sed -i '/eedmeth/d' Lib/*'. To remove the coulombic correction, I recommend using ' sed -s 's/do_coulomb_correction = true,/do_coulomb_correction = false,/g' Lib/* '.

# Structure of the directory
As it might be important to know where to find each information about successive steps of the computation, we propose here a short explanation of the structure of each sub-directory that is present at first or created during the run.

- Functions: 
Where all the scripts required for the computations are present.
- Lib: 
Where all template and parameter files that are used to build computation directories are present.
- Input: 
In it should be the input file, and, after the computation, a file containing cell information and files containing charges information input or output of cm5.
- Adsorbate_files: 
 Contains all intermediate file based on CONTCAR_ads (different format and steps of the file preparation).
- Surface_files: 
Contains all intermediate file based on CONTCAR_surf (different format and steps of the file preparation).
- Molecule_files: 
 Contains all intermediate file based on CONTCAR_mol (different format and steps of the file preparation).
- TI_surface: 
Where the TI1 is conducted, contains a base_files directory with all amber prmtop and inpcrd for the TI computation, and a TI_computation directory, where all steps are present and subdivided in windows, themselves subdivided in minimization, heating and equilibration/production.
- TI_bulk: 
Where the TI2 is conducted, same as TI_surface

# Credits
This package relies on AMBER17, the GAL17 forcefield and cm5pack and some part of the code were re-used from http://ambermd.org/tutorials/advanced/tutorial9/#overview. You are welcome to use it but please aknowledge its usage by properly citing them and the article associated to this work: Clabaut, P.; Schweitzer, B.; Götz, A. W.; Michel, C.; Steinmann, S. N. Solvation Free Energies and Adsorption Energies at the Metal/Water Interface from Hybrid QM-MM Simulations. J. Chem. Theory Comput. 2020. https://doi.org/10.1021/acs.jctc.0c00632.

