onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib bmp_cluster_blkmem_opt

do {wave.do}

view wave
view structure
view signals

do {bmp_cluster_blkmem.udo}

run -all

quit -force
