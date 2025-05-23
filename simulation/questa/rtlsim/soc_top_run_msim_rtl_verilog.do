transcript on
onerror {resume}

if {![info exists DPI_LIBRARY_ELAB]} { set DPI_LIBRARY_ELAB ""} 

if ![file isdirectory verilog_libs] {
	file mkdir verilog_libs
}

###### Libraries for device simulation 

set QSYS_SIMDIR device_sim_scripts
set PRECOMP_DEVICE_LIB_FILE ""
source $QSYS_SIMDIR/mentor/msim_setup.tcl
dev_com

###### End Libraries for device simulation 

vmap pdipss_work ./libraries/work/

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work    +incdir+D:/SOC+D:/SOC/ {D:/SOC/soc_top.sv}
vlog -sv -work work    +incdir+D:/SOC+D:/SOC/ {D:/SOC/dma_axi_slave.sv}
vlog -sv -work work    +incdir+D:/SOC+D:/SOC/ {D:/SOC/clk_gate.sv}
vlog -sv -work work    +incdir+D:/SOC+D:/SOC/ {D:/SOC/dma_axI_slave.sv}
vlog -sv -work work    +incdir+D:/SOC+D:/SOC/ {D:/SOC/dma_core.sv}
vlog -sv -work work    +incdir+D:/SOC+D:/SOC/ {D:/SOC/soc_tb.sv}

vlog -sv -work work    +incdir+D:/SOC+D:/SOC/ {D:/SOC/soc_tb.sv}

if {![info exists ELAB_OPTIONS]} { set ELAB_OPTIONS ""} 
if {![info exists DPI_LIBRARIES_ELAB]} { set DPI_LIBRARIES_ELAB ""} 

if {![info exists logical_libraries]} { set logical_libraries ""} 
set pd_libs ""
foreach library $logical_libraries { append pd_libs " -L $library" }
if {$pd_libs != "" } {
    append pd_libs " -L pdipss_work"
}

eval "vsim -t 1ps $pd_libs -L work -L rtl_work -voptargs=\"+acc\"   $ELAB_OPTIONS $DPI_LIBRARIES_ELAB soc_tb"

add wave *
view structure
view signals
echo Press Enter key to get the command prompt...
run -all
