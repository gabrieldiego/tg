# Carregue o arquivo usando (gdb) source debug_cobracat.gdb
# Fonte http://www.chemie.fu-berlin.de/chemnet/use/info/gdb/gdb_16.html

# bt: Imprime pilha
# finish: executa até retornar da função
# disable 2: desativa bp 2
# enable 2: reativa bp 2

file ../bin/TAppEncoderStaticd

rbreak TComInterpolationFilter::filter<

define ccc
  run -c encoder_lowdelay_P_main.cfg -c cobracat64.cfg

define run_cobracat
  run -c encoder_lowdelay_P_main.cfg -c cobracat.cfg

