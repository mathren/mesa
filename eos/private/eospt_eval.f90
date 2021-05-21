! ***********************************************************************
!
!   Copyright (C) 2010-2019  The MESA Team
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
!
! ***********************************************************************

      module eosPT_eval
      use eos_def
      use const_def
      use math_lib
      use utils_lib, only: mesa_error

      implicit none

         
      integer, parameter :: i_doing_which = 1
      integer, parameter :: i_which_other = 2
      integer, parameter :: i_handle = 3
      integer, parameter :: i_count = 4
      integer, parameter :: i_species = 5
      
      integer, parameter :: eos_lipar = 5

      integer, parameter :: r_other_value = 1
      integer, parameter :: r_Z = 2
      integer, parameter :: r_X = 3
      integer, parameter :: r_abar = 4
      integer, parameter :: r_zbar = 5
      integer, parameter :: r_Pgas = 6
      integer, parameter :: r_T = 7
      integer, parameter :: r_the_other_log = 8

      integer, parameter :: eos_lrpar = 8
      
      integer, parameter :: doing_get_T = 1
      integer, parameter :: doing_get_Pgas = 2
      integer, parameter :: doing_get_Pgas_for_Rho = 3

      

      
      contains


      subroutine Get_eosPT_Results(rq, &
               Z_in, X_in, abar, zbar, &
               species, chem_id, net_iso, xa, &
               aPgas, alogPgas, atemp, alogtemp, &
               Rho, logRho, dlnRho_dlnPgas_c_T, dlnRho_dlnT_c_Pgas, &
               res, d_dlnRho_c_T, d_dlnT_c_Rho, &
               ierr)
         use utils_lib, only: is_bad
         type (EoS_General_Info), pointer :: rq
         real(dp), intent(in) :: Z_in, X_in, abar, zbar
         integer, intent(in) :: species
         integer, pointer :: chem_id(:), net_iso(:)
         real(dp), intent(in) :: xa(:)
         real(dp), intent(in) :: aPgas, alogPgas, atemp, alogtemp
         real(dp), intent(out) :: Rho, logRho, dlnRho_dlnPgas_c_T, dlnRho_dlnT_c_Pgas
         real(dp), intent(inout) :: res(:), d_dlnRho_c_T(:), d_dlnT_c_Rho(:) ! (nv)
         integer, intent(out) :: ierr
         
         real(dp) :: X, Z, T, logT
         real(dp) :: Pgas, logPgas, Prad, tiny
         logical, parameter :: dbg = .false.
         
         logical :: skip

         include 'formats'
         
         ierr = 0
         tiny = rq% tiny_fuzz
         
         if (is_bad(X_in) .or. is_bad(Z_in)) then
            ierr = -1
            return
         end if
         
         X = X_in; Z = Z_in
         if (X < tiny) X = 0d0
         if (Z < tiny) Z = 0d0
         
         if (X > 1d0) then
            if (X > 1.0001D0) then
               write(*,1) 'Get_eosPT_Results: X bad', X
               ierr = -1
               return
               stop 'eosPT'
            end if
            X = 1d0
         end if
         
         call get_PT_args( &
            aPgas, alogPgas, atemp, alogtemp, Pgas, logPgas, T, logT, ierr)
         if (ierr /= 0) then
            if (dbg) write(*,*) 'error from get_PT_args'
            return
         end if
         
         if (Pgas <= 0) then
            ierr = -1
            return
         end if
         
         if (is_bad(Pgas) .or. is_bad(T)) then
            ierr = -1
            return
         end if
         
         call Get1_eosPT_Results(rq, &
            Z, X, abar, zbar, &
            species, chem_id, net_iso, xa, &
            Pgas, logPgas, T, logT, &
            Rho, logRho, dlnRho_dlnPgas_c_T, dlnRho_dlnT_c_Pgas, &
            res, d_dlnRho_c_T, d_dlnT_c_Rho, ierr)

         ! zero blend fractions; not supported for eosPT
         res(i_frac:i_frac+num_eos_frac_results-1) = 0.0
         d_dlnRho_c_T(i_frac:i_frac+num_eos_frac_results-1) = 0.0
         d_dlnT_c_Rho(i_frac:i_frac+num_eos_frac_results-1) = 0.0

         ! zero phase information
         res(i_phase:i_latent_ddlnRho) = 0d0
         d_dlnT_c_Rho(i_phase:i_latent_ddlnRho) = 0d0
         d_dlnRho_c_T(i_phase:i_latent_ddlnRho) = 0d0

                   
      end subroutine Get_eosPT_Results


      subroutine Get1_eosPT_Results(rq, &
               Z, X, abar, zbar, &
               species, chem_id, net_iso, xa, &
               Pgas, logPgas, T, logT, &
               Rho, logRho, dlnRho_dlnPgas_c_T, dlnRho_dlnT_c_Pgas, &
               res, d_dlnRho_c_T, d_dlnT_c_Rho, ierr)

         use utils_lib, only: is_bad
                  
         type (EoS_General_Info), pointer :: rq
         real(dp), intent(in) :: Z, X, abar, zbar
         integer, intent(in) :: species
         integer, pointer :: chem_id(:), net_iso(:)
         real(dp), intent(in) :: xa(:)
         real(dp), intent(in) :: Pgas, logPgas, T, logT
         real(dp), intent(out) :: Rho, logRho, dlnRho_dlnPgas_c_T, dlnRho_dlnT_c_Pgas
         real(dp), intent(inout) :: res(:), d_dlnRho_c_T(:), d_dlnT_c_Rho(:) ! (nv)
         integer, intent(out) :: ierr
         logical, parameter :: dbg = .false.

         real(dp) :: Pg, logPg, temp, logtemp
         
         include 'formats'
         
         ierr = 0
         
         Pg = Pgas
         logPg = logPgas
         temp = T
         logtemp = logT
         call Get_PT_Results_using_DT( &
            rq, Z, X, abar, zbar, &
            species, chem_id, net_iso, xa, &
            Pg, logPg, temp, logtemp, &
            Rho, logRho, dlnRho_dlnPgas_c_T, dlnRho_dlnT_c_Pgas, &
            res, d_dlnRho_c_T, d_dlnT_c_Rho, ierr)
         
      end subroutine Get1_eosPT_Results
      
      
      subroutine get_PT_args( &
            aPg, alogPg, atemp, alogtemp, Pgas, logPgas, T, logT, ierr)       
         real(dp), intent(in) :: aPg, alogPg
         real(dp), intent(in) :: atemp, alogtemp
         real(dp), intent(out) :: Pgas, logPgas, T, logT
         integer, intent(out) :: ierr
         include 'formats'
         ierr = 0
         T = atemp; logT = alogtemp
         if (atemp == arg_not_provided .and. alogtemp == arg_not_provided) then
            ierr = -2; return
         end if
         if (alogtemp == arg_not_provided) logT = log10(T)
         if (atemp == arg_not_provided) T = exp10(logT)
         if (T <= 0) then
            ierr = -1
            return
         end if
         Pgas = aPg; logPgas = alogPg
         if (Pgas == arg_not_provided .and. logPgas == arg_not_provided) then
            ierr = -3; return
         end if
         if (logPgas == arg_not_provided) logPgas = log10(Pgas)
         if (Pgas == arg_not_provided) Pgas = exp10(logPgas)
         if (Pgas <= 0) then
            ierr = -1
            return
         end if
      end subroutine get_PT_args
         

      subroutine Get_PT_Results_using_DT( &
               rq, Z, X, abar, zbar, &
               species, chem_id, net_iso, xa, &
               Pgas, logPgas, T, logT, &
               Rho, logRho, dlnRho_dlnPgas_c_T, dlnRho_dlnT_c_Pgas, &
               res, d_dlnRho_c_T, d_dlnT_c_Rho, ierr)
         use eosDT_eval, only: get_Rho
         use utils_lib, only: is_bad
         
         type (EoS_General_Info), pointer :: rq ! general information about the request
         real(dp), intent(in) :: Z, X, abar, zbar
         integer, intent(in) :: species
         integer, pointer :: chem_id(:)    
         integer, pointer :: net_iso(:)
         real(dp), intent(in) :: xa(:)
         real(dp), intent(inout) :: Pgas, logPgas, T, logT
         real(dp), intent(out) :: Rho, logRho, dlnRho_dlnPgas_c_T, dlnRho_dlnT_c_Pgas
         real(dp), intent(inout) :: res(:) ! (nv)
         real(dp), intent(inout) :: d_dlnRho_c_T(:) ! (nv)
         real(dp), intent(inout) :: d_dlnT_c_Rho(:) ! (nv)
         integer, intent(out) :: ierr
         
         logical, parameter :: basic_flag = .false.
         integer:: i, eos_calls, max_iter, which_other
         real(dp) :: &
            logRho_guess, rho_guess, other, other_tol, logRho_tol, Prad, f, dfdx, &
            logRho_bnd1, logRho_bnd2, other_at_bnd1, other_at_bnd2, logRho_result

         real(dp), allocatable :: d_dxa_c_TRho(:,:) ! (nv, species)
         
         logical, parameter :: dbg = .false.
         
         include 'formats'
         
         ierr = 0

         which_other = i_lnPgas
         other = logPgas*ln10
         other_tol = 1d-8
         logRho_tol = 1d-8
         
         ! guess based on fully ionized, ideal gas of ions and electrons
         rho_guess = Pgas*abar*mp/(kerg*T*(1+zbar))
         logRho_guess = log10(rho_guess)
      
         logRho_bnd1 = arg_not_provided
         logRho_bnd2 = arg_not_provided
         other_at_bnd1 = arg_not_provided
         other_at_bnd2 = arg_not_provided

         max_iter = 20
         eos_calls = 0
         
         if (dbg) write(*,1) 'rho_guess', rho_guess
         if (dbg) write(*,1) 'logRho_guess', logRho_guess

         allocate(d_dxa_c_TRho(nv, species))
         
         call get_Rho( &
               rq% handle, Z, X, abar, zbar, &
               species, chem_id, net_iso, xa, &
               logT, which_other, other, &
               logRho_tol, other_tol, max_iter, logRho_guess, &
               logRho_bnd1, logRho_bnd2, other_at_bnd1, other_at_bnd2, &
               logRho_result, res, d_dlnRho_c_T, d_dlnT_c_Rho, d_dxa_c_TRho, &
               eos_calls, ierr)
         if (ierr /= 0) then
            if (.false.) then
               write(*,*) 'failed in get_Rho for Get_PT_Results_using_DT'
               write(*,1) 'Z = ', Z
               write(*,1) 'X = ', X
               write(*,1) 'abar = ', abar
               write(*,1) 'zbar = ', zbar
               write(*,1) 'logT = ', logT
               write(*,1) 'Pgas = ', Pgas
               write(*,1) 'logPgas = ', logPgas
               write(*,1) 'logRho_tol = ', logRho_tol
               write(*,1) 'other_tol = ', other_tol
               write(*,1) 'logRho_guess = ', logRho_guess
               write(*,*)
            end if
            return
         end if
         
         logRho = logRho_result
         Rho = exp10(logRho)
         
         if (dbg) write(*,1) 'Rho', Rho
         if (dbg) write(*,1) 'logRho', logRho
         if (dbg) write(*,*)
         if (dbg) write(*,1) 'Pgas input', Pgas
         if (dbg) write(*,1) 'logPgas input', logPgas
         if (dbg) write(*,1) 'Pgas match', exp(res(i_lnPgas))
         if (dbg) write(*,1) 'logPgas match', res(i_lnPgas)/ln10
         if (dbg) write(*,*)
         if (dbg) write(*,1) 'get_Rho: grad_ad', res(i_grad_ad)
         if (dbg) write(*,*)
         
         call do_partials
         
         contains
         
         subroutine do_partials ! dlnRho_dlnPgas_c_T and dlnRho_dlnT_c_Pgas
            real(dp) :: Prad, P, dP_dRho, dPgas_dRho, &
                  dP_dT, dPrad_dT, dPgas_dT, dRho_dPgas, dRho_dT
            include 'formats'
            
            Prad = crad*T*T*T*T/3
            P = Pgas + Prad
            dP_dRho = res(i_chiRho)*P/Rho
            dPgas_dRho = dP_dRho ! const T, so dP_dRho = dPgas_dRho
            dRho_dPgas = 1/dPgas_dRho ! const T
            dlnRho_dlnPgas_c_T = dRho_dPgas*Pgas/Rho ! const T
            
            dPrad_dT = 4*crad*T*T*T/3
            dP_dT = res(i_chiT)*P/T
            dPgas_dT = dP_dT - dPrad_dT ! const Rho
            dRho_dT = -dPgas_dT/dPgas_dRho ! const Pgas
            dlnRho_dlnT_c_Pgas = dRho_dT*T/Rho
            
         end subroutine do_partials

      end subroutine Get_PT_Results_using_DT


      subroutine get_T( &
               handle, Z, X, abar, zbar, &
               species, chem_id, net_iso, xa, &
               logPgas, which_other, other_value, &
               logT_tol, other_tol, max_iter, logT_guess, &
               logT_bnd1, logT_bnd2,  other_at_bnd1, other_at_bnd2, &
               logT_result, Rho, logRho, dlnRho_dlnPgas_c_T, dlnRho_dlnT_c_Pgas, &
               res, d_dlnRho_c_T, d_dlnT_c_Rho, &
               eos_calls, ierr)
         
         integer, intent(in) :: handle

         real(dp), intent(in) :: Z ! the metals mass fraction
         real(dp), intent(in) :: X ! the hydrogen mass fraction
            
         real(dp), intent(in) :: abar, zbar
         
         integer, intent(in) :: species
         integer, pointer :: chem_id(:)    
         integer, pointer :: net_iso(:)
         real(dp), intent(in) :: xa(:)
         
         real(dp), intent(in) :: logPgas ! log10 of density
         integer, intent(in) :: which_other
         real(dp), intent(in) :: other_value ! desired value for the other variable
         real(dp), intent(in) :: other_tol
         
         real(dp), intent(in) :: logT_tol
         integer, intent(in) :: max_iter ! max number of iterations        

         real(dp), intent(in) :: logT_guess
         real(dp), intent(in) :: logT_bnd1, logT_bnd2 ! bounds for logT
            ! set to arg_not_provided if do not know bounds
         real(dp), intent(in) :: other_at_bnd1, other_at_bnd2 ! values at bounds
            ! if don't know these values, just set to arg_not_provided (defined in c_def)
         
         real(dp), intent(out) :: logT_result
         real(dp), intent(out) :: Rho, logRho ! density
         real(dp), intent(out) :: dlnRho_dlnPgas_c_T
         real(dp), intent(out) :: dlnRho_dlnT_c_Pgas

         real(dp), intent(inout) :: res(:) ! (nv)
         real(dp), intent(inout) :: d_dlnRho_c_T(:) ! (nv)
         real(dp), intent(inout) :: d_dlnT_c_Rho(:) ! (nv)
         
         integer, intent(out) :: eos_calls
         integer, intent(out) :: ierr ! 0 means AOK.
         
         call do_safe_get_Pgas_T( &
               handle, Z, X, abar, zbar, &
               species, chem_id, net_iso, xa, &
               logPgas, which_other, other_value, doing_get_T, &
               logT_guess, logT_result, logT_bnd1, logT_bnd2, other_at_bnd1, other_at_bnd2, &
               logT_tol, other_tol, max_iter, &
               Rho, logRho, dlnRho_dlnPgas_c_T, dlnRho_dlnT_c_Pgas, &
               res, d_dlnRho_c_T, d_dlnT_c_Rho, &
               eos_calls, ierr)
      
      end subroutine get_T
      

      subroutine get_Pgas( &
               handle, Z, X, abar, zbar, &
               species, chem_id, net_iso, xa, &
               logT, which_other, other_value, &
               logPgas_tol, other_tol, max_iter, logPgas_guess, &
               logPgas_bnd1, logPgas_bnd2, other_at_bnd1, other_at_bnd2, &
               logPgas_result, Rho, logRho, dlnRho_dlnPgas_c_T, dlnRho_dlnT_c_Pgas, &
               res, d_dlnRho_c_T, d_dlnT_c_Rho, &
               eos_calls, ierr)
     
         use const_def
         
         integer, intent(in) :: handle

         real(dp), intent(in) :: Z ! the metals mass fraction
         real(dp), intent(in) :: X ! the hydrogen mass fraction
            
         real(dp), intent(in) :: abar, zbar
         
         integer, intent(in) :: species
         integer, pointer :: chem_id(:)    
         integer, pointer :: net_iso(:)
         real(dp), intent(in) :: xa(:)
         
         real(dp), intent(in) :: logT ! log10 of temperature

         integer, intent(in) :: which_other
         real(dp), intent(in) :: other_value ! desired value for the other variable
         real(dp), intent(in) :: other_tol
         
         real(dp), intent(in) :: logPgas_tol

         integer, intent(in) :: max_iter ! max number of Newton iterations        

         real(dp), intent(in) :: logPgas_guess
         real(dp), intent(in) :: logPgas_bnd1, logPgas_bnd2 ! bounds for logPgas
            ! set to arg_not_provided if do not know bounds
         real(dp), intent(in) :: other_at_bnd1, other_at_bnd2 ! values at bounds
            ! if don't know these values, just set to arg_not_provided (defined in c_def)
            
         real(dp), intent(out) :: logPgas_result
         real(dp), intent(out) :: Rho, logRho ! density
         real(dp), intent(out) :: dlnRho_dlnPgas_c_T
         real(dp), intent(out) :: dlnRho_dlnT_c_Pgas

         real(dp), intent(inout) :: res(:) ! (nv)
         real(dp), intent(inout) :: d_dlnRho_c_T(:) ! (nv)
         real(dp), intent(inout) :: d_dlnT_c_Rho(:) ! (nv)

         integer, intent(out) :: eos_calls
         integer, intent(out) :: ierr ! 0 means AOK.
         
         call do_safe_get_Pgas_T( &
               handle, Z, X, abar, zbar, &
               species, chem_id, net_iso, xa, &
               logT, which_other, other_value, doing_get_Pgas, &
               logPgas_guess, logPgas_result, logPgas_bnd1, logPgas_bnd2, other_at_bnd1, other_at_bnd2, &
               logPgas_tol, other_tol, max_iter, &
               Rho, logRho, dlnRho_dlnPgas_c_T, dlnRho_dlnT_c_Pgas, &
               res, d_dlnRho_c_T, d_dlnT_c_Rho, &
               eos_calls, ierr)

      end subroutine get_Pgas
      

      subroutine get_Pgas_for_Rho( &
               handle, Z, X, abar, zbar, &
               species, chem_id, net_iso, xa, &
               logT, logRho_want, &
               logPgas_tol, logRho_tol, max_iter, logPgas_guess_in, &
               logPgas_bnd1, logPgas_bnd2, logRho_at_bnd1, logRho_at_bnd2, &
               logPgas_result, Rho, logRho, dlnRho_dlnPgas_c_T, dlnRho_dlnT_c_Pgas, &
               res, d_dlnRho_c_T, d_dlnT_c_Rho, &
               eos_calls, ierr)

         integer, intent(in) :: handle

         real(dp), intent(in) :: Z ! the metals mass fraction
         real(dp), intent(in) :: X ! the hydrogen mass fraction
            
         real(dp), intent(in) :: abar, zbar
         
         integer, intent(in) :: species
         integer, pointer :: chem_id(:)    
         integer, pointer :: net_iso(:)
         real(dp), intent(in) :: xa(:)
         
         real(dp), intent(in) :: logT ! log10 of temperature

         real(dp), intent(in) :: logRho_want ! log10 of desired density
         real(dp), intent(in) :: logRho_tol
         
         real(dp), intent(in) :: logPgas_tol

         integer, intent(in) :: max_iter ! max number of Newton iterations        

         real(dp), intent(in) :: logPgas_guess_in ! log10 of gas pressure
            ! if = arg_not_provided, then will use ideal gas for guess
         real(dp), intent(in) :: logPgas_bnd1, logPgas_bnd2 ! bounds for logPgas
            ! if don't know bounds, just set to arg_not_provided (defined in const_def)
         real(dp), intent(in) :: logRho_at_bnd1, logRho_at_bnd2 ! values at bounds
            ! if don't know these values, just set to arg_not_provided (defined in const_def)

         real(dp), intent(out) :: logPgas_result ! log10 of gas pressure
         real(dp), intent(out) :: Rho, logRho ! density corresponding to logPgas_result
         real(dp), intent(out) :: dlnRho_dlnPgas_c_T
         real(dp), intent(out) :: dlnRho_dlnT_c_Pgas

         real(dp), intent(inout) :: res(:) ! (nv)
         real(dp), intent(inout) :: d_dlnRho_c_T(:) ! (nv)
         real(dp), intent(inout) :: d_dlnT_c_Rho(:) ! (nv)

         integer, intent(out) :: eos_calls
         integer, intent(out) :: ierr ! 0 means AOK.

         real(dp) :: logPgas_guess
         
         logPgas_guess = logPgas_guess_in
         if (logPgas_guess == arg_not_provided) then
            ! Pgas = rho*kerg*T*(1+zbar)/(abar*mp)
            logPgas_guess = logRho_want + logT + log10(kerg*(1+zbar)/(abar*mp))
         end if

         call do_safe_get_Pgas_T( &
               handle, Z, X, abar, zbar, &
               species, chem_id, net_iso, xa, &
               logT, 0, logRho_want, doing_get_Pgas_for_Rho, &
               logPgas_guess, logPgas_result, logPgas_bnd1, logPgas_bnd2, &
               logRho_at_bnd1, logRho_at_bnd2, logPgas_tol, logRho_tol, max_iter, &
               Rho, logRho, dlnRho_dlnPgas_c_T, dlnRho_dlnT_c_Pgas, &
               res, d_dlnRho_c_T, d_dlnT_c_Rho, &
               eos_calls, ierr)
      
      end subroutine get_Pgas_for_Rho

      
      subroutine do_safe_get_Pgas_T( &
               handle, Z, XH1, abar, zbar, &
               species, chem_id, net_iso, xa, &
               the_other_log, which_other, other_value, doing_which, &
               initial_guess, x, xbnd1, xbnd2, other_at_bnd1, other_at_bnd2, &
               xacc, yacc, ntry, &
               Rho, logRho, dlnRho_dlnPgas_c_T, dlnRho_dlnT_c_Pgas, &
               res, d_dlnRho_c_T, d_dlnT_c_Rho, &
               eos_calls, ierr)
         use const_def
         use utils_lib, only: is_bad
         use num_lib, only: brent_safe_zero, look_for_brackets
         use chem_def, only: num_chem_isos
         integer, intent(in) :: handle
         real(dp), intent(in) :: Z, XH1, abar, zbar
         integer, intent(in) :: species
         integer, pointer :: chem_id(:)    
         integer, pointer :: net_iso(:)
         real(dp), intent(in) :: xa(:)
         integer, intent(in) :: which_other
         real(dp), intent(in) :: other_value
         integer, intent(in) :: doing_which
         real(dp), intent(in) :: initial_guess ! for x
         real(dp), intent(out) :: x ! if doing_Pgas, then logPgas, else logT
         real(dp), intent(in) :: the_other_log
         real(dp), intent(in) :: xbnd1, xbnd2, other_at_bnd1, other_at_bnd2
         real(dp), intent(in) :: xacc, yacc ! tolerances
         integer, intent(in) :: ntry ! max number of iterations        
         real(dp), intent(out) :: Rho, logRho ! density
         real(dp), intent(out) :: dlnRho_dlnPgas_c_T
         real(dp), intent(out) :: dlnRho_dlnT_c_Pgas
         real(dp), intent(inout) :: res(:) ! (nv)
         real(dp), intent(inout) :: d_dlnRho_c_T(:) ! (nv)
         real(dp), intent(inout) :: d_dlnT_c_Rho(:) ! (nv)
         integer, intent(out) :: eos_calls, ierr
         
         integer :: i, j, lrpar, lipar, max_iter, irho, ix, iz
         integer, parameter :: lrextras=4
         real(dp), parameter :: dx = 0.1d0
         integer, pointer :: ipar(:)
         real(dp), pointer :: rpar(:)
         real(dp) :: Pgas, T, xb1, xb3, y1, y3, dfdx, f, logPgas, logT
         logical, parameter :: basic_flag = .false.
         type (EoS_General_Info), pointer :: rq
         
         logical, parameter :: dbg = .false.
         
         include 'formats'
         
         ierr = 0

         call get_eos_ptr(handle, rq, ierr)
         if (ierr /= 0) then
            write(*, *) 'get_eos_ptr returned ierr', ierr
            return
         end if

         eos_calls = 0
         x = initial_guess
            
         if (doing_which /= doing_get_T) then
            Pgas = arg_not_provided
            T = exp10(the_other_log)
         else
            T = arg_not_provided
            Pgas = exp10(the_other_log)
         end if

         lipar = eos_lipar + species + num_chem_isos
         lrpar = eos_lrpar + lrextras + nv*3 + species
        
         allocate(rpar(lrpar),ipar(lipar),stat=ierr)
         if (ierr /= 0) then
            write(*, *) 'allocate ierr', ierr
            return
         end if

         ipar(i_doing_which) = doing_which
         ipar(i_which_other) = which_other
         ipar(i_handle) = handle
         ipar(i_count) = eos_calls
         ipar(i_species) = species
         i = eos_lipar
         do j=1,species 
            ipar(i+j) = chem_id(j)
         end do
         i = i+species
         do j=1,num_chem_isos 
            ipar(i+j) = net_iso(j)
         end do
         i = i+num_chem_isos

         rpar(r_other_value) = other_value
         rpar(r_Z) = Z
         rpar(r_X) = XH1
         rpar(r_abar) = abar
         rpar(r_zbar) = zbar
         rpar(r_Pgas) = Pgas
         rpar(r_T) = T
         rpar(r_the_other_log) = the_other_log
         i = eos_lrpar
         i = i+nv ! res
         i = i+nv ! d_dlnRho_c_T
         i = i+nv ! d_dlnT_c_Rho
         i = i+1 ! Rho
         i = i+1 ! logRho
         i = i+1 ! dlnRho_dlnPgas_c_T
         i = i+1 ! dlnRho_dlnT_c_Pgas
         rpar(i+1:i+species) = xa(1:species); i = i+species
         if (i /= lrpar) then
            write(*,3) 'i /= lrpar', i, lrpar
            stop 'bad value for lrpar in do_safe_get_Pgas_T'
         end if
         
         
         xb1 = xbnd1; xb3 = xbnd2
         if (xb1 == arg_not_provided .or. xb3 == arg_not_provided .or. xb1 == xb3) then
         
            if (dbg) then
               write(*,*)
               write(*,*) 'call look_for_brackets'
               write(*,2) 'ntry', ntry
               write(*,1) 'x', x
               write(*,1) 'dx', dx
               write(*,1) 'Z', Z
               write(*,1) 'XH1', XH1
               write(*,1) 'abar', abar
               write(*,1) 'zbar', zbar
               write(*,1) 'Pgas', Pgas
               write(*,1) 'T', T
               write(*,1) 'the_other_log', the_other_log
               write(*,*)
            end if

            call look_for_brackets(x, dx, xb1, xb3, get_f_df, y1, y3, &
                     ntry, lrpar, rpar, lipar, ipar, ierr)
            if (ierr /= 0) then
               if (dbg) then
                  write(*, *) 'look_for_brackets returned ierr', ierr
                  write(*,1) 'x', x
                  write(*,1) 'dx', dx
                  write(*,1) 'xb1', xb1
                  write(*,1) 'xb3', xb3
                  write(*,*) 'ntry', ntry
                  write(*,*) 'lrpar', lrpar
                  write(*,*) 'lipar', lipar
               end if
               call dealloc
               return
            end if
            !write(*,*) 'done look_for_brackets'
         else
            if (other_at_bnd1 == arg_not_provided) then
               y1 = get_f_df(xb1, dfdx, lrpar, rpar, lipar, ipar, ierr)
               if (ierr /= 0) then
                  call dealloc
                  return
               end if
            else
               y1 = other_at_bnd1 - other_value
            end if
            if (other_at_bnd2 == arg_not_provided) then
               y3 = get_f_df(xb3, dfdx, lrpar, rpar, lipar, ipar, ierr)
               if (ierr /= 0) then
                  call dealloc
                  return
               end if
            else
               y3 = other_at_bnd2 - other_value
            end if
         end if
         
         if (dbg) then
            write(*,*)
            write(*,*) 'call brent_safe_zero'
            write(*,1) 'xb1', xb1
            write(*,1) 'xb3', xb3
            write(*,1) 'y1', y1
            write(*,1) 'y3', y3
         end if

         x = brent_safe_zero( &
            xb1, xb3, 1d-14, 0.5d0*xacc, 0.5d0*yacc, get_f_df, y1, y3, &
            lrpar, rpar, lipar, ipar, ierr)
         if (ierr /= 0) then
            call dealloc
            return
         end if
      
         i = eos_lrpar
         res = rpar(i+1:i+nv); i = i+nv
         d_dlnRho_c_T = rpar(i+1:i+nv); i = i+nv
         d_dlnT_c_Rho = rpar(i+1:i+nv); i = i+nv
         Rho = rpar(i+1); i = i+1
         logRho = rpar(i+1); i = i+1
         dlnRho_dlnPgas_c_T = rpar(i+1); i = i+1
         dlnRho_dlnT_c_Pgas = rpar(i+1); i = i+1
         i = i + species ! xa
         if (i /= lrpar) then
            write(*,3) 'i /= lrpar', i, lrpar
            stop 'bad value for lrpar at end of do_safe_get_Pgas_T'
         end if
         
         eos_calls = ipar(4)
         
         call dealloc
         
         !write(*,*) 'do_safe_get_Pgas_T eos_calls', eos_calls
         
         contains
         
         subroutine dealloc
            deallocate(rpar,ipar)
         end subroutine dealloc
         
      end subroutine do_safe_get_Pgas_T


      real(dp) function get_f_df(x, dfdx, lrpar, rpar, lipar, ipar, ierr)
         use eos_def, only:EoS_General_Info, get_eos_ptr
         use chem_def, only: num_chem_isos
         integer, intent(in) :: lrpar, lipar
         real(dp), intent(in) :: x
         real(dp), intent(out) :: dfdx
         integer, intent(inout), pointer :: ipar(:) ! (lipar)
         real(dp), intent(inout), pointer :: rpar(:) ! (lrpar)
         integer, intent(out) :: ierr

         real(dp) :: new, logT, logPgas
         real(dp) :: Z, XH1, abar, zbar, Pgas, T, other, the_other_log
         
         real(dp), dimension(nv) :: d_res_d_abar, d_res_d_zbar
         
         integer :: i, which_other, handle, doing_which, species, rpar_irho
         real(dp), dimension(:), pointer :: &
            res, d_dlnRho_c_T, d_dlnT_c_Rho, xa
         integer, dimension(:), pointer :: chem_id, net_iso
         real(dp), pointer :: Rho, logRho, dlnRho_dlnPgas_c_T, dlnRho_dlnT_c_Pgas
         real(dp) :: dfdx_alt
         logical, parameter :: basic_flag = .false.
         type (EoS_General_Info), pointer :: rq

         include 'formats'
         
         ierr = 0
         get_f_df = 0
         
         doing_which = ipar(i_doing_which)
         which_other = ipar(i_which_other)
         handle = ipar(i_handle)
         species = ipar(i_species)
         i = eos_lipar
         chem_id => ipar(i+1:i+species); i = i+species
         net_iso => ipar(i+1:i+num_chem_isos); i = i+num_chem_isos
         if (i /= lipar) then
         end if
         
         call get_eos_ptr(handle, rq, ierr)
         if (ierr /= 0) then
            write(*, *) 'get_eos_ptr returned ierr', ierr
            return
         end if
         dfdx = 0

         other = rpar(r_other_value)
         Z = rpar(r_Z)
         XH1 = rpar(r_X)
         abar = rpar(r_abar)
         zbar = rpar(r_zbar)
         Pgas = rpar(r_Pgas)
         T = rpar(r_T)
         the_other_log = rpar(r_the_other_log)
         
         i = eos_lrpar
         res => rpar(i+1:i+nv); i = i+nv
         d_dlnRho_c_T => rpar(i+1:i+nv); i = i+nv
         d_dlnT_c_Rho => rpar(i+1:i+nv); i = i+nv
         rpar_irho = i+1
         Rho => rpar(i+1); i = i+1
         logRho => rpar(i+1); i = i+1
         dlnRho_dlnPgas_c_T => rpar(i+1); i = i+1
         dlnRho_dlnT_c_Pgas => rpar(i+1); i = i+1
         xa => rpar(i+1:i+species); i = i+species
         if (i /= lrpar) stop 'bad value for lrpar in eosPT get_f_df'
         
         if (doing_which /= doing_get_T) then
            logPgas = x
            Pgas = exp10(logPgas)
            logT = the_other_log
            T = arg_not_provided
         else
            logT = x
            T = exp10(logT)
            logPgas = the_other_log
            Pgas = arg_not_provided
         end if
         
         ierr = 0
         call Get_eosPT_Results(rq, &
               Z, XH1, abar, zbar, &
               species, chem_id, net_iso, xa, &
               Pgas, logPgas, T, logT, &
               Rho, logRho, dlnRho_dlnPgas_c_T, dlnRho_dlnT_c_Pgas, &
               res, d_dlnRho_c_T, d_dlnT_c_Rho, &
               ierr)
         if (ierr /= 0) then
 22          format(a30, e26.16)
            if (.true.) then
               write(*, *) 'Get_eosPT_Results returned ierr', ierr
               write(*, 22) 'Z', Z
               write(*, 22) 'XH1', XH1
               write(*, 22) 'abar', abar
               write(*, 22) 'zbar', zbar
               write(*, 22) 'Pgas', Pgas
               write(*, 22) 'logPgas', logPgas
               write(*, 22) 'T', T
               write(*, 22) 'logT', logT
               write(*,*)
            end if
            return
         end if
         
         ipar(4) = ipar(4)+1 ! count eos calls
         
         if (doing_which == doing_get_Pgas_for_Rho) then
            new = logRho
         else
            new = res(which_other)
         end if
         get_f_df = new - other
         
         ! f = f(lnRho(lnPgas,lnT),lnT)
         if (doing_which == doing_get_T) then
            dfdx = (d_dlnT_c_Rho(which_other) &
                  + dlnRho_dlnT_c_Pgas*d_dlnRho_c_T(which_other))*ln10
         else if (doing_which == doing_get_Pgas) then
            dfdx = dlnRho_dlnPgas_c_T*d_dlnRho_c_T(which_other)*ln10
         else if (doing_which == doing_get_Pgas_for_Rho) then
            dfdx = dlnRho_dlnPgas_c_T
         else
            stop 'bad value for doing_which in eosPT_eval'
         end if
         
         if (.false. .and. abs(other - 3.5034294596213336d+01) < 1d-14) then
         !if (.true.) then
            if (doing_which /= doing_get_T) then
               write(*,2) 'logPgas, f, dfdx, f/dfdx', ipar(4), logPgas, get_f_df, dfdx, get_f_df/dfdx
            else
               write(*,2) 'logT, f, dfdx, f/dfdx', ipar(4), logT, get_f_df, dfdx, get_f_df/dfdx
            end if
            !write(*,1) 'new', new
            !write(*,1) 'other', other
            !write(*,1) 'get_f_df', get_f_df
            !write(*,1) 'dfdx', dfdx
            !write(*,*)
            !if (ipar(4) > 25) stop
         end if
         
         !write(*,2) 'get_f_df Rho', rpar_irho, rpar(rpar_irho), Rho
         
      end function get_f_df


      end module eosPT_eval
      
