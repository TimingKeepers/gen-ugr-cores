#!/bin/bash

mkdir -p doc
wbgen2 -D ./doc/i2c_arb_wb.html -V i2c_arb_wb.vhd -p i2c_arb_pkg.vhd --cstyle struct -C wb_i2c_arb.h --hstyle record --lang vhdl i2c_arbiter_wb.wb 
