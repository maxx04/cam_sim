create_clock -period 100.000 -name clk_200MHZ -waveform {0.000 50.000} [get_ports -filter { NAME =~  "*clk*" && DIRECTION == "IN" }]





