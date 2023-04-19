! ***********************************************************************
!
!   Copyright (C) 2012  The MESA Team
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

module other_j_for_adjust_J_lost

   ! consult star/other/README for general usage instructions
   ! control name: use_other_j_for_adjust_J_lost = .true.
   ! procedure pointer: s% other_j_for_adjust_J_lost => my_routine

   implicit none


contains

   ! your routine will be called after winds and before mass adjustment

   subroutine null_other_j_for_adjust_J_lost(id, starting_j_rot_surf, j_for_mass_loss, ierr)
      use star_def
      integer, intent(in) :: id
      real(dp), intent(in) :: starting_j_rot_surf
      real(dp), intent(out) :: j_for_mass_loss
      integer, intent(out) :: ierr
      write(*, *) 'no implementation for other_j_for_adjust_J_lost'
      ierr = -1
      j_for_mass_loss = -1d99
   end subroutine null_other_j_for_adjust_J_lost


end module other_j_for_adjust_J_lost
      
      
      
      
