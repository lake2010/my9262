onerror {exit -code 1}
vlib work
vlog -work work Verilog_First.vo
vlog -work work Waveform1.vwf.vt
vsim -novopt -c -t 1ps -L cycloneive_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.Verilog_First_vlg_vec_tst -voptargs="+acc"
vcd file -direction Verilog_First.msim.vcd
vcd add -internal Verilog_First_vlg_vec_tst/*
vcd add -internal Verilog_First_vlg_vec_tst/i1/*
run -all
quit -f
