REM Rscript plot2.r [path to times : string] [plot name : string] [positions file path : string] [y-axix upper bound : float]


REM Regular, all sizes and all configurations
Rscript plot2.r "gpu/ocl4/timings/all" "Nvidia GPU" 1 6.5
Rscript plot2.r "cpu/ocl4/timings/all" "Sandy Bridge CPU" 1 6.5
Rscript plot2.r "phi/ocl4/timings/all" "Xeon Phi" 1 6.5


REM zoom!
REM Rscript plot2.r "gpu/ocl4/timings/all" "Nvidia GPU (zoom)" 1 1.0
REM Rscript plot2.r "gpu/ocl4/timings/all" "Nvidia GPU (extra zoom)" 1 0.25
REM Rscript plot2.r "cpu/ocl4/timings/all" "Sandy Bridge CPU (zoom)" 1 1.0
REM Rscript plot2.r "cpu/ocl4/timings/all" "Sandy Bridge CPU (extra zoom)" 1 0.25
REM Rscript plot2.r "phi/ocl4/timings/all" "Xeon Phi (zoom)" 1 0.1
REM Rscript plot2.r "phi/ocl4/timings/all" "Xeon Phi (extra zoom)" 1 0.25


REM Regular (for bad cache comparisons)
REM Rscript plot2.r "gpu/ocl4/timings/all" "Nvidia GPU (init)" 2 6.5
REM Rscript plot2.r "cpu/ocl4/timings/all" "Sandy Bridge CPU (init)" 2 3.0
REM Rscript plot2.r "phi/ocl4/timings/all" "Xeon Phi (init)" 2 0.1


REM Bad Cache!
REM Rscript plot2.r "gpu/ocl4/timings/badcache/time" "Nvidia GPU (bad cache behaviour)" 3 6.5
REM Rscript plot2.r "cpu/ocl4/timings/badcache/time" "Sandy Bridge CPU (bad cache behaviour)" 3 3.0
REM Rscript plot2.r "phi/ocl4/timings/badcache/time" "Xeon Phi (bad cache behaviour)" 3 0.1


REM Regular, for all different sizes
Rscript plot3.r positions.txt 6.5
