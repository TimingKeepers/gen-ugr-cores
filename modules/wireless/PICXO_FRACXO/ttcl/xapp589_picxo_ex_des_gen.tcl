proc lremove {listVariable value} {
    foreach v $value {
    regsub $v $listVariable "" listVariable 
    }
    return $listVariable
};

proc xapp589_picxo_ex_des_gen {srcIpDir} {
    #set_property source_mgmt_mode None [current_project];
    puts "Running xapp589_picxo_ex_des_gen $srcIpDir";
    set no_gt 0;
    set mode [get_property CONFIG.MODE [get_ips -filter {IPDEF =~ *PICXO*}]];
    set gt_type [get_property CONFIG.GT_TYPE [get_ips -filter {IPDEF =~ *PICXO*}]];
    set ip_file [get_property IP_FILE [get_ips -filter {IPDEF =~ *PICXO*}]];
    set ip_name [get_property NAME [get_ips -filter {IPDEF =~ *PICXO*}]];
    set ip_container [get_property core_container [get_files $ip_file]]
    set family [get_property FAMILY [get_parts [get_property PART [current_project]]]];
    switch $family {
        kintex7         {set board KC705; if {$gt_type == "NO_GT"} {set gt_type GTX; set no_gt 1; }}
        zynq            {set board ZC706; if {$gt_type == "NO_GT"} {set gt_type GTX; set no_gt 1; }}
        artix7          {set board AC701; if {$gt_type == "NO_GT"} {set gt_type GTP; set no_gt 1; }}
        virtex7         {if {$gt_type == "GTX"} {set board KC705; send_msg_id {PICXO-301} {WARNING} "Example design will be generated with xdc files targeting KC705";} elseif {$gt_type == "GTH"} {set board VC709}}
        kintexu         {if {$gt_type == "GTH"} {set board KCU105; set gt_type GTH_ultrascale;} elseif {$gt_type == "GTY"} {set board VCU108; send_msg_id {PICXO-300} {WARNING} "Example design will be generated with xdc files targeting VCU108";} }
        virtexues2      {if {$gt_type == "GTY"} {set board VCU108;}; if {$gt_type == "GTH"} {set board VCU108; set gt_type "GTH_ultrascale";}}
        virtexu         {if {$gt_type == "GTY"} {set board VCU108;}; if {$gt_type == "GTH"} {set board VCU108; set gt_type "GTH_ultrascale";}}
        kintexuplus     {if {$gt_type == "GTY"} {set gt_type GTY_plus}; if {$gt_type == "GTH"} {set gt_type GTH_plus}}
        kintexupluses1  {if {$gt_type == "GTY"} {set gt_type GTY_plus}; if {$gt_type == "GTH"} {set gt_type GTH_plus}}
        zynqupluses1    {if {$gt_type == "GTY"} {set gt_type GTY_plus}; if {$gt_type == "GTH"} {set gt_type GTH_plus; set board ZCU102}}
        zynquplus       {if {$gt_type == "GTY"} {set gt_type GTY_plus}; if {$gt_type == "GTH"} {set gt_type GTH_plus; set board ZCU102}}
        virtexuplus     {if {$gt_type == "GTY"} {set gt_type GTY_plus}}
        virtexupluses1  {if {$gt_type == "GTY"} {set gt_type GTY_plus}}
        default         {puts "Board selection error"}
    };
    switch $family {
        kintex7      {set top [list GTX_picxo_example_top];}
        zynq         {set top [list GTX_picxo_example_top];}
        artix7       {set top [list GTP_picxo_example_top];}
        artix7       {set top [list GTP_picxo_example_top];}
        virtex7      {if {$gt_type == "GTX"} {set top [list GTX_picxo_example_top];}; 
                      if {$gt_type == "GTH"} {set top [list GTH_gtwizard_v2_4_exdes];};
                     }
        kintexu      {set top [list gtwizard_ultrascale_0_example_top];}
        virtexues2   {if {$gt_type == "GTY"} {set top [list gtwizard_ultrascale_0_example_top];};
                      if {$gt_type == "GTH_ultrascale"} {set top [list gtwizard_ultrascale_0_example_top];};
                     }
        virtexu      {if {$gt_type == "GTY"} {set top [list gtwizard_ultrascale_0_example_top];};
                      if {$gt_type == "GTH_ultrascale"} {set top [list gtwizard_ultrascale_0_example_top];};
                     }
        zynqupluses1 {set top [list gtwizard_ultrascale_0_example_top];}           
        zynquplus    {set top [list gtwizard_ultrascale_0_example_top];}           
        default      {puts "ERROR: Device is beta, example design no supported"; return 1}
    };
    
    
    #puts "TOP\n\n [get_files -filter "IMPORTED_FROM == $top"]";
    set ip_sub_files [get_files -filter "PARENT_COMPOSITE_FILE == $ip_file"];
    lappend ip_sub_files [get_files -quiet $ip_container]
    #puts "ip_sub_files\n\n\n [join $ip_sub_files \n]";
    #set remove_file_list [get_files -filter "IMPORTED_FROM !~ *$board* && IMPORTED_FROM !~ [file join $srcIpDir example_design/$gt_type]/* && IMPORTED_FROM !~ [file join $srcIpDir]/*.xci && IMPORTED_FROM != $top"];
    set remove_file_list [get_files -filter "IMPORTED_FROM !~ *$board* && IMPORTED_FROM !~ [file join $srcIpDir example_design/$gt_type]/* && IMPORTED_FROM !~ [file join $srcIpDir]/*.xci"];
    set remove_file_list [lremove $remove_file_list $ip_sub_files];
    #puts "REMOVE FILE\n\n\n\n [join $remove_file_list \n]";
    remove_files $remove_file_list;
    set_property top $top [current_fileset];
    set_property -quiet file_type {Verilog Header} [get_files -quiet gtwizard_ultrascale_0_example_wrapper_functions.v]
    #set_property source_mgmt_mode All [current_project]
    update_compile_order -fileset sources_1

    # create PICXO ILA
    create_ip -quiet -name ila -vendor xilinx.com -library ip -module_name picxo_ila;
        set_property -quiet -dict [list \
        CONFIG.C_ADV_TRIGGER         {false}\
        CONFIG.C_DATA_DEPTH          {8192}\
        CONFIG.C_ENABLE_ILA_AXI_MON  {false}\
        CONFIG.C_EN_STRG_QUAL        {1}\
        CONFIG.C_INPUT_PIPE_STAGES   {2}\
        CONFIG.C_MONITOR_TYPE        {Native}\
        CONFIG.ALL_PROBE_SAME_MU     {true}\
        CONFIG.ALL_PROBE_SAME_MU_CNT {2}\
        CONFIG.C_NUM_MONITOR_SLOTS   {1}\
        CONFIG.C_NUM_OF_PROBES       {10}\
        CONFIG.C_PROBE0_MU_CNT       {2}\
        CONFIG.C_PROBE0_WIDTH        {21}\
        CONFIG.C_PROBE1_MU_CNT       {2}\
        CONFIG.C_PROBE1_WIDTH        {22}\
        CONFIG.C_PROBE2_MU_CNT       {2}\
        CONFIG.C_PROBE2_WIDTH        {8}\
        CONFIG.C_PROBE3_MU_CNT       {2}\
        CONFIG.C_PROBE3_WIDTH        {1}\
        CONFIG.C_PROBE4_MU_CNT       {2}\
        CONFIG.C_PROBE4_WIDTH        {1}\
        CONFIG.C_PROBE5_MU_CNT       {2}\
        CONFIG.C_PROBE5_WIDTH        {1}\
        CONFIG.C_PROBE6_MU_CNT       {2}\
        CONFIG.C_PROBE6_WIDTH        {1}\
        CONFIG.C_PROBE7_MU_CNT       {2}\
        CONFIG.C_PROBE7_WIDTH        {1}\
        CONFIG.C_PROBE8_MU_CNT       {2}\
        CONFIG.C_PROBE8_WIDTH        {1}\
        CONFIG.C_PROBE9_MU_CNT       {2}\
        CONFIG.C_PROBE9_WIDTH        {1}\
    ] [get_ips picxo_ila];

    # create PICXO VIO
    create_ip -quiet -name vio -vendor xilinx.com -library ip -module_name picxo_vio;
    set_property -quiet -dict [list \
        CONFIG.C_EN_PROBE_IN_ACTIVITY   {0}\
        CONFIG.C_EN_SYNCHRONIZATION     {1}\
        CONFIG.C_NUM_PROBE_IN           {0}\
        CONFIG.C_NUM_PROBE_OUT          {12}\
        CONFIG.C_PROBE_OUT0_WIDTH       {5}\
        CONFIG.C_PROBE_OUT0_INIT_VAL    {0x08}\
        CONFIG.C_PROBE_OUT1_WIDTH       {5}\
        CONFIG.C_PROBE_OUT1_INIT_VAL    {0x10}\
        CONFIG.C_PROBE_OUT2_WIDTH       {16}\
        CONFIG.C_PROBE_OUT2_INIT_VAL    {0x0200}\
        CONFIG.C_PROBE_OUT3_WIDTH       {16}\
        CONFIG.C_PROBE_OUT3_INIT_VAL    {0x0200}\
        CONFIG.C_PROBE_OUT4_WIDTH       {4}\
        CONFIG.C_PROBE_OUT4_INIT_VAL    {0x4}\
        CONFIG.C_PROBE_OUT5_WIDTH       {16}\
        CONFIG.C_PROBE_OUT5_INIT_VAL    {0x03ff}\
        CONFIG.C_PROBE_OUT6_WIDTH       {22}\
        CONFIG.C_PROBE_OUT6_INIT_VAL    {0x0}\
        CONFIG.C_PROBE_OUT7_WIDTH       {1}\
        CONFIG.C_PROBE_OUT7_INIT_VAL    {0x0}\
        CONFIG.C_PROBE_OUT8_WIDTH       {1}\
        CONFIG.C_PROBE_OUT8_INIT_VAL    {0x0}\
        CONFIG.C_PROBE_OUT9_WIDTH       {1}\
        CONFIG.C_PROBE_OUT9_INIT_VAL    {0x0}\
        CONFIG.C_PROBE_OUT10_WIDTH      {1}\
        CONFIG.C_PROBE_OUT10_INIT_VAL   {0x0}\
        CONFIG.C_PROBE_OUT11_WIDTH      {1}\
        CONFIG.C_PROBE_OUT11_INIT_VAL   {0x0}\
    ] [get_ips picxo_vio];

    # NO GT create PICXO with GT
    if {$no_gt ==  1} {
        create_ip -name PICXO_FRACXO -vendor xilinx.com -library ip -module_name $ip_name\_with_gt
        set_property -dict [list CONFIG.GT_TYPE "$gt_type"] [get_ips $ip_name\_with_gt]
    }
    
    # Artix-7
    if {$family ==  "artix7"} {
        # create clk_wiz for AC701
        create_ip -quiet -name clk_wiz -vendor xilinx.com -library ip -module_name clk_wiz_0;
        set_property -quiet -dict [list \
            CONFIG.CALC_DONE                     {empty}\
            CONFIG.CDDCDONE_PORT                 {cddcdone}\
            CONFIG.CDDCREQ_PORT                  {cddcreq}\
            CONFIG.CLKFB_IN_N_PORT               {clkfb_in_n}\
            CONFIG.CLKFB_IN_PORT                 {clkfb_in}\
            CONFIG.CLKFB_IN_P_PORT               {clkfb_in_p}\
            CONFIG.CLKFB_IN_SIGNALING            {SINGLE}\
            CONFIG.CLKFB_OUT_N_PORT              {clkfb_out_n}\
            CONFIG.CLKFB_OUT_PORT                {clkfb_out}\
            CONFIG.CLKFB_OUT_P_PORT              {clkfb_out_p}\
            CONFIG.CLKFB_STOPPED_PORT            {clkfb_stopped}\
            CONFIG.CLKIN1_JITTER_PS              {50.0}\
            CONFIG.CLKIN1_UI_JITTER              {0.010}\
            CONFIG.CLKIN2_JITTER_PS              {100.0}\
            CONFIG.CLKIN2_UI_JITTER              {0.010}\
            CONFIG.CLKOUT1_DRIVES                {BUFG}\
            CONFIG.CLKOUT1_JITTER                {0.0}\
            CONFIG.CLKOUT1_PHASE_ERROR           {0.0}\
            CONFIG.CLKOUT1_REQUESTED_DUTY_CYCLE  {50.000}\
            CONFIG.CLKOUT1_REQUESTED_OUT_FREQ    {50}\
            CONFIG.CLKOUT1_REQUESTED_PHASE       {0.000}\
            CONFIG.CLKOUT1_SEQUENCE_NUMBER       {1}\
            CONFIG.CLKOUT1_USED                  {true}\
            CONFIG.PRIM_IN_FREQ                  {200}\
            CONFIG.PRIM_SOURCE                   {No_buffer}\
        ] [get_ips clk_wiz_0];
        
        # create data VIO
        create_ip -quiet -name vio -vendor xilinx.com -library ip -module_name data_vio;
        set_property -quiet -dict [list\
            CONFIG.C_NUM_PROBE_IN     {2}\
            CONFIG.C_NUM_PROBE_OUT    {2}\
            CONFIG.C_PROBE_IN0_WIDTH  {32}\
            CONFIG.C_PROBE_IN1_WIDTH  {32}\
            CONFIG.C_PROBE_OUT0_WIDTH {32}\
            CONFIG.C_PROBE_OUT1_WIDTH {32}\
        ] [get_ips data_vio];
    };

    # Virtex-7
    if {$family ==  "virtex7"} {
        # create data VIO
        create_ip -quiet -name vio -vendor xilinx.com -library ip -module_name data_vio;
        set_property -quiet -dict [list\
            CONFIG.C_NUM_PROBE_IN     {2}\
            CONFIG.C_NUM_PROBE_OUT    {2}\
            CONFIG.C_PROBE_IN0_WIDTH  {32}\
            CONFIG.C_PROBE_IN1_WIDTH  {32}\
            CONFIG.C_PROBE_OUT0_WIDTH {32}\
            CONFIG.C_PROBE_OUT1_WIDTH {32}\
        ] [get_ips data_vio]
    };

    # GTH Ultrascale
    if {$gt_type == "GTH_ultrascale" } {
        # GT VIO
        create_ip -quiet -name vio -vendor xilinx.com -library ip -module_name gtwizard_ultrascale_0_vio_0;
        set_property -dict [list \
            CONFIG.C_NUM_PROBE_IN           {8}\
            CONFIG.C_NUM_PROBE_OUT          {9}\
            CONFIG.C_PROBE_IN0_WIDTH        {1}\
            CONFIG.C_PROBE_IN1_WIDTH        {1}\
            CONFIG.C_PROBE_IN2_WIDTH        {1}\
            CONFIG.C_PROBE_IN3_WIDTH        {4}\
            CONFIG.C_PROBE_OUT0_WIDTH       {1}\
            CONFIG.C_PROBE_OUT1_WIDTH       {1}\
            CONFIG.C_PROBE_OUT2_WIDTH       {1}\
            CONFIG.C_PROBE_OUT3_WIDTH       {1}\
            CONFIG.C_PROBE_OUT4_WIDTH       {1}\
            CONFIG.C_PROBE_OUT5_WIDTH       {1}\
            CONFIG.C_PROBE_OUT6_WIDTH       {5}\
            CONFIG.C_PROBE_OUT7_WIDTH       {5}\
            CONFIG.C_PROBE_OUT8_WIDTH       {5}\
            CONFIG.C_PROBE_OUT8_INIT_VAL    {0x0C}\
        ] [get_ips gtwizard_ultrascale_0_vio_0];
    
        # GT Wizard
        set gt_wiz_ip [create_ip -name gtwizard_ultrascale -vendor xilinx.com -library ip -module_name gtwizard_ultrascale_0];
        set_property -quiet -dict [list \
            CONFIG.ENABLE_OPTIONAL_PORTS                 {txdiffctrl_in txpippmen_in txpippmovrden_in txpippmpd_in txpippmsel_in txpippmstepsize_in txpostcursor_in txprecursor_in}\
            CONFIG.GT_TYPE                               {GTH}\
            CONFIG.LOCATE_COMMON                         {CORE}\
            CONFIG.LOCATE_RESET_CONTROLLER               {CORE}\
            CONFIG.LOCATE_RX_BUFFER_BYPASS_CONTROLLER    {CORE}\
            CONFIG.LOCATE_RX_USER_CLOCKING               {CORE}\
            CONFIG.LOCATE_TX_BUFFER_BYPASS_CONTROLLER    {CORE}\
            CONFIG.LOCATE_TX_USER_CLOCKING               {CORE}\
            CONFIG.LOCATE_USER_DATA_WIDTH_SIZING         {CORE}\
            CONFIG.TX_LINE_RATE                          {10.3125}\
            CONFIG.RX_LINE_RATE                          {10.3125}\
            CONFIG.FREERUN_FREQUENCY                     {125}\
            CONFIG.TX_REFCLK_FREQUENCY                   {156.25}\
            CONFIG.RX_REFCLK_FREQUENCY                   {156.25}\
            CONFIG.RX_JTOL_FC                            {6.1862627}\
            CONFIG.TXPROGDIV_FREQ_VAL                    {322.265625}\
            ] [get_ips gtwizard_ultrascale_0];
    };

    # GTY Ultrascale
    if {$gt_type == "GTY" } {
        # GT VIO
        create_ip -quiet -name vio -vendor xilinx.com -library ip -module_name gtwizard_ultrascale_0_vio_0;
        set_property -dict [list \
            CONFIG.C_NUM_PROBE_IN           {8}\
            CONFIG.C_NUM_PROBE_OUT          {9}\
            CONFIG.C_PROBE_IN0_WIDTH        {1}\
            CONFIG.C_PROBE_IN1_WIDTH        {1}\
            CONFIG.C_PROBE_IN2_WIDTH        {1}\
            CONFIG.C_PROBE_IN3_WIDTH        {4}\
            CONFIG.C_PROBE_OUT0_WIDTH       {1}\
            CONFIG.C_PROBE_OUT1_WIDTH       {1}\
            CONFIG.C_PROBE_OUT2_WIDTH       {1}\
            CONFIG.C_PROBE_OUT3_WIDTH       {1}\
            CONFIG.C_PROBE_OUT4_WIDTH       {1}\
            CONFIG.C_PROBE_OUT5_WIDTH       {1}\
            CONFIG.C_PROBE_OUT6_WIDTH       {5}\
            CONFIG.C_PROBE_OUT7_WIDTH       {5}\
            CONFIG.C_PROBE_OUT8_WIDTH       {5}\
            CONFIG.C_PROBE_OUT8_INIT_VAL    {0x0C}\
        ] [get_ips gtwizard_ultrascale_0_vio_0];
        
        # GT Wizard
        create_ip -name gtwizard_ultrascale -vendor xilinx.com -library ip -module_name gtwizard_ultrascale_0;
        set_property -dict [list \
            CONFIG.GT_TYPE                                                             {GTY}\
            CONFIG.LOCATE_COMMON                                                       {CORE}\
            CONFIG.LOCATE_RESET_CONTROLLER                                             {CORE}\
            CONFIG.LOCATE_RX_BUFFER_BYPASS_CONTROLLER                                  {CORE}\
            CONFIG.LOCATE_RX_USER_CLOCKING                                             {CORE}\
            CONFIG.LOCATE_TX_BUFFER_BYPASS_CONTROLLER                                  {CORE}\
            CONFIG.LOCATE_TX_USER_CLOCKING                                             {CORE}\
            CONFIG.LOCATE_USER_DATA_WIDTH_SIZING                                       {CORE}\
            CONFIG.FREERUN_FREQUENCY                                                   {125}\
            CONFIG.TX_REFCLK_FREQUENCY                                                 {156.25}\
            CONFIG.RX_REFCLK_FREQUENCY                                                 {156.25}\
        ] [get_ips gtwizard_ultrascale_0];
        
        if {$mode == "PICXO"} {
            set_property -dict [list \
            CONFIG.ENABLE_OPTIONAL_PORTS                                               { txdiffctrl_in  txpostcursor_in txprecursor_in txpippmen_in txpippmovrden_in txpippmpd_in txpippmsel_in txpippmstepsize_in}\
            ] [get_ips gtwizard_ultrascale_0];
        } elseif {$mode == "FRACXO"} {
            set_property -dict [list \
            CONFIG.ENABLE_OPTIONAL_PORTS                                               { txdiffctrl_in  txpostcursor_in txprecursor_in sdm0data_in sdm0reset_in sdm0width_in }\
            CONFIG.TX_QPLL_FRACN_NUMERATOR                                             {131477}\
            CONFIG.RX_QPLL_FRACN_NUMERATOR                                             {131477}\
            CONFIG.TX_REFCLK_FREQUENCY                                                 {257.7620003}\
            CONFIG.RX_REFCLK_FREQUENCY                                                 {257.7620003}\
            ] [get_ips gtwizard_ultrascale_0];
            set_property -quiet -dict [list\
                CONFIG.C_PROBE_OUT10_WIDTH      {6}\
                CONFIG.C_PROBE_OUT10_INIT_VAL   {0x00}\
            ] [get_ips picxo_vio];
        }
   };
   
    # GTH Plus
    if {$gt_type == "GTH_plus" } {
        # GT VIO
        create_ip -quiet -name vio -vendor xilinx.com -library ip -module_name gtwizard_ultrascale_0_vio_0;
        set_property -dict [list \
            CONFIG.C_NUM_PROBE_IN           {8}\
            CONFIG.C_NUM_PROBE_OUT          {9}\
            CONFIG.C_PROBE_IN0_WIDTH        {1}\
            CONFIG.C_PROBE_IN1_WIDTH        {1}\
            CONFIG.C_PROBE_IN2_WIDTH        {1}\
            CONFIG.C_PROBE_IN3_WIDTH        {4}\
            CONFIG.C_PROBE_OUT0_WIDTH       {1}\
            CONFIG.C_PROBE_OUT1_WIDTH       {1}\
            CONFIG.C_PROBE_OUT2_WIDTH       {1}\
            CONFIG.C_PROBE_OUT3_WIDTH       {1}\
            CONFIG.C_PROBE_OUT4_WIDTH       {1}\
            CONFIG.C_PROBE_OUT5_WIDTH       {1}\
            CONFIG.C_PROBE_OUT6_WIDTH       {5}\
            CONFIG.C_PROBE_OUT7_WIDTH       {5}\
            CONFIG.C_PROBE_OUT8_WIDTH       {6}\
            CONFIG.C_PROBE_OUT8_INIT_VAL    {0x0C}\
        ] [get_ips gtwizard_ultrascale_0_vio_0];
    
        # GT Wizard
        set gt_wiz_ip [create_ip -name gtwizard_ultrascale -vendor xilinx.com -library ip -module_name gtwizard_ultrascale_0];
        set_property -quiet -dict [list \
            CONFIG.GT_TYPE                               {GTH}\
            CONFIG.LOCATE_COMMON                         {CORE}\
            CONFIG.LOCATE_RESET_CONTROLLER               {CORE}\
            CONFIG.LOCATE_RX_BUFFER_BYPASS_CONTROLLER    {CORE}\
            CONFIG.LOCATE_RX_USER_CLOCKING               {CORE}\
            CONFIG.LOCATE_TX_BUFFER_BYPASS_CONTROLLER    {CORE}\
            CONFIG.LOCATE_TX_USER_CLOCKING               {CORE}\
            CONFIG.LOCATE_USER_DATA_WIDTH_SIZING         {CORE}\
            CONFIG.TX_LINE_RATE                          {10.3125}\
            CONFIG.RX_LINE_RATE                          {10.3125}\
            CONFIG.FREERUN_FREQUENCY                     {125}\
            CONFIG.TX_REFCLK_FREQUENCY                   {156.25}\
            CONFIG.RX_REFCLK_FREQUENCY                   {156.25}\
            CONFIG.RX_JTOL_FC                            {9.8230354}\
            CONFIG.TXPROGDIV_FREQ_VAL                    {468.75}\
            ] [get_ips gtwizard_ultrascale_0];
        
        if {$mode == "PICXO"} {
            set_property -dict [list \
            CONFIG.ENABLE_OPTIONAL_PORTS                                               { txdiffctrl_in  txpostcursor_in txprecursor_in txpippmen_in txpippmovrden_in txpippmpd_in txpippmsel_in txpippmstepsize_in}\
            ] [get_ips gtwizard_ultrascale_0];
        } elseif {$mode == "FRACXO"} {
            set_property -dict [list \
            CONFIG.ENABLE_OPTIONAL_PORTS                                               { txdiffctrl_in  txpostcursor_in txprecursor_in sdm0data_in sdm0reset_in sdm0width_in }\
            CONFIG.TX_QPLL_FRACN_NUMERATOR                                             {131477}\
            CONFIG.RX_QPLL_FRACN_NUMERATOR                                             {131477}\
            CONFIG.TX_REFCLK_FREQUENCY                                                 {257.7620003}\
            CONFIG.RX_REFCLK_FREQUENCY                                                 {257.7620003}\
            ] [get_ips gtwizard_ultrascale_0];
            set_property -quiet -dict [list\
                CONFIG.C_PROBE_OUT10_WIDTH      {6}\
                CONFIG.C_PROBE_OUT10_INIT_VAL   {0x00}\
            ] [get_ips picxo_vio];
        }
    };
   
   
};
xapp589_picxo_ex_des_gen $srcIpDir;