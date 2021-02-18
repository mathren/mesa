! ***********************************************************************
!
!   Copyright (C) 2011  Bill Paxton
!
!   this file is part of mesa.
!
!   mesa is free software; you can redistribute it and/or modify
!   it under the terms of the gnu general library public license as published
!   by the free software foundation; either version 2 of the license, or
!   (at your option) any later version.
!
!   mesa is distributed in the hope that it will be useful, 
!   but without any warranty; without even the implied warranty of
!   merchantability or fitness for a particular purpose.  see the
!   gnu library general public license for more details.
!
!   you should have received a copy of the gnu library general public license
!   along with this software; if not, write to the free software
!   foundation, inc., 59 temple place, suite 330, boston, ma 02111-1307 usa
!
! ***********************************************************************
 
      module run_star_extras

      use star_lib
      use star_def
      use const_def
      use math_lib
      use utils_lib, only: mesa_error
            
      implicit none
      
      include "test_suite_extras_def.inc"
      integer :: iounit

      real(dp) :: target_a3, target_b3, target_b1, target_a_div_r
      real(dp) :: target_p0, target_p1, target_s0, target_s1
      real(dp), parameter :: perfect_tol = 1d-12
      real(dp), parameter :: solar_tol = 1d1
      
      ! these routines are called by the standard run_star check_model
      contains

      include "test_suite_extras.inc"
      
      
      subroutine extras_controls(id, ierr)
         use astero_def, only: star_astero_procs
         integer, intent(in) :: id
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return         
         s% extras_startup => extras_startup
         s% extras_check_model => extras_check_model
         s% extras_finish_step => extras_finish_step
         s% extras_after_evolve => extras_after_evolve
         s% how_many_extra_history_columns => how_many_extra_history_columns
         s% data_for_extra_history_columns => data_for_extra_history_columns
         s% how_many_extra_profile_columns => how_many_extra_profile_columns
         s% data_for_extra_profile_columns => data_for_extra_profile_columns  
         include 'set_star_astero_procs.inc'
      end subroutine extras_controls

      
      subroutine set_my_vars(id, ierr) ! called from star_astero code
         !use astero_search_data, only: include_my_var1_in_chi2, my_var1
         integer, intent(in) :: id
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         ! my_var's are predefined in the simplex_search_data.
         ! this routine's job is to assign those variables to current value in the model.
         ! it is called whenever a new value of chi2 is calculated.
         ! only necessary to set the my_var's you are actually using.
         ierr = 0
         !if (include_my_var1_in_chi2) then
            call star_ptr(id, s, ierr)
            if (ierr /= 0) return
            !my_var1 = s% Teff
         !end if
      end subroutine set_my_vars
      
      
      subroutine will_set_my_param(id, i, new_value, ierr) ! called from star_astero code
         !use astero_search_data, only: vary_my_param1
         integer, intent(in) :: id
         integer, intent(in) :: i ! which of my_param's will be set
         real(dp), intent(in) :: new_value
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         ierr = 0

         ! old value has not yet been changed.
         ! do whatever is necessary for this new value.
         ! i.e. change whatever mesa params you need to adjust.
         ! as example, my_param1 is alpha_mlt
         ! if (i == 1) then
         !    call star_ptr(id, s, ierr)
         !    if (ierr /= 0) return
         !    s% mixing_length_alpha = new_value
         ! end if
      end subroutine will_set_my_param

      
      subroutine extras_startup(id, restart, ierr)
         integer, intent(in) :: id
         logical, intent(in) :: restart
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         call test_suite_startup(s, restart, ierr)

         ! after the test case has run, targets can be generated by the
         ! Python script get_targets.py
         target_a3 = -1.9598354017888975d-18
         target_b1 = -5.6562574033046321d-05
         target_b3 = -1.3718306920267347d-18
         target_p0 = -6.1740066328987266d+00
         target_p1 =  4.2038735981976894d+00
         target_s0 = -4.3564518258795764d-03
         target_s1 =  6.8470233631677164d+00
         target_a_div_r = -4.2567978129788724d+00
         
      end subroutine extras_startup


      subroutine extras_after_evolve(id, ierr)
         use astero_def
         use astero_lib, only: &
            astero_get_one_el_info, &
            astero_interpolate_l0_inertia, &
            astero_get_kjeldsen_radial_freq_corr, &
            astero_get_cubic_all_freq_corr, &
            astero_get_combined_all_freq_corr, &
            astero_get_power_law_all_freq_corr, &
            astero_get_sonoi_all_freq_corr
         real(dp) :: x0, x1
         integer, intent(in) :: id
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         
         logical :: store_model, okay

         integer :: i
         real(dp) :: test_freq(0:3,max_nl)
         character(50) :: fmt
         
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return

         store_model = .true.

         call astero_get_one_el_info(s, 0, &
               nu_lower_factor*freq_target(0,1), &
               nu_upper_factor*freq_target(0,nl(0)), &
               iscan_factor(0)*nl(0), 1, nl(0), store_model, &
               oscillation_code, ierr)
         !write(*,*) 'done astero_get_one_el_info'
         if (ierr /= 0) then
            write(*,*) 'failed to find l=0 modes'
            call mesa_error(__FILE__,__LINE__)
         end if

         call astero_get_one_el_info(s, 1, &
               nu_lower_factor*freq_target(1,1), &
               nu_upper_factor*freq_target(1,nl(1)), &
               iscan_factor(1)*nl(1), 1, nl(1), store_model, &
               oscillation_code, ierr)
         !write(*,*) 'done astero_get_one_el_info'
         if (ierr /= 0) then
            write(*,*) 'failed to find l=1 modes'
            call mesa_error(__FILE__,__LINE__)
         end if

         call astero_get_one_el_info(s, 2, &
               nu_lower_factor*freq_target(2,1), &
               nu_upper_factor*freq_target(2,nl(2)), &
               iscan_factor(2)*nl(2), 1, nl(2), store_model, &
               oscillation_code, ierr)
         !write(*,*) 'done astero_get_one_el_info'
         if (ierr /= 0) then
            write(*,*) 'failed to find l=2 modes'
            call mesa_error(__FILE__,__LINE__)
         end if

         call astero_get_one_el_info(s, 3, &
               nu_lower_factor*freq_target(3,1), &
               nu_upper_factor*freq_target(3,nl(3)), &
               iscan_factor(3)*nl(3), 1, nl(3), store_model, &
               oscillation_code, ierr)
         !write(*,*) 'done astero_get_one_el_info'
         if (ierr /= 0) then
            write(*,*) 'failed to find l=3 modes'
            call mesa_error(__FILE__,__LINE__)
         end if

         ! save the data in case we need to recreate target values
         
         open(newunit=iounit, file='freqs.dat', status='replace', iostat=ierr)
         if (ierr /= 0) then
            write(*,*) 'failed to open iounit'
            call mesa_error(__FILE__,__LINE__)
         end if
         
         write(iounit, '(a5,4a26)') 'l', 'obs', 'obs_sigma', 'freq', 'inertia'
         fmt = '(i5,4es26.16)'

         do i = 1, nl(0)
            write(iounit, fmt) 0, freq_target(0,i), freq_sigma(0,i), model_freq(0,i), model_inertia(0,i)
         end do

         do i = 1, nl(1)
            write(iounit, fmt) 1, freq_target(1,i), freq_sigma(1,i), model_freq(1,i), model_inertia(1,i)
         end do

         do i = 1, nl(2)
            write(iounit, fmt) 2, freq_target(2,i), freq_sigma(2,i), model_freq(2,i), model_inertia(2,i)
         end do

         do i = 1, nl(3)
            write(iounit, fmt) 3, freq_target(3,i), freq_sigma(3,i), model_freq(3,i), model_inertia(3,i)
         end do

         close(iounit)

         write(*,*) ''
         write(*,*) 'comparing to perfect data'
         write(*,*) ''
         write(*,'(4a26)') 'parameter', 'result', 'target', 'result/target-1'
         write(*,*) ''
         okay = .true.

         test_freq = model_freq

         ! call astero_get_kjeldsen_radial_freq_corr( &
         !    a_div_r, correction_b, nu_max, correction_factor, .false., &
         !    nl(0), test_freq(0,:), model_freq(0,:), model_freq_corr(0,:), model_inertia(0,:))
         ! okay = check_okay('a_div_r', a_div_r, target_a_div_r, perfect_tol) .and. okay

         test_freq(0,1:nl(0)) = model_freq(0,1:nl(0)) + target_a3*pow3(model_freq(0,1:nl(0)))/model_inertia(0,1:nl(0))
         test_freq(1,1:nl(1)) = model_freq(1,1:nl(1)) + target_a3*pow3(model_freq(1,1:nl(1)))/model_inertia(1,1:nl(1))
         test_freq(2,1:nl(2)) = model_freq(2,1:nl(2)) + target_a3*pow3(model_freq(2,1:nl(2)))/model_inertia(2,1:nl(2))
         test_freq(3,1:nl(3)) = model_freq(3,1:nl(3)) + target_a3*pow3(model_freq(3,1:nl(3)))/model_inertia(3,1:nl(3))

         call astero_get_cubic_all_freq_corr(x0, .false., &
            nl, test_freq, freq_sigma, model_freq, model_freq_corr, model_inertia)
         okay = check_okay('a3', x0, target_a3, perfect_tol) .and. okay

         test_freq(0,1:nl(0)) = model_freq(0,1:nl(0)) + (target_b1*powm1(model_freq(0,1:nl(0)))+target_b3*pow3(model_freq(0,1:nl(0))))/model_inertia(0,1:nl(0))
         test_freq(1,1:nl(1)) = model_freq(1,1:nl(1)) + (target_b1*powm1(model_freq(1,1:nl(1)))+target_b3*pow3(model_freq(1,1:nl(1))))/model_inertia(1,1:nl(1))
         test_freq(2,1:nl(2)) = model_freq(2,1:nl(2)) + (target_b1*powm1(model_freq(2,1:nl(2)))+target_b3*pow3(model_freq(2,1:nl(2))))/model_inertia(2,1:nl(2))
         test_freq(3,1:nl(3)) = model_freq(3,1:nl(3)) + (target_b1*powm1(model_freq(3,1:nl(3)))+target_b3*pow3(model_freq(3,1:nl(3))))/model_inertia(3,1:nl(3))

         call astero_get_combined_all_freq_corr(x0, x1, .false., &
            nl, test_freq, freq_sigma, model_freq, model_freq_corr, model_inertia)
         okay = check_okay('b3', x0, target_b3, perfect_tol) .and. okay
         okay = check_okay('b1', x1, target_b1, perfect_tol) .and. okay

         do i = 1, nl(0)
            test_freq(0,i) = model_freq(0,i) + target_p0*pow(model_freq(0,i)/nu_max, target_p1)
         end do

         do i = 1, nl(1)
            test_freq(1,i) = model_freq(1,i) + target_p0*pow(model_freq(1,i)/nu_max, target_p1)*astero_interpolate_l0_inertia(model_freq(1,i))/model_inertia(1,i)
         end do

         do i = 1, nl(2)
            test_freq(2,i) = model_freq(2,i) + target_p0*pow(model_freq(2,i)/nu_max, target_p1)*astero_interpolate_l0_inertia(model_freq(2,i))/model_inertia(2,i)
         end do

         do i = 1, nl(3)
            test_freq(3,i) = model_freq(3,i) + target_p0*pow(model_freq(3,i)/nu_max, target_p1)*astero_interpolate_l0_inertia(model_freq(3,i))/model_inertia(3,i)
         end do

         call astero_get_power_law_all_freq_corr(x0, x1, .false., nu_max, &
            nl, test_freq, freq_sigma, model_freq, model_freq_corr, model_inertia)
         okay = check_okay('p0', x0, target_p0, perfect_tol) .and. okay
         okay = check_okay('p1', x1, target_p1, perfect_tol) .and. okay

         do i = 1, nl(0)
            test_freq(0,i) = model_freq(0,i) + target_s0*nu_max*(1d0-1d0/(1d0+pow(model_freq(0,i)/nu_max, target_s1)))
         end do

         do i = 1, nl(1)
            test_freq(1,i) = model_freq(1,i) + target_s0*nu_max*(1d0-1d0/(1d0+pow(model_freq(1,i)/nu_max, target_s1)))*astero_interpolate_l0_inertia(model_freq(1,i))/model_inertia(1,i)
         end do

         do i = 1, nl(2)
            test_freq(2,i) = model_freq(2,i) + target_s0*nu_max*(1d0-1d0/(1d0+pow(model_freq(2,i)/nu_max, target_s1)))*astero_interpolate_l0_inertia(model_freq(2,i))/model_inertia(2,i)
         end do

         do i = 1, nl(3)
            test_freq(3,i) = model_freq(3,i) + target_s0*nu_max*(1d0-1d0/(1d0+pow(model_freq(3,i)/nu_max, target_s1)))*astero_interpolate_l0_inertia(model_freq(3,i))/model_inertia(3,i)
         end do

         call astero_get_sonoi_all_freq_corr(x0, x1, .false., nu_max, &
            nl, test_freq, freq_sigma, model_freq, model_freq_corr, model_inertia)
         okay = check_okay('s0', x0, target_s0, perfect_tol) .and. okay
         okay = check_okay('s1', x1, target_s1, perfect_tol) .and. okay
         
         write(*,*) ''
         if (okay) write(*,*) 'all tests are within tolerances'
         write(*,*) ''

         write(*,*) ''
         write(*,*) 'comparing to solar data'
         write(*,*) ''
         write(*,'(4a26)') 'parameter', 'result', 'target', 'result/target-1'
         write(*,*) ''

         call astero_get_kjeldsen_radial_freq_corr( &
            a_div_r, correction_b, nu_max, correction_factor, .false., &
            nl(0), freq_target(0,:), model_freq(0,:), model_freq_corr(0,:), model_inertia(0,:))
         okay = check_okay('a_div_r', a_div_r, target_a_div_r, solar_tol) .and. okay

         call astero_get_cubic_all_freq_corr(x0, .false., &
            nl, freq_target, freq_sigma, model_freq, model_freq_corr, model_inertia)
         okay = check_okay('a3', x0, target_a3, solar_tol) .and. okay

         call astero_get_combined_all_freq_corr(x0, x1, .false., &
            nl, freq_target, freq_sigma, model_freq, model_freq_corr, model_inertia)
         okay = check_okay('b3', x0, target_b3, solar_tol) .and. okay
         okay = check_okay('b1', x1, target_b1, solar_tol) .and. okay

         call astero_get_power_law_all_freq_corr(x0, x1, .false., nu_max, &
            nl, freq_target, freq_sigma, model_freq, model_freq_corr, model_inertia)
         okay = check_okay('p0', x0, target_p0, solar_tol) .and. okay
         okay = check_okay('p1', x1, target_p1, solar_tol) .and. okay

         call astero_get_sonoi_all_freq_corr(x0, x1, .false., nu_max, &
            nl, freq_target, freq_sigma, model_freq, model_freq_corr, model_inertia)
         okay = check_okay('s0', x0, target_s0, solar_tol) .and. okay
         okay = check_okay('s1', x1, target_s1, solar_tol) .and. okay

         write(*,*) ''
         
         call test_suite_after_evolve(s, ierr)

       contains

         logical function check_okay(name, val, tgt, tol)
           real(dp), intent(in) :: val, tgt, tol
           character(len=*), intent(in) :: name
           
           if (abs(val/tgt-1d0) < tol) then
              write(*,'(a26,3(1pd26.16))') name, val, tgt, val/tgt-1d0
              check_okay = .true.
           else
              write(*,'(a26,3(1pd26.16),a10)') name, val, tgt, val/tgt-1d0, 'FAILED'
              check_okay = .false.
           end if
              
         end function check_okay
         
      end subroutine extras_after_evolve
      

      ! returns either keep_going, retry, or terminate.
      integer function extras_check_model(id)
         integer, intent(in) :: id
         integer :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         extras_check_model = keep_going         
         if (.false. .and. s% star_mass_h1 < 0.35d0) then
            ! stop when star hydrogen mass drops to specified level
            extras_check_model = terminate
            write(*, *) 'have reached desired hydrogen mass'
            return
         end if


         ! if you want to check multiple conditions, it can be useful
         ! to set a different termination code depending on which
         ! condition was triggered.  MESA provides 9 customizeable
         ! termination codes, named t_xtra1 .. t_xtra9.  You can
         ! customize the messages that will be printed upon exit by
         ! setting the corresponding termination_code_str value.
         ! termination_code_str(t_xtra1) = 'my termination condition'

         ! by default, indicate where (in the code) MESA terminated
         if (extras_check_model == terminate) s% termination_code = t_extras_check_model
      end function extras_check_model
      
      
      subroutine set_my_param(s, i, new_value)
         type (star_info), pointer :: s
         integer, intent(in) :: i ! which of my_param's will be set
         real(dp), intent(in) :: new_value
         include 'formats'
         ! old value has not yet been changed.
         ! do whatever is necessary for this new value.
         ! i.e. change whatever mesa params you need to adjust.
         ! for example, my_param1 is mass
         if (i == 1) then
            s% job% new_mass = new_value
         end if
         
      end subroutine set_my_param


      integer function how_many_extra_history_columns(id)
         integer, intent(in) :: id
         integer :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         how_many_extra_history_columns = 0
      end function how_many_extra_history_columns
      
      
      subroutine data_for_extra_history_columns(id, n, names, vals, ierr)
         integer, intent(in) :: id, n
         character (len=maxlen_history_column_name) :: names(n)
         real(dp) :: vals(n)
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
      end subroutine data_for_extra_history_columns

      
      integer function how_many_extra_profile_columns(id)
         use star_def, only: star_info
         integer, intent(in) :: id
         integer :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         how_many_extra_profile_columns = 0
      end function how_many_extra_profile_columns
      
      
      subroutine data_for_extra_profile_columns(id, n, nz, names, vals, ierr)
         use star_def, only: star_info, maxlen_profile_column_name
         use const_def, only: dp
         integer, intent(in) :: id, n, nz
         character (len=maxlen_profile_column_name) :: names(n)
         real(dp) :: vals(nz,n)
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         integer :: k
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
      end subroutine data_for_extra_profile_columns
      

      ! returns either keep_going or terminate.
      integer function extras_finish_step(id)
         integer, intent(in) :: id
         integer :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call star_ptr(id, s, ierr)
         if (ierr /= 0) return
         extras_finish_step = keep_going
      end function extras_finish_step
      
      

      end module run_star_extras
