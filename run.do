#vlib work
vlog -f src_files.list +cover=f +cover -covercells
vsim -coverage -voptargs=+acc work.axi4_top -cover
coverage save -onexit cov.ucdb -du axi4
do wave.do
run -all
vcover report cov.ucdb -details  -all -annotate -output cov_report.txt



