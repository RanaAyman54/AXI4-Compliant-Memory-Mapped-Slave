onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /axi4_top/axi4If/ACLK
add wave -noupdate /axi4_top/axi4If/ARESETn
add wave -noupdate -group write -color Magenta -radix decimal /axi4_top/axi4If/AWADDR
add wave -noupdate -group write -color Magenta -radix unsigned /axi4_top/axi4If/AWLEN
add wave -noupdate -group write -color Magenta /axi4_top/axi4If/AWSIZE
add wave -noupdate -group write -color Magenta /axi4_top/axi4If/AWVALID
add wave -noupdate -group write -color Magenta /axi4_top/axi4If/AWREADY
add wave -noupdate -group write -color Cyan /axi4_top/axi4If/WDATA
add wave -noupdate -group write -color Cyan /axi4_top/axi4If/WVALID
add wave -noupdate -group write -color Cyan /axi4_top/axi4If/WREADY
add wave -noupdate -group write -color Cyan /axi4_top/axi4If/WLAST
add wave -noupdate -group write -color {Medium Spring Green} /axi4_top/axi4If/BREADY
add wave -noupdate -group write -color {Medium Spring Green} /axi4_top/axi4If/BVALID
add wave -noupdate -group write -color {Medium Spring Green} /axi4_top/axi4If/BRESP
add wave -noupdate -radix unsigned /axi4_top/TEST/waddr
add wave -noupdate -radix unsigned /axi4_top/TEST/wlen
add wave -noupdate -group internal /axi4_top/DUT/mem_en
add wave -noupdate -group internal /axi4_top/DUT/mem_we
add wave -noupdate -group internal /axi4_top/DUT/mem_addr
add wave -noupdate -group internal /axi4_top/DUT/mem_wdata
add wave -noupdate -group internal /axi4_top/DUT/mem_rdata
add wave -noupdate -group internal /axi4_top/DUT/write_addr
add wave -noupdate -group internal -radix unsigned /axi4_top/DUT/read_addr
add wave -noupdate -group internal -radix unsigned /axi4_top/DUT/write_burst_len
add wave -noupdate -group internal -radix unsigned /axi4_top/DUT/read_burst_len
add wave -noupdate -group internal -radix unsigned /axi4_top/DUT/write_burst_cnt
add wave -noupdate -group internal -radix unsigned /axi4_top/DUT/read_burst_cnt
add wave -noupdate -group internal /axi4_top/DUT/write_size
add wave -noupdate -group internal /axi4_top/DUT/read_size
add wave -noupdate -group internal /axi4_top/DUT/write_addr_incr
add wave -noupdate -group internal /axi4_top/DUT/read_addr_incr
add wave -noupdate -group internal -color Coral /axi4_top/DUT/write_boundary_cross
add wave -noupdate -group internal -color Coral /axi4_top/DUT/read_boundary_cross
add wave -noupdate -group internal -color Coral /axi4_top/DUT/write_addr_valid
add wave -noupdate -group internal -color Coral /axi4_top/DUT/read_addr_valid
add wave -noupdate -group internal /axi4_top/DUT/write_state
add wave -noupdate -group internal /axi4_top/DUT/read_state
add wave -noupdate -group internal /axi4_top/DUT/mem_rdata_reg
add wave -noupdate /axi4_top/axi4If/ACLK
add wave -noupdate /axi4_top/axi4If/ARESETn
add wave -noupdate -group read -color Magenta -radix unsigned /axi4_top/axi4If/ARADDR
add wave -noupdate -group read -color Magenta -radix unsigned /axi4_top/axi4If/ARLEN
add wave -noupdate -group read -color Magenta /axi4_top/axi4If/ARSIZE
add wave -noupdate -group read -color Magenta /axi4_top/axi4If/ARVALID
add wave -noupdate -group read -color Magenta /axi4_top/axi4If/ARREADY
add wave -noupdate -group read -color Cyan /axi4_top/axi4If/RDATA
add wave -noupdate -group read -color Cyan /axi4_top/axi4If/RRESP
add wave -noupdate -group read -color Cyan /axi4_top/axi4If/RLAST
add wave -noupdate -group read -color Cyan /axi4_top/axi4If/RVALID
add wave -noupdate -group read /axi4_top/axi4If/RREADY
add wave -noupdate -radix unsigned /axi4_top/TEST/rlen
add wave -noupdate /axi4_top/TEST/raddr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {52805000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 155
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 1
configure wave -timelineunits ms
update
WaveRestoreZoom {52731525 ps} {52874525 ps}
