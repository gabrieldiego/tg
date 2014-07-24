RTL=abs_diff.v compute_sad.v frac_search.v
VVP=abs_diff compute_sad frac_search

%: %_tb.v $(RTL)
	iverilog -o $@ $^

clean:
	rm -rf $(VVP)
