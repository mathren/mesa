! ***********************************************************************
!
!   Copyright (C) 2010  The MESA Team
!
!   MESA is free software; you can use it and/or modify
!   it under the combined terms and restrictions of the MESA MANIFESTO
!   and the GNU General Library Public License as published
!   by the Free Software Foundation; either version 2 of the License,
!   or (at your option) any later version.
!
!   You should have received a copy of the MESA MANIFESTO along with
!   this software; if not, it is available at the mesa website:
!   http://mesa.sourceforge.net/
!
!   MESA is distributed in the hope that it will be useful,
!   but WITHOUT ANY WARRANTY; without even the implied warranty of
!   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
!   See the GNU Library General Public License for more details.
!
!   You should have received a copy of the GNU Library General Public License
!   along with this software; if not, write to the Free Software
!   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
!
! ***********************************************************************

module rates_names

   use utils_lib, only : mesa_error

   implicit none


contains

   subroutine set_reaction_names
      use rates_def
      integer :: i, cnt

      cnt = 0
      reaction_Name(:) = ''

      reaction_Name(ir1212) = 'r1212'
      reaction_Name(ir1216) = 'r1216'
      reaction_Name(ir1216_to_mg24) = 'r1216_to_mg24'
      reaction_Name(ir1216_to_si28) = 'r1216_to_si28'
      reaction_Name(ir1616) = 'r1616'
      reaction_Name(ir1616a) = 'r1616a'
      reaction_Name(ir1616g) = 'r1616g'
      reaction_Name(ir1616p_aux) = 'r1616p_aux'
      reaction_Name(ir1616ppa) = 'r1616ppa'
      reaction_Name(ir1616ppg) = 'r1616ppg'
      reaction_Name(ir_he3_ag_be7) = 'r_he3_ag_be7'
      reaction_Name(ir34_pp2) = 'r34_pp2'
      reaction_Name(ir34_pp3) = 'r34_pp3'
      reaction_Name(ir_al27_pa_mg24) = 'r_al27_pa_mg24'
      reaction_Name(ir_ar36_ag_ca40) = 'r_ar36_ag_ca40'
      reaction_Name(ir_ar36_ga_s32) = 'r_ar36_ga_s32'
      reaction_Name(ir_b8_gp_be7) = 'r_b8_gp_be7'
      reaction_Name(ir_be7_wk_li7) = 'r_be7_wk_li7'
      reaction_Name(ir_be7_pg_b8) = 'r_be7_pg_b8'
      reaction_Name(ir_c12_ag_o16) = 'r_c12_ag_o16'
      reaction_Name(ir_c12_ap_n15) = 'r_c12_ap_n15'
      reaction_Name(ir_c12_pg_n13) = 'r_c12_pg_n13'
      reaction_Name(ir_c12_to_he4_he4_he4) = 'r_c12_to_he4_he4_he4'
      reaction_Name(ir_c13_an_o16) = 'r_c13_an_o16'
      reaction_Name(ir_c13_pg_n14) = 'r_c13_pg_n14'
      reaction_Name(ir_ca40_ag_ti44) = 'r_ca40_ag_ti44'
      reaction_Name(ir_ca40_ga_ar36) = 'r_ca40_ga_ar36'
      reaction_Name(ir_cr48_ag_fe52) = 'r_cr48_ag_fe52'
      reaction_Name(ir_cr48_ga_ti44) = 'r_cr48_ga_ti44'
      reaction_Name(ir_f17_ap_ne20) = 'r_f17_ap_ne20'
      reaction_Name(ir_f17_gp_o16) = 'r_f17_gp_o16'
      reaction_Name(ir_f17_pa_o14) = 'r_f17_pa_o14'
      reaction_Name(ir_f18_gp_o17) = 'r_f18_gp_o17'
      reaction_Name(ir_f18_pa_o15) = 'r_f18_pa_o15'
      reaction_Name(ir_f19_ap_ne22) = 'r_f19_ap_ne22'
      reaction_Name(ir_f19_gp_o18) = 'r_f19_gp_o18'
      reaction_Name(ir_f19_pa_o16) = 'r_f19_pa_o16'
      reaction_Name(ir_f19_pg_ne20) = 'r_f19_pg_ne20'
      reaction_Name(ir_fe52_ag_ni56) = 'r_fe52_ag_ni56'
      reaction_Name(ir_fe52_ga_cr48) = 'r_fe52_ga_cr48'
      reaction_Name(ir_h2_be7_to_h1_he4_he4) = 'r_h2_be7_to_h1_he4_he4'
      reaction_Name(ir_h2_h2_to_he4) = 'r_h2_h2_to_he4'
      reaction_Name(ir_h2_he3_to_h1_he4) = 'r_h2_he3_to_h1_he4'
      reaction_Name(ir_he3_be7_to_h1_h1_he4_he4) = 'r_he3_be7_to_h1_h1_he4_he4'
      reaction_Name(ir_he3_he3_to_h1_h1_he4) = 'r_he3_he3_to_h1_h1_he4'
      reaction_Name(ir_h1_h1_he4_to_he3_he3) = 'r_h1_h1_he4_to_he3_he3'
      reaction_Name(ir_he4_he4_he4_to_c12) = 'r_he4_he4_he4_to_c12'
      reaction_Name(ir_li7_pa_he4) = 'r_li7_pa_he4'
      reaction_Name(ir_he4_ap_li7) = 'r_he4_ap_li7'
      reaction_Name(ir_mg24_ag_si28) = 'r_mg24_ag_si28'
      reaction_Name(ir_mg24_ap_al27) = 'r_mg24_ap_al27'
      reaction_Name(ir_mg24_ga_ne20) = 'r_mg24_ga_ne20'
      reaction_Name(ir_n13_ap_o16) = 'r_n13_ap_o16'
      reaction_Name(ir_n13_gp_c12) = 'r_n13_gp_c12'
      reaction_Name(ir_n13_pg_o14) = 'r_n13_pg_o14'
      reaction_Name(ir_n14_ag_f18) = 'r_n14_ag_f18'
      reaction_Name(ir_n14_ap_o17) = 'r_n14_ap_o17'
      reaction_Name(ir_n14_gp_c13) = 'r_n14_gp_c13'
      reaction_Name(ir_n14_pg_o15) = 'r_n14_pg_o15'
      reaction_Name(ir_n15_ag_f19) = 'r_n15_ag_f19'
      reaction_Name(ir_n15_ap_o18) = 'r_n15_ap_o18'
      reaction_Name(ir_n15_pa_c12) = 'r_n15_pa_c12'
      reaction_Name(ir_n15_pg_o16) = 'r_n15_pg_o16'
      reaction_Name(ir_na23_pa_ne20) = 'r_na23_pa_ne20'
      reaction_Name(ir_ne18_gp_f17) = 'r_ne18_gp_f17'
      reaction_Name(ir_ne19_ga_o15) = 'r_ne19_ga_o15'
      reaction_Name(ir_ne19_gp_f18) = 'r_ne19_gp_f18'
      reaction_Name(ir_ne20_ag_mg24) = 'r_ne20_ag_mg24'
      reaction_Name(ir_ne20_ap_na23) = 'r_ne20_ap_na23'
      reaction_Name(ir_ne20_ga_o16) = 'r_ne20_ga_o16'
      reaction_Name(ir_ne20_gp_f19) = 'r_ne20_gp_f19'
      reaction_Name(ir_ne22_ag_mg26) = 'r_ne22_ag_mg26'
      reaction_Name(ir_ne22_pg_na23) = 'r_ne22_pg_na23'
      reaction_Name(ir_ni56_ga_fe52) = 'r_ni56_ga_fe52'
      reaction_Name(ir_o14_ag_ne18) = 'r_o14_ag_ne18'
      reaction_Name(ir_o14_ap_f17) = 'r_o14_ap_f17'
      reaction_Name(ir_o14_gp_n13) = 'r_o14_gp_n13'
      reaction_Name(ir_o15_ag_ne19) = 'r_o15_ag_ne19'
      reaction_Name(ir_o15_ap_f18) = 'r_o15_ap_f18'
      reaction_Name(ir_o15_gp_n14) = 'r_o15_gp_n14'
      reaction_Name(ir_o16_ag_ne20) = 'r_o16_ag_ne20'
      reaction_Name(ir_o16_ap_f19) = 'r_o16_ap_f19'
      reaction_Name(ir_o16_ga_c12) = 'r_o16_ga_c12'
      reaction_Name(ir_o16_gp_n15) = 'r_o16_gp_n15'
      reaction_Name(ir_o16_pg_f17) = 'r_o16_pg_f17'
      reaction_Name(ir_o17_pa_n14) = 'r_o17_pa_n14'
      reaction_Name(ir_o17_pg_f18) = 'r_o17_pg_f18'
      reaction_Name(ir_o18_ag_ne22) = 'r_o18_ag_ne22'
      reaction_Name(ir_o18_pa_n15) = 'r_o18_pa_n15'
      reaction_Name(ir_o18_pg_f19) = 'r_o18_pg_f19'
      reaction_Name(ir_f17_pg_ne18) = 'r_f17_pg_ne18'
      reaction_Name(ir_f18_pg_ne19) = 'r_f18_pg_ne19'
      reaction_Name(ir_s32_ag_ar36) = 'r_s32_ag_ar36'
      reaction_Name(ir_s32_ga_si28) = 'r_s32_ga_si28'
      reaction_Name(ir_si28_ag_s32) = 'r_si28_ag_s32'
      reaction_Name(ir_si28_ga_mg24) = 'r_si28_ga_mg24'
      reaction_Name(ir_ti44_ag_cr48) = 'r_ti44_ag_cr48'
      reaction_Name(ir_ti44_ga_ca40) = 'r_ti44_ga_ca40'
      reaction_Name(iral27pa_aux) = 'ral27pa_aux'
      reaction_Name(iral27pg_aux) = 'ral27pg_aux'
      reaction_Name(irar36ap_aux) = 'rar36ap_aux'
      reaction_Name(irar36ap_to_ca40) = 'rar36ap_to_ca40'
      reaction_Name(irar36gp_aux) = 'rar36gp_aux'
      reaction_Name(irar36gp_to_s32) = 'rar36gp_to_s32'
      reaction_Name(irbe7ec_li7_aux) = 'rbe7ec_li7_aux'
      reaction_Name(irbe7pg_b8_aux) = 'rbe7pg_b8_aux'
      reaction_Name(irc12_to_c13) = 'rc12_to_c13'
      reaction_Name(irc12_to_n14) = 'rc12_to_n14'
      reaction_Name(irc12ap_aux) = 'rc12ap_aux'
      reaction_Name(irc12ap_to_o16) = 'rc12ap_to_o16'
      reaction_Name(irca40ap_aux) = 'rca40ap_aux'
      reaction_Name(irca40ap_to_ti44) = 'rca40ap_to_ti44'
      reaction_Name(irca40gp_aux) = 'rca40gp_aux'
      reaction_Name(irca40gp_to_ar36) = 'rca40gp_to_ar36'
      reaction_Name(ircl35pa_aux) = 'rcl35pa_aux'
      reaction_Name(ircl35pg_aux) = 'rcl35pg_aux'
      reaction_Name(irco55gprot_aux) = 'rco55gprot_aux'
      reaction_Name(irco55pg_aux) = 'rco55pg_aux'
      reaction_Name(irco55protg_aux) = 'rco55protg_aux'
      reaction_Name(ircr48ap_aux) = 'rcr48ap_aux'
      reaction_Name(ircr48ap_to_fe52) = 'rcr48ap_to_fe52'
      reaction_Name(ircr48gp_aux) = 'rcr48gp_aux'
      reaction_Name(ircr48gp_to_ti44) = 'rcr48gp_to_ti44'
      reaction_Name(irf19pg_aux) = 'rf19pg_aux'
      reaction_Name(irfe52ap_aux) = 'rfe52ap_aux'
      reaction_Name(irfe52ap_to_ni56) = 'rfe52ap_to_ni56'
      reaction_Name(irfe52aprot_aux) = 'rfe52aprot_aux'
      reaction_Name(irfe52aprot_to_fe54) = 'rfe52aprot_to_fe54'
      reaction_Name(irfe52aprot_to_ni56) = 'rfe52aprot_to_ni56'
      reaction_Name(irfe52gp_aux) = 'rfe52gp_aux'
      reaction_Name(irfe52gp_to_cr48) = 'rfe52gp_to_cr48'
      reaction_Name(irfe52neut_to_fe54) = 'rfe52neut_to_fe54'
      reaction_Name(irfe52ng_aux) = 'rfe52ng_aux'
      reaction_Name(irfe53gn_aux) = 'rfe53gn_aux'
      reaction_Name(irfe53ng_aux) = 'rfe53ng_aux'
      reaction_Name(irfe54a_to_ni56) = 'rfe54a_to_ni56'
      reaction_Name(irfe54an_aux) = 'rfe54an_aux'
      reaction_Name(irfe54an_to_ni56) = 'rfe54an_to_ni56'
      reaction_Name(irfe54aprot_to_fe56) = 'rfe54aprot_to_fe56'
      reaction_Name(irfe54g_to_fe52) = 'rfe54g_to_fe52'
      reaction_Name(irfe54ng_aux) = 'rfe54ng_aux'
      reaction_Name(irfe54ng_to_fe56) = 'rfe54ng_to_fe56'
      reaction_Name(irfe54prot_to_fe52) = 'rfe54prot_to_fe52'
      reaction_Name(irfe54prot_to_ni56) = 'rfe54prot_to_ni56'
      reaction_Name(irfe54protg_aux) = 'rfe54protg_aux'
      reaction_Name(irfe55gn_aux) = 'rfe55gn_aux'
      reaction_Name(irfe55ng_aux) = 'rfe55ng_aux'
      reaction_Name(irfe56ec_fake_to_mn56) = 'rfe56ec_fake_to_mn56'
      reaction_Name(irfe56ec_fake_to_mn57) = 'rfe56ec_fake_to_mn57'
      reaction_Name(irfe56ec_fake_to_cr56) = 'rfe56ec_fake_to_cr56'
      reaction_Name(irfe56ec_fake_to_cr57) = 'rfe56ec_fake_to_cr57'
      reaction_Name(irfe56ec_fake_to_cr58) = 'rfe56ec_fake_to_cr58'
      reaction_Name(irfe56ec_fake_to_cr59) = 'rfe56ec_fake_to_cr59'
      reaction_Name(irfe56ec_fake_to_cr60) = 'rfe56ec_fake_to_cr60'
      reaction_Name(irfe56ec_fake_to_cr61) = 'rfe56ec_fake_to_cr61'
      reaction_Name(irfe56ec_fake_to_cr62) = 'rfe56ec_fake_to_cr62'
      reaction_Name(irfe56ec_fake_to_cr63) = 'rfe56ec_fake_to_cr63'
      reaction_Name(irfe56ec_fake_to_cr64) = 'rfe56ec_fake_to_cr64'
      reaction_Name(irfe56ec_fake_to_cr65) = 'rfe56ec_fake_to_cr65'
      reaction_Name(irfe56ec_fake_to_cr66) = 'rfe56ec_fake_to_cr66'
      reaction_Name(irfe56ee_to_ni56) = 'rfe56ee_to_ni56'
      reaction_Name(irfe56gn_aux) = 'rfe56gn_aux'
      reaction_Name(irfe56gn_to_fe54) = 'rfe56gn_to_fe54'
      reaction_Name(irfe56prot_to_fe54) = 'rfe56prot_to_fe54'
      reaction_Name(irh2_protg_aux) = 'rh2_protg_aux'
      reaction_Name(irh2g_neut_aux) = 'rh2g_neut_aux'
      reaction_Name(irhe3_neutg_aux) = 'rhe3_neutg_aux'
      reaction_Name(irhe3gprot_aux) = 'rhe3gprot_aux'
      reaction_Name(irhe4_breakup) = 'rhe4_breakup'
      reaction_Name(irhe4_rebuild) = 'rhe4_rebuild'
      reaction_Name(irhe4g_neut_aux) = 'rhe4g_neut_aux'
      reaction_Name(irk39pa_aux) = 'rk39pa_aux'
      reaction_Name(irk39pg_aux) = 'rk39pg_aux'
      reaction_Name(irmg24ap_aux) = 'rmg24ap_aux'
      reaction_Name(irmg24ap_to_si28) = 'rmg24ap_to_si28'
      reaction_Name(irmg24gp_aux) = 'rmg24gp_aux'
      reaction_Name(irmg24gp_to_ne20) = 'rmg24gp_to_ne20'
      reaction_Name(irmn51pg_aux) = 'rmn51pg_aux'
      reaction_Name(irn14_to_c12) = 'rn14_to_c12'
      reaction_Name(irn14_to_n15) = 'rn14_to_n15'
      reaction_Name(irn14_to_o16) = 'rn14_to_o16'
      reaction_Name(irn14ag_lite) = 'rn14ag_lite'
      reaction_Name(irn14gc12) = 'rn14gc12'
      reaction_Name(irn14pg_aux) = 'rn14pg_aux'
      reaction_Name(irn15pa_aux) = 'rn15pa_aux'
      reaction_Name(irn15pg_aux) = 'rn15pg_aux'
      reaction_Name(irna23pa_aux) = 'rna23pa_aux'
      reaction_Name(irna23pg_aux) = 'rna23pg_aux'
      reaction_Name(irne18ag_to_mg24) = 'rne18ag_to_mg24'
      reaction_Name(irne18ap_to_mg22) = 'rne18ap_to_mg22'
      reaction_Name(irne18ap_to_mg24) = 'rne18ap_to_mg24'
      reaction_Name(irne19pg_to_mg22) = 'rne19pg_to_mg22'
      reaction_Name(irne19pg_to_mg24) = 'rne19pg_to_mg24'
      reaction_Name(irne20ap_aux) = 'rne20ap_aux'
      reaction_Name(irne20ap_to_mg24) = 'rne20ap_to_mg24'
      reaction_Name(irne20gp_aux) = 'rne20gp_aux'
      reaction_Name(irne20gp_to_o16) = 'rne20gp_to_o16'
      reaction_Name(irne20pg_to_mg22) = 'rne20pg_to_mg22'
      reaction_Name(irne20pg_to_mg24) = 'rne20pg_to_mg24'
      reaction_Name(irneut_to_prot) = 'rneut_to_prot'
      reaction_Name(irni56ec_to_fe54) = 'rni56ec_to_fe54'
      reaction_Name(irni56ec_to_fe56) = 'rni56ec_to_fe56'

      reaction_Name(irni56ec_to_co56) = 'rni56ec_to_co56'
      reaction_Name(irco56ec_to_fe56) = 'rco56ec_to_fe56'

      reaction_Name(irni56gp_aux) = 'rni56gp_aux'
      reaction_Name(irni56gp_to_fe52) = 'rni56gp_to_fe52'
      reaction_Name(irni56gprot_aux) = 'rni56gprot_aux'
      reaction_Name(irni56gprot_to_fe52) = 'rni56gprot_to_fe52'
      reaction_Name(irni56gprot_to_fe54) = 'rni56gprot_to_fe54'
      reaction_Name(irni56ng_to_fe54) = 'rni56ng_to_fe54'
      reaction_Name(irni57na_aux) = 'rni57na_aux'
      reaction_Name(iro16_to_n14) = 'ro16_to_n14'
      reaction_Name(iro16_to_o17) = 'ro16_to_o17'
      reaction_Name(iro16ap_aux) = 'ro16ap_aux'
      reaction_Name(iro16ap_to_ne20) = 'ro16ap_to_ne20'
      reaction_Name(iro16gp_aux) = 'ro16gp_aux'
      reaction_Name(iro16gp_to_c12) = 'ro16gp_to_c12'
      reaction_Name(iro17_to_o18) = 'ro17_to_o18'
      reaction_Name(irp31pa_aux) = 'rp31pa_aux'
      reaction_Name(irp31pg_aux) = 'rp31pg_aux'
      reaction_Name(irpep_to_he3) = 'rpep_to_he3'
      reaction_Name(irpp_to_he3) = 'rpp_to_he3'
      reaction_Name(irprot_neutg_aux) = 'rprot_neutg_aux'
      reaction_Name(irprot_to_neut) = 'rprot_to_neut'
      reaction_Name(irs32ap_aux) = 'rs32ap_aux'
      reaction_Name(irs32ap_to_ar36) = 'rs32ap_to_ar36'
      reaction_Name(irs32gp_aux) = 'rs32gp_aux'
      reaction_Name(irs32gp_to_si28) = 'rs32gp_to_si28'
      reaction_Name(irsc43pa_aux) = 'rsc43pa_aux'
      reaction_Name(irsc43pg_aux) = 'rsc43pg_aux'
      reaction_Name(irsi28ap_aux) = 'rsi28ap_aux'
      reaction_Name(irsi28ap_to_s32) = 'rsi28ap_to_s32'
      reaction_Name(irsi28gp_aux) = 'rsi28gp_aux'
      reaction_Name(irsi28gp_to_mg24) = 'rsi28gp_to_mg24'
      reaction_Name(irti44ap_aux) = 'rti44ap_aux'
      reaction_Name(irti44ap_to_cr48) = 'rti44ap_to_cr48'
      reaction_Name(irti44gp_aux) = 'rti44gp_aux'
      reaction_Name(irti44gp_to_ca40) = 'rti44gp_to_ca40'
      reaction_Name(irv47pa_aux) = 'rv47pa_aux'
      reaction_Name(irv47pg_aux) = 'rv47pg_aux'
      reaction_Name(ir_h1_h1_wk_h2) = 'r_h1_h1_wk_h2'
      reaction_Name(ir_h1_h1_ec_h2) = 'r_h1_h1_ec_h2'
      reaction_Name(irn14ag_to_ne22) = 'rn14ag_to_ne22'
      reaction_Name(irf19pa_aux) = 'rf19pa_aux'
      reaction_Name(ir_b8_wk_he4_he4) = 'r_b8_wk_he4_he4'
      reaction_Name(irmn51pa_aux) = 'rmn51pa_aux'
      reaction_Name(irfe54gn_aux) = 'rfe54gn_aux'
      reaction_Name(irco55pa_aux) = 'rco55pa_aux'
      reaction_Name(irco55prota_aux) = 'rco55prota_aux'
      reaction_Name(irn14ag_to_o18) = 'rn14ag_to_o18'
      reaction_Name(ir_h1_he3_wk_he4) = 'r_h1_he3_wk_he4'

      reaction_Name(ir_al27_pg_si28) = 'r_al27_pg_si28'
      reaction_Name(ir_si28_gp_al27) = 'r_si28_gp_al27'
      reaction_Name(ir_si28_ap_p31) = 'r_si28_ap_p31'
      reaction_Name(ir_p31_pa_si28) = 'r_p31_pa_si28'
      reaction_Name(ir_p31_pg_s32) = 'r_p31_pg_s32'
      reaction_Name(ir_s32_gp_p31) = 'r_s32_gp_p31'
      reaction_Name(ir_s32_ap_cl35) = 'r_s32_ap_cl35'
      reaction_Name(ir_cl35_pa_s32) = 'r_cl35_pa_s32'
      reaction_Name(ir_cl35_pg_ar36) = 'r_cl35_pg_ar36'
      reaction_Name(ir_ar36_gp_cl35) = 'r_ar36_gp_cl35'
      reaction_Name(ir_ar36_ap_k39) = 'r_ar36_ap_k39'
      reaction_Name(ir_k39_pa_ar36) = 'r_k39_pa_ar36'
      reaction_Name(ir_k39_pg_ca40) = 'r_k39_pg_ca40'
      reaction_Name(ir_ca40_gp_k39) = 'r_ca40_gp_k39'
      reaction_Name(ir_ca40_ap_sc43) = 'r_ca40_ap_sc43'
      reaction_Name(ir_sc43_pa_ca40) = 'r_sc43_pa_ca40'
      reaction_Name(ir_sc43_pg_ti44) = 'r_sc43_pg_ti44'
      reaction_Name(ir_ti44_gp_sc43) = 'r_ti44_gp_sc43'
      reaction_Name(ir_ti44_ap_v47) = 'r_ti44_ap_v47'
      reaction_Name(ir_v47_pa_ti44) = 'r_v47_pa_ti44'
      reaction_Name(ir_v47_pg_cr48) = 'r_v47_pg_cr48'
      reaction_Name(ir_cr48_gp_v47) = 'r_cr48_gp_v47'
      reaction_Name(ir_cr48_ap_mn51) = 'r_cr48_ap_mn51'
      reaction_Name(ir_mn51_pa_cr48) = 'r_mn51_pa_cr48'
      reaction_Name(ir_mn51_pg_fe52) = 'r_mn51_pg_fe52'
      reaction_Name(ir_fe52_gp_mn51) = 'r_fe52_gp_mn51'
      reaction_Name(ir_fe52_ap_co55) = 'r_fe52_ap_co55'
      reaction_Name(ir_co55_pa_fe52) = 'r_co55_pa_fe52'
      reaction_Name(ir_co55_pg_ni56) = 'r_co55_pg_ni56'
      reaction_Name(ir_ni56_gp_co55) = 'r_ni56_gp_co55'
      reaction_Name(ir_fe52_ng_fe53) = 'r_fe52_ng_fe53'
      reaction_Name(ir_fe53_gn_fe52) = 'r_fe53_gn_fe52'
      reaction_Name(ir_fe53_ng_fe54) = 'r_fe53_ng_fe54'
      reaction_Name(ir_fe54_gn_fe53) = 'r_fe54_gn_fe53'
      reaction_Name(ir_fe54_pg_co55) = 'r_fe54_pg_co55'
      reaction_Name(ir_co55_gp_fe54) = 'r_co55_gp_fe54'
      reaction_Name(ir_he3_ng_he4) = 'r_he3_ng_he4'
      reaction_Name(ir_he4_gn_he3) = 'r_he4_gn_he3'
      reaction_Name(ir_h1_ng_h2) = 'r_h1_ng_h2'
      reaction_Name(ir_h2_gn_h1) = 'r_h2_gn_h1'
      reaction_Name(ir_h2_pg_he3) = 'r_h2_pg_he3'
      reaction_Name(ir_he3_gp_h2) = 'r_he3_gp_h2'
      reaction_Name(ir_fe54_ng_fe55) = 'r_fe54_ng_fe55'
      reaction_Name(ir_fe55_gn_fe54) = 'r_fe55_gn_fe54'
      reaction_Name(ir_fe55_ng_fe56) = 'r_fe55_ng_fe56'
      reaction_Name(ir_fe56_gn_fe55) = 'r_fe56_gn_fe55'
      reaction_Name(ir_fe54_ap_co57) = 'r_fe54_ap_co57'
      reaction_Name(ir_co57_pa_fe54) = 'r_co57_pa_fe54'
      reaction_Name(ir_fe56_pg_co57) = 'r_fe56_pg_co57'
      reaction_Name(ir_co57_gp_fe56) = 'r_co57_gp_fe56'
      reaction_Name(ir_c12_c12_to_h1_na23) = 'r_c12_c12_to_h1_na23'
      reaction_Name(ir_he4_ne20_to_c12_c12) = 'r_he4_ne20_to_c12_c12'
      reaction_Name(ir_c12_c12_to_he4_ne20) = 'r_c12_c12_to_he4_ne20'
      reaction_Name(ir_he4_mg24_to_c12_o16) = 'r_he4_mg24_to_c12_o16'

      ! fxt for al26 isomers
      reaction_Name(ir_al26_1_to_al26_2) = 'r_al26-1_to_al26-2'
      reaction_Name(ir_al26_2_to_al26_1) = 'r_al26-2_to_al26-1'

      !reaction_Name(i) = ''

      cnt = 0
      do i = 1, num_predefined_reactions
         if (len_trim(reaction_Name(i)) == 0) then
            write(*, *) 'missing name for reaction', i
            if (i > 1) write(*, *) 'following ' // trim(reaction_Name(i - 1))
            write(*, *)
            cnt = cnt + 1
         end if
      end do

      if (cnt > 0) call mesa_error(__FILE__, __LINE__, 'set_reaction_names')

   end subroutine set_reaction_names


end module rates_names


