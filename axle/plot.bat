Rscript plot2.r "gpu/ocl4/timings/all" "Nvidia GPU" 1
Rscript plot2.r "cpu/ocl4/timings/all" "Sandy Bridge CPU" 1
Rscript plot2.r "phi/ocl4/timings/all" "Xeon Phi" 1

Rscript plot2.r "gpu/ocl4/timings/all" "Nvidia GPU (init)" 2
Rscript plot2.r "cpu/ocl4/timings/all" "Sandy Bridge CPU (init)" 2
Rscript plot2.r "phi/ocl4/timings/all" "Xeon Phi (init)" 2

Rscript plot2.r "gpu/ocl4/timings/badcache/time" "Nvidia GPU (bad cache behaviour)" 3
Rscript plot2.r "cpu/ocl4/timings/badcache/time" "Sandy Bridge CPU (bad cache behaviour)" 3
Rscript plot2.r "phi/ocl4/timings/badcache/time" "Xeon Phi (bad cache behaviour)" 3