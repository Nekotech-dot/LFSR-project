transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/Projects/science_project/prng_based_lfsr/LFSR4bit_on_paper/LFSR4bit_on_paper_verilog {D:/Projects/science_project/prng_based_lfsr/LFSR4bit_on_paper/LFSR4bit_on_paper_verilog/LFSR4bit.v}

