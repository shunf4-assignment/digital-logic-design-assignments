onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+pic_blk_mem -L unisims_ver -L unimacro_ver -L secureip -L xil_defaultlib -L xpm -L blk_mem_gen_v8_3_3 -O5 xil_defaultlib.pic_blk_mem xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {pic_blk_mem.udo}

run -all

endsim

quit -force
