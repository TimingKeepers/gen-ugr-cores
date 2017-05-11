
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/XAPP589_XAPP1241_picxo_v2_4.gtcl]

# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  
  set page_1 [ipgui::add_page $IPINST -name page_1 -parent $IPINST -layout vertical]
  ipgui::add_param $IPINST -name "Component_Name" -parent $page_1
  ipgui::add_static_text $IPINST -name label_0 -text "" -parent $page_1
  set pan0 [ipgui::add_panel $IPINST -name pan0 -parent $page_1 -layout horizontal] 
  set GT_TYPE [ipgui::add_param $IPINST -name "GT_TYPE" -layout horizontal -parent $pan0 -widget comboBox]
  set_property display_name "GT TYPE" $GT_TYPE
  set pan1 [ipgui::add_panel $IPINST -name pan1 -parent $page_1 -layout horizontal] 
  set MODE [ipgui::add_param $IPINST -name "MODE" -layout horizontal -parent $pan1 -widget comboBox]
  set_property display_name "MODE   " $MODE
  
  ipgui::add_dynamic_text $IPINST -name GTY_WARN  -parent $pan0 -tclproc gty_warn
  #ipgui::add_indent $IPINST -parent $page_1
  set pan2 [ipgui::add_panel $IPINST -name pan2 -parent $page_1 -layout vertical]
  set CR [ipgui::add_param $IPINST -name "CLOCK_REGION" -layout horizontal -parent $pan2]
  set_property display_name "Clock Region" $CR
  set_property tooltip "Clock Region where the PICXO will be placed in NO GT mode, format X%Y%" $CR
  ipgui::add_static_text $IPINST -name label_0 -text "" -parent $pan2
  
 # ipgui::add_row $IPINST -parent $page_1
  set groupbox_1 [ipgui::add_group $IPINST -name groupbox_1 -parent $page_1 -layout horizontal]
  set_property display_name "Ports" $groupbox_1
  set DRP [ipgui::add_param $IPINST -name "DRP" -layout horizontal -parent $groupbox_1]
  set ACC_O [ipgui::add_param $IPINST -name "ACC_O" -layout horizontal -parent $groupbox_1]
  set_property display_name "ACC_DATA" $ACC_O
  ipgui::add_row $IPINST -parent $groupbox_1
  set OFFSET [ipgui::add_param $IPINST -name "OFFSET" -layout horizontal -parent $groupbox_1]
  set_property display_name "PPM Control" $OFFSET
  set_property tooltip "Allows direct control of VOLT, enables OFFSET_PPM and OFFSET_EN inputs" $OFFSET
  set HOLD [ipgui::add_param $IPINST -name "HOLD" -layout horizontal -parent $groupbox_1]
  set_property display_name "Hold" $HOLD
  ipgui::add_row $IPINST -parent $groupbox_1
  set DITHER [ipgui::add_param $IPINST -name "DITHER" -layout horizontal -parent $groupbox_1]
  set_property display_name "Dither" $DITHER
  set PRESCALER [ipgui::add_param $IPINST -name "PRESCALER" -layout horizontal -parent $groupbox_1]
  set_property display_name "Pre-Scaler" $PRESCALER
  ipgui::add_static_text $IPINST -name label_0 -text "" -parent $groupbox_1
  
  set groupbox_2 [ipgui::add_group $IPINST -name groupbox_2 -parent $page_1 -layout horizontal]
  set_property display_name "Debug Ports" $groupbox_2
  set ERROR [ipgui::add_param $IPINST -name "ERROR" -layout horizontal -parent $groupbox_2]
  set_property display_name "ERROR_O" $ERROR
  set VOLT [ipgui::add_param $IPINST -name "VOLT" -layout horizontal -parent $groupbox_2]
  set_property display_name "VOLT_O" $VOLT
  set CEs [ipgui::add_param $IPINST -name "CEs" -layout horizontal -parent $groupbox_2]
  set_property display_name "Clock Enables" $CEs
  set_property tooltip "CE_PI_O, CE_DSP_O" $CEs
  set OVF [ipgui::add_param $IPINST -name "OVF" -layout horizontal -parent $groupbox_2]
  set_property display_name "Overflows" $OVF
  set_property tooltip "OVF_PD, OVD_AB, OVF_VOLT, OVF_INT" $OVF
  set DRPDATA_SHORT [ipgui::add_param $IPINST -name "DRPDATA_SHORT" -layout horizontal -parent $groupbox_2]
  set_property display_name "DRPDATA_SHORT_O" $DRPDATA_SHORT
  
  set groupbox_3 [ipgui::add_group $IPINST -name groupbox_3 -parent $page_1 -layout horizontal]
  set_property display_name "Documentation" $groupbox_3
  ipgui::add_row $IPINST -parent $groupbox_3
  ipgui::add_static_text $IPINST -name label_0 -text "For docummentation, please refer to" -parent $groupbox_3
  ipgui::add_dynamic_text $IPINST -name label_0 -tclproc doc -parent $groupbox_3
  #set arch [ipgui::add_image $IPINST -parent $groupbox_2 -name image1 -width 482 -height 300]
  #set_property load_image {./xgui/picxo_arch.JPG} $arch
  #set groupbox_2 [ipgui::add_group $IPINST -name groupbox_2 -parent $page_1]
}

proc doc { PARAM_VALUE.C_FAMILY PARAM_VALUE.MODE} {
   set family [get_property value ${PARAM_VALUE.C_FAMILY}]
   set mode   [get_property value ${PARAM_VALUE.MODE}]
   if {$mode == "PICXO"} {
       if {$family == "virtexu" || $family == "kintexu" || $family == "kintexuplus" || $family == "virtexuplus" || $family == "zynquplus"} {
            return "http://www.xilinx.com/support/documentation/application_notes/xapp1241-vcxo.pdf"
       } elseif {$family == "virtex7" || $family == "kintex7" || $family == "artix7" || $family == "zynq"} {
            return "http://www.xilinx.com/support/documentation/application_notes/xapp589-VCXO.pdf"
       }
   } else { return "http://www.xilinx.com/support/documentation/application_notes/xapp1276.pdf"
   };
}

proc gty_warn {PARAM_VALUE.GT_TYPE} {
    set GT_TYPE [get_property value ${PARAM_VALUE.GT_TYPE}]
    if {$GT_TYPE == "GTY" } {
        return "GTY speed is limited to 16Gb"
     } else {
        return ""
     }
}

proc validate_PARAM_VALUE.OFFSET { PARAM_VALUE.OFFSET } {
    return true
}

proc update_PARAM_VALUE.OFFSET { PARAM_VALUE.OFFSET} {
}

proc update_PARAM_VALUE.OVF { PARAM_VALUE.OVF} {
}

proc validate_PARAM_VALUE.DRP { PARAM_VALUE.GT_TYPE PARAM_VALUE.DRP } {
    return true
}
proc update_PARAM_VALUE.DRPDATA_SHORT { PARAM_VALUE.DRP PARAM_VALUE.DRPDATA_SHORT } {
    set DRP [get_property value ${PARAM_VALUE.DRP}]
    if {$DRP == "true"} {
        set_property value true ${PARAM_VALUE.DRPDATA_SHORT}
        set_property enabled true ${PARAM_VALUE.DRPDATA_SHORT}
     } else {
        set_property value false ${PARAM_VALUE.DRPDATA_SHORT}
        set_property enabled false ${PARAM_VALUE.DRPDATA_SHORT}
     }
}

proc update_PARAM_VALUE.ACC_O { PARAM_VALUE.MODE PARAM_VALUE.GT_TYPE PARAM_VALUE.ACC_O} {
    set GT_TYPE [get_property value ${PARAM_VALUE.GT_TYPE}]
    set mode [get_property value ${PARAM_VALUE.MODE}]
    if {$mode == "FRACXO"} {
        set_property value false ${PARAM_VALUE.ACC_O}
        set_property enabled false ${PARAM_VALUE.ACC_O}
     } elseif {$mode == "PICXO" && $GT_TYPE != "GTX"} {
        set_property value true ${PARAM_VALUE.ACC_O}
        set_property enabled false ${PARAM_VALUE.ACC_O}
     } else {
        set_property enabled true ${PARAM_VALUE.ACC_O}
     }
}

proc update_PARAM_VALUE.DRP { PARAM_VALUE.MODE PARAM_VALUE.GT_TYPE PARAM_VALUE.DRP} {
    set GT_TYPE [get_property value ${PARAM_VALUE.GT_TYPE}]
    set mode [get_property value ${PARAM_VALUE.MODE}]
    if {$GT_TYPE == "GTX"} {
        set_property value true ${PARAM_VALUE.DRP}
        set_property enabled false ${PARAM_VALUE.DRP}
     } elseif {$mode == "FRACXO"} {
        set_property value false ${PARAM_VALUE.DRP}
        set_property enabled false ${PARAM_VALUE.DRP}
     } elseif {$mode == "PICXO"} {
        set_property value true ${PARAM_VALUE.DRP}
        set_property enabled true ${PARAM_VALUE.DRP}
     } else {
        set_property enabled true ${PARAM_VALUE.DRP}
     }
}

proc update_PARAM_VALUE.CLOCK_REGION { PARAM_VALUE.CLOCK_REGION PARAM_VALUE.GT_TYPE } {
    set CLOCK_REGION ${PARAM_VALUE.CLOCK_REGION}
    set GT_TYPE ${PARAM_VALUE.GT_TYPE}
    set values(GT_TYPE) [get_property value $GT_TYPE]
    if { [gen_USERPARAMETER_CLOCK_REGION_ENABLEMENT $values(GT_TYPE)] } {
        set_property enabled true $CLOCK_REGION
    } else {
        set_property enabled false $CLOCK_REGION
    }
}

proc validate_PARAM_VALUE.CLOCK_REGION { PARAM_VALUE.CLOCK_REGION } {
    set device [get_project_property DEVICE]
    set region [get_property value ${PARAM_VALUE.CLOCK_REGION}]
    if { [regexp (X\\d+Y\\d+) $region] } {
        return true
    } else {
        set_property errmsg "Clock Region format must be X0Y0" ${PARAM_VALUE.CLOCK_REGION}
        return false
    }
}

proc update_PARAM_VALUE.C_FAMILY { PARAM_VALUE.C_FAMILY PROJECT_PARAM.ARCHITECTURE } {
    set c_family [string tolower ${PROJECT_PARAM.ARCHITECTURE}]
    set_property value $c_family ${PARAM_VALUE.C_FAMILY}
}


proc validate_PARAM_VALUE.C_FAMILY { PARAM_VALUE.C_FAMILY } {
    return true
}

proc update_PARAM_VALUE.MODE { PARAM_VALUE.MODE PARAM_VALUE.C_FAMILY PARAM_VALUE.GT_TYPE} {
     set c_family [get_property value ${PARAM_VALUE.C_FAMILY}];
     set gt_type [get_property value ${PARAM_VALUE.GT_TYPE}]
    if { [regexp (.+plus) $c_family] == 1} {
        set_property value "PICXO" ${PARAM_VALUE.MODE}; set_property range "PICXO, FRACXO" ${PARAM_VALUE.MODE};
    } else {
         switch $gt_type {
            "GTX"   { set_property value "PICXO" ${PARAM_VALUE.MODE}; set_property range "PICXO" ${PARAM_VALUE.MODE}; }
            "NO_GT" { set_property value "PICXO" ${PARAM_VALUE.MODE}; set_property range "PICXO" ${PARAM_VALUE.MODE}; }
            "GTP"   { set_property value "PICXO" ${PARAM_VALUE.MODE}; set_property range "PICXO" ${PARAM_VALUE.MODE}; }
            "GTH"   { set_property value "PICXO" ${PARAM_VALUE.MODE}; set_property range "PICXO" ${PARAM_VALUE.MODE}; }
            "GTY"   { set_property value "PICXO" ${PARAM_VALUE.MODE}; set_property range "PICXO, FRACXO" ${PARAM_VALUE.MODE}; }
        }
    } 
}

proc validate_PARAM_VALUE.MODE { PARAM_VALUE.C_FAMILY } {
    return true
}

proc update_PARAM_VALUE.GT_TYPE { PARAM_VALUE.GT_TYPE PARAM_VALUE.C_FAMILY} {
    set c_family [get_property value ${PARAM_VALUE.C_FAMILY}]
    set device [get_project_property DEVICE]
    set test {}
    set size {}
    regexp xczu([0-9]+) $device test size;
    switch $c_family {
        "kintex7"     { set_property value "GTX" ${PARAM_VALUE.GT_TYPE}; set_property range "GTX, NO_GT" ${PARAM_VALUE.GT_TYPE}; }
        "kintexu"     { set_property value "GTH" ${PARAM_VALUE.GT_TYPE}; if {[regexp (xcku095) $device] == 1} {set_property range "GTH, GTY, NO_GT" ${PARAM_VALUE.GT_TYPE};} else {set_property range "GTH, NO_GT" ${PARAM_VALUE.GT_TYPE};} }
        "artix7"      { set_property value "GTP" ${PARAM_VALUE.GT_TYPE}; set_property range "GTP, NO_GT" ${PARAM_VALUE.GT_TYPE}; }
        "virtex7"     { set_property value "GTH" ${PARAM_VALUE.GT_TYPE}; set_property range "GTX, GTH, NO_GT" ${PARAM_VALUE.GT_TYPE}; }
        "virtexu"     { set_property value "GTH" ${PARAM_VALUE.GT_TYPE}; set_property range "GTH, GTY, NO_GT" ${PARAM_VALUE.GT_TYPE}; }
        "zynq"        { set_property value "GTX" ${PARAM_VALUE.GT_TYPE}; set_property range "GTP, GTX, NO_GT" ${PARAM_VALUE.GT_TYPE}; }
        "zynquplus"   { set_property value "GTH" ${PARAM_VALUE.GT_TYPE}; 
                        if { [expr $size < 10 || $size == 15] } {
                                    set_property range "GTH, NO_GT" ${PARAM_VALUE.GT_TYPE}
                        } else {    set_property range "GTH, GTY, NO_GT" ${PARAM_VALUE.GT_TYPE}
                        }; 
                      }
        "kintexuplus" { set_property value "GTH" ${PARAM_VALUE.GT_TYPE}; set_property range "GTH, GTY, NO_GT" ${PARAM_VALUE.GT_TYPE}; }
        "virtexuplus" { set_property value "GTY" ${PARAM_VALUE.GT_TYPE}; set_property range "GTY, NO_GT" ${PARAM_VALUE.GT_TYPE}; }
        default       { set_property value "GTH" ${PARAM_VALUE.GT_TYPE}; set_property range "GTP, GTX, GTH, GTY, NO_GT" ${PARAM_VALUE.GT_TYPE}; }
    }    
}

proc validate_PARAM_VALUE.GT_TYPE { PARAM_VALUE.C_FAMILY PARAM_VALUE.GT_TYPE PROJECT_PARAM.ARCHITECTURE} {
    set c_family [get_property value ${PARAM_VALUE.C_FAMILY}]
    set gt_type [get_property value ${PARAM_VALUE.GT_TYPE}]
    switch $c_family {
        "kintex7"     { if {$gt_type == "GTX" || $gt_type == "NO_GT" } {return true} else { set_property errmsg "$gt_type does not exist in $c_family"  ${PARAM_VALUE.GT_TYPE}; return false} }
        "kintexu"     { if {$gt_type == "GTH" || $gt_type == "NO_GT" || $gt_type == "GTY" } {return true} else { set_property errmsg "$gt_type does not exist in $c_family"  ${PARAM_VALUE.GT_TYPE}; return false} }
        "kintexuplus" { if {$gt_type == "GTH" || $gt_type == "NO_GT" || $gt_type == "GTY" || $gt_type == "FRACXO"} {return true} else { set_property errmsg "$gt_type does not exist in $c_family"  ${PARAM_VALUE.GT_TYPE}; return false} }
        "artix7"      { if {$gt_type == "GTP" || $gt_type == "NO_GT" } {return true} else { set_property errmsg "$gt_type does not exist in $c_family"  ${PARAM_VALUE.GT_TYPE}; return false} }
        "virtex7"     { if {$gt_type == "GTX" || $gt_type == "NO_GT" || $gt_type == "GTH"} {return true} else { set_property errmsg "$gt_type does not exist in $c_family"  ${PARAM_VALUE.GT_TYPE}; return false} }
        "virtexu"     { if {$gt_type == "GTH" || $gt_type == "NO_GT" || $gt_type == "GTY" || $gt_type == "FRACXO"} {return true} else { set_property errmsg "$gt_type does not exist in $c_family"  ${PARAM_VALUE.GT_TYPE}; return false} }
        "virtexuplus" { if {$gt_type == "GTY" || $gt_type == "NO_GT" || $gt_type == "FRACXO"} {return true} else { set_property errmsg "$gt_type does not exist in $c_family"  ${PARAM_VALUE.GT_TYPE}; return false} }
        "zynquplus"   { if {$gt_type == "GTH" || $gt_type == "NO_GT" || $gt_type == "GTY" || $gt_type == "FRACXO"} {return true} else { set_property errmsg "$gt_type does not exist in $c_family"  ${PARAM_VALUE.GT_TYPE}; return false} }
        "zynq"        { if {$gt_type == "GTP" || $gt_type == "NO_GT" || $gt_type == "GTX"} {return true} else { set_property errmsg "$gt_type does not exist in $c_family"  ${PARAM_VALUE.GT_TYPE}; return false} }
        default       {return false}
    }    
}

proc update_MODELPARAM_VALUE.MODE { MODELPARAM_VALUE.MODE PARAM_VALUE.MODE } {
#    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.MODE}] ${MODELPARAM_VALUE.MODE}
}

proc update_MODELPARAM_VALUE.GT_TYPE { MODELPARAM_VALUE.GT_TYPE PARAM_VALUE.GT_TYPE } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.GT_TYPE}] ${MODELPARAM_VALUE.GT_TYPE}
}

proc update_MODELPARAM_VALUE.CLOCK_REGION { MODELPARAM_VALUE.CLOCK_REGION PARAM_VALUE.CLOCK_REGION } {
    # Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
    set_property value [get_property value ${PARAM_VALUE.CLOCK_REGION}] ${MODELPARAM_VALUE.CLOCK_REGION}
}

