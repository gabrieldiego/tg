#!/usr/bin/python

cfgs = ["traffic.cfg"]
qps = [22, 27, 32, 37]

for cfg in cfgs:
  cfg_name = cfg[:-4]
  for qp in qps:
    cfg_summary = cfg_name + "_qp_" + str(qp)
    cfg_summary_new = cfg_summary + "_new.summary"
    cfg_summary_old = cfg_summary + "_old.summary"
    cfg_summary_none = cfg_summary + "_none.summary"

    print "../bin/TAppEncoderStatic -c encoder_lowdelay_P_main.cfg -c", cfg, "-q", qp, "--6x6Blocks=1", "| tee", cfg_summary_new
    print "../bin/TAppEncoderStatic -c encoder_lowdelay_P_main.cfg -c", cfg, "-q", qp, "--6x6Blocks=0", "| tee", cfg_summary_old

    print "./TAppEncoderStatic.none -c encoder_lowdelay_P_main.cfg -c", cfg, "-q", qp, "--6x6Blocks=0", "| tee", cfg_summary_none
