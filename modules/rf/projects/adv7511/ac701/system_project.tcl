
source ../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_project.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

adi_project_create adv7511_ac701
adi_project_files adv7511_ac701 [list \
  "system_top.v" \
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/common/ac701/ac701_system_constr.xdc" \
  "$ad_hdl_dir/projects/adv7511/ac701/system_constr.xdc"]

adi_project_run adv7511_ac701

