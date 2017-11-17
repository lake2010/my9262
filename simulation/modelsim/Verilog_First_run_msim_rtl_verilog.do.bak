transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+E:/Zircon_Verilog/Verilog_First {E:/Zircon_Verilog/Verilog_First/Verilog_First.v}

vlog -vlog01compat -work work +incdir+E:/Zircon_Verilog/Verilog_First/simulation/modelsim {E:/Zircon_Verilog/Verilog_First/simulation/modelsim/Verilog_First.vt}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  Verilog_First_vlg_tst

add wave *
view structure
view signals
run -all
