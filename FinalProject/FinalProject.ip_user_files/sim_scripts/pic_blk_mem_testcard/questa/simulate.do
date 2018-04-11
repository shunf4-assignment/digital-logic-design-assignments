onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib pic_blk_mem_testcard_opt

do {wave.do}

view wave
view structure
view signals

do {pic_blk_mem_testcard.udo}

run -all

quit -force
