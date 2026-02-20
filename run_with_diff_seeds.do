vlib work
vlog -f src_files.list +cover=f +cover -covercells
for {set i 0} {$i < 5} {incr i} {
    set seed [expr {int(rand() * 1000000)}]
    set ucdb_file cov_run${i}.ucdb

    puts "Running simulation $i with random seed : $seed"

    vsim -coverage -voptargs=+acc work.axi4_top -cover +ntb_random_seed=$seed -do "
      coverage save -onexit $ucdb_file -du axi4;
      do wave.do
      run -all;
      #quit -sim 
    " }

vcover merge merged_cov.ucdb cov_run*.ucdb

vcover report merged_cov.ucdb -details -output cov_report_seeds.txt

