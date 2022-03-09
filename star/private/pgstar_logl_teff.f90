! ***********************************************************************
!
!   Copyright (C) 2014  The MESA Team
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

      module pgstar_logL_Teff

      use star_private_def
      use const_def
      use pgstar_support
      use star_pgstar

      implicit none


      contains


      subroutine logL_Teff_Plot(id, device_id, ierr)
         integer, intent(in) :: id, device_id
         integer, intent(out) :: ierr
         type (star_info), pointer :: s
         ierr = 0
         call get_star_ptr(id, s, ierr)
         if (ierr /= 0) return

         call pgslct(device_id)
         call pgbbuf()
         call pgeras()

         call do_logL_Teff_Plot(s, id, device_id, &
            s% pg% logL_Teff_xleft, s% pg% logL_Teff_xright, &
            s% pg% logL_Teff_ybot, s% pg% logL_Teff_ytop, .false., &
            s% pg% logL_Teff_title, s% pg% logL_Teff_txt_scale, ierr)
         if (ierr /= 0) return

         call pgebuf()

      end subroutine logL_Teff_Plot


      subroutine do_logL_Teff_Plot(s, id, device_id, &
            xleft, xright, ybot, ytop, subplot, &
            title, txt_scale, ierr)
         use pgstar_hist_track, only: null_decorate, do_Hist_Track
         type (star_info), pointer :: s
         integer, intent(in) :: id, device_id
         real, intent(in) :: xleft, xright, ybot, ytop, txt_scale
         logical, intent(in) :: subplot
         character (len=*), intent(in) :: title
         integer, intent(out) :: ierr
         logical, parameter :: &
            reverse_xaxis = .true., reverse_yaxis = .false.
         ierr = 0
         call do_Hist_Track(s, id, device_id, &
            xleft, xright, ybot, ytop, subplot, title, txt_scale, &
            'effective_T', 'log_L', &
            'Teff', 'log L/L\d\(2281)', &
            s% pg% logL_Teff_Teff_min, s% pg% logL_Teff_Teff_max, &
            s% pg% logL_Teff_Teff_margin, s% pg% logL_Teff_dTeff_min, &
            s% pg% logL_Teff_logL_min, s% pg% logL_Teff_logL_max, &
            s% pg% logL_Teff_logL_margin, s% pg% logL_Teff_dlogL_min, &
            s% pg% logL_Teff_step_min, s% pg% logL_Teff_step_max, &
            reverse_xaxis, reverse_yaxis, .false., .false., &
            s% pg% show_logL_Teff_target_box, s% pg% logL_Teff_target_n_sigma, &
            s% pg% logL_Teff_target_Teff, s% pg% logL_Teff_target_logL, &
            s% pg% logL_Teff_target_Teff_sigma, s% pg% logL_Teff_target_logL_sigma, &
            s% pg% show_logL_Teff_annotation1, &
            s% pg% show_logL_Teff_annotation2, &
            s% pg% show_logL_Teff_annotation3, &
            s% pg% logL_Teff_fname, &
            s% pg% logL_Teff_use_decorator, &
            s% pg% logL_Teff_pgstar_decorator, &
            null_decorate, ierr)
      end subroutine do_logL_Teff_Plot


      end module pgstar_logL_Teff

