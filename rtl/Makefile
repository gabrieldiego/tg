RTL=abs_diff.v compute_sad.v frac_search.v filter_half.v filter_quarter.v
VVP=abs_diff compute_sad frac_search filter_line

%: %_tb.v $(RTL)
	iverilog -o $@ $^

clean:
	rm -rf $(VVP)
