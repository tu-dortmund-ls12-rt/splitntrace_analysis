#Split’n Trace NVM - Analysis
This repository contains the analysis modules and scripts, mecessary to perform a split'n trace analysis. This analysis requires to have a valid unikraft build directory and a gem5/nvmain2.0 memory trace from exacty this compiled application.

##Building an application for gem5 and split'n trace
*!currently the gem5 port is not upstreamed in unikraft, instructions will appear here once the code is available!*

##Producing the gem5 trace
Once the application is fully compiled, a compiled gem5 / nvmain instance (see the build instructions at [https://github.com/tu-dortmund-ls12-rt/NVMSimulator#compile-gem5](https://github.com/tu-dortmund-ls12-rt/NVMSimulator#compile-gem5)) can be used to execute the application. Use the following command to start the simulation:
```
export M5_PATH=.
gem5/build/ARM/gem5.fast ($realptah gem5/configs/example/fs.py) --bare-metal --disk-image ($realpath fake.iso) --kernel=$(realpath ./build/uk_{your app name}_gem5-arm64.dbg) --mem-type=NVMainMemory --nvmain-config=($realptah nvmain/Config/printtrace.config) --cpu-type=DerivO3CPU --machine-type=VExpress_GEM5_V2 --caches --l2cache --l1i_size='32kB' --l1d_size='8kB' --l2_size='8kB' --dtb-filename=none --mem-size=4GB
```
Be aware that some pathes may look different in your setup. After the application finishes, you will find a file called `nvmain.nvt` in your `nvmain/Config` directory. This is the memory tracefile, which is needed for the next steps.

##Prepare the libraray-memory map
In this repository, you find the file `scan_symbols.sh`. This script scans the build directory of your application for matches of binary symbols in the final compiled binary and the single compiled libraries. The ouput of this script is file `vec.R`, which contains the library-memory map as a R vector.

The script expects 3 arguments, first the allover end address of the main memory, which is `0x80000000` + `4GB` for the previously mentioned simulation call (`0xC0000000`). The second argument is the build folder of your application, where all compiled libraries can be found. The last arguemnt is the DBG file of the compiled kernel image (can be usually found in the build folder).

Hint: If you want to exclude some libraries from the analysis, it is most easy to just remove the `lib***.o` and `lib***.ld.o` in the build folder.

##Produce graphical illustrations
The analysis provides 2 different kinds of scripts, which can be used either for static or dynamic memory analysis, as described in the corresponding paper. Static analysis can be done with the scripts `plot_{,r,rw}.R`, which each provide a function `do_plot_log`, which expects 9 arguemnts, which should be assigned as follows:

1. The memory trace file `nvmain.nvt` from the simulation
2. A name for the figure (which will also be placed on top of the figure)
3. A filename, under which the plot and the legend should be saved
4. A  lower memory bound, where the plot should begin (use `0x0` to begin at the beginning of dram). Keep in mind that DRAM starts at `0x80000000`, so whenever you want to use DRAM adresses here, subtract `0x80000000` first.
5. The upper memory bound where the plot should end
6. The lower limit on the y axis in 10^x (use 0 to begin the axis at 1)
7. The upper limit of the y axis in 10^y
8. `lib_names`, an R vector with the name strings of all investigated libraries in order. This vector is provided under the name `lib_names` in the `vec.R` file from the `scan_symbols.sh` script.
9. `lib_sections`, an R list of vectors, which indicate start and end addresses of memory sections for each libraray in order, the so called library memory map. This list is also provided under the name `lib_sections` in the `vec.R` file.

The script `plot.R` will produce a plot from write acesses only, `plot_r.R` produces a plot from read accesses only and `plot_rw.R` produces a plot from read and write accesses in sum.


Dynamic analysis can be performed with the script `dynamic_plot.R`. This script provides a function `do_dyn_plot_log`, which expects 10 arguments:

1. The filename of the memory trace
2. The filename of the generated figure
3. the lower bound of the analyzed memory region
4. the upper bound of the analyzed memory region
5. the lower bound of the text segment (can be easily found by running `aarch64-linux-gnu-nm ***.dbg | grep __NVM`
6. the upper bound of the text segment
7. The lower bound of the y axis
8. The upper bound of the y axis
9. The `lib_names` name vector
10. The `lib_sections` library memory map

If dynamic anaylsis should be performed on the stack memory, the stack address is printed out during boot of the unikraft kernel.