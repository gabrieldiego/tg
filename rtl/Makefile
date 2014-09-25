RTL=abs_diff.v compute_sad.v frac_search.v filter_half.v filter_quarter.v
VVP=compute_sad frac_search filter_line

compute_sad: compute_sad_tb.v abs_diff.v filter_half.v filter_quarter.v compute_sad.v sad.v
	iverilog -o $@ $^

frac_search: frac_search_tb.v frac_search.v abs_diff.v filter_half.v filter_quarter.v compute_sad.v sad.v smallest_sad.v
	iverilog -o $@ $^

%: %_tb.v $(RTL)
	iverilog -o $@ $^

clean:
	rm -rf $(VVP)
