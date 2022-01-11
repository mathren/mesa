! ***********************************************************************
!
!   Copyright (C) 2010-2021  The MESA Team
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


module tdc

use const_def
use num_lib
use utils_lib
use auto_diff
use star_data_def
use tdc_support

implicit none

private
public :: get_TDC_solution

contains


   !> Computes the outputs of time-dependent convection theory following the model specified in
   !! Radek Smolec's thesis [https://users.camk.edu.pl/smolec/phd_smolec.pdf], which in turn
   !! follows the model of Kuhfuss 1986.
   !!
   !! Internally this solves the equation L = L_conv + L_rad.
   !!
   !! @param conv_vel_start The convection speed at the start of the step.
   !! @param mixing_length_alpha The mixing length parameter.
   !! @param alpha_TDC_DAMP TDC turbulent damping parameter
   !! @param alpha_TDC_DAMPR TDC radiative damping parameter
   !! @param alpha_TDC_PtdVdt TDC coefficient on P_turb*dV/dt. Physically should probably be 1.
   !! @param The time-step (s).
   !! @param cgrav gravitational constant (erg*cm/g^2).
   !! @param m Mass inside the face (g).
   !! @param report Write debug output if true, not if false.
   !! @param mixing_type Set to semiconvective if convection operates (output).
   !! @param scale The scale for computing residuals to the luminosity equation (erg/s).
   !! @param L Luminosity across a face (erg/s).
   !! @param r radial coordinate of the face (cm).
   !! @param P pressure (erg/cm^3).
   !! @param T temperature (K).
   !! @param rho density (g/cm^3).
   !! @param dV The change in specific volume of the face (cm^3/g) since the start of the step.
   !! @param Cp Specific heat at constant pressure (erg/g/K).
   !! @param opacity opacity (cm^2/g).
   !! @param scale_height The pressure scale-height (cm).
   !! @param gradL The Ledoux temperature gradient dlnT/dlnP
   !! @param grada The adiabatic temperature gradient dlnT/dlnP|s
   !! @param Zlb Lower bound on Z.
   !! @param Zub Upper bound on Z.
   !! @param conv_vel The convection speed (cm/s).
   !! @param Y_face The superadiabaticity (dlnT/dlnP - grada, output).
   !! @param tdc_num_iters Number of iterations taken in the TDC solver.
   !! @param ierr Tracks errors (output).
   subroutine get_TDC_solution( &
         conv_vel_start, mixing_length_alpha, alpha_TDC_DAMP, alpha_TDC_DAMPR, alpha_TDC_PtdVdt, dt, cgrav, m, report, &
         mixing_type, scale, L_in, r, P, T, rho, dV, Cp, kap, Hp, gradL_in, grada_in, Zlb, Zub, conv_vel, Y_face, tdc_num_iters, ierr)
      real(dp), intent(in) :: conv_vel_start, mixing_length_alpha, alpha_TDC_DAMP, alpha_TDC_DAMPR, alpha_TDC_PtdVdt, dt, cgrav, m, scale, Zlb, Zub
      type(auto_diff_real_star_order1), intent(in) :: &
         L_in, r, P, T, rho, dV, Cp, kap, Hp, gradL_in, grada_in
      logical, intent(in) :: report
      type(auto_diff_real_star_order1),intent(out) :: conv_vel, Y_face
      integer, intent(out) :: mixing_type, tdc_num_iters, ierr
      
      type(auto_diff_real_tdc) :: L, gradL, grada, c0, L0, A0
      type(auto_diff_real_tdc) :: Af, Y, Z0, radY
      type(auto_diff_real_tdc) :: dQdZ, prev_dQdZ, Q0
      integer :: iter
      integer, parameter :: max_iter = 30
      include 'formats'

      ierr = 0
      if (mixing_length_alpha == 0d0 .or. dt <= 0d0) then
         call mesa_error(__FILE__,__LINE__,'bad call to TDC get_TDC_solution')
      end if         

      ! Set up inputs.
      L = convert(L_in)
      gradL = convert(gradL_in)
      grada = convert(grada_in)
      c0 = convert(mixing_length_alpha*alpha_c*rho*T*Cp*4d0*pi*pow2(r))
      L0 = convert((16d0*pi*crad*clight/3d0)*cgrav*m*pow4(T)/(P*kap)) ! assumes QHSE for dP/dm
      A0 = conv_vel_start/sqrt_2_div_3

      ! Determine the sign of the solution.
      !
      ! If Q(Y=0) is positive then the luminosity is too great to be carried radiatively, so
      ! we'll necessarily have Y > 0.
      !
      ! If Q(Y=0) is negative then the luminosity can be carried by radiation alone, so we'll
      ! necessarily have Y < 0.
      Y = 0d0
      call compute_Q(mixing_length_alpha, alpha_TDC_DAMP, alpha_TDC_DAMPR, alpha_TDC_PtdVdt, dt, &
         Y, c0, L, L0, A0, T, rho, dV, Cp, kap, Hp, gradL, grada, Q0, Af)
      if (Q0 > 0d0) then
         Y_is_positive = .true.
      else
         Y_is_positive = .false.
      end if

      ! Start down the chain of logic...
      if (Y_is_positive) then
         ! If Y > 0 then Q(Y) is monotone and we can jump straight to the search.
         call bracket_plus_Newton_search( &
            Y_is_positive, conv_vel_start, mixing_length_alpha, alpha_TDC_DAMP, alpha_TDC_DAMPR, alpha_TDC_PtdVdt, dt, cgrav, m, report, &
            mixing_type, scale, L_in, r, P, T, rho, dV, Cp, kap, Hp, gradL_in, grada_in, Zlb, Zub, Y_face, Af, tdc_num_iters, ierr)
      else
         ! If Y < 0 then Q(Y) is not guaranteed to be monotone, so we have to be more careful.
         ! One root we could have is the radiative solution (with Af==0), given by
         radY = (L - L0 * gradL) / L0

         ! If A0 == 0 then, because Af(Y) is monotone-increasing in Y, we know that for Y < 0, Af(Y) = 0.
         ! As a result we can directly write down the solution and get just radY.
         if (A0 == 0) then
            Y = radY
         else
            ! Otherwise, we keep going.
            ! We next identify the point where Af(Y) = 0. Call this Y0, corresponding to Z0.
            call Af_bisection_search(mixing_length_alpha, alpha_TDC_DAMP, alpha_TDC_DAMPR, alpha_TDC_PtdVdt, dt, &
                                    lower_bound_Z, upper_bound_Z, c0, L, L0, A0, T, rho, dV, Cp, kap, Hp, gradL, grada, Z0, Af)
            Y0 = set_Y(.false., Z0)

            ! We next need to do a bracket search for where dQdZ = 0 over the interval [Y0,0] (equivalently from Z=lower_bound to Z=Z0).

      end if



      ! Process Y into the various outputs.
      conv_vel = sqrt_2_div_3*unconvert(Af)   
      if (conv_vel > 0d0) then
         mixing_type = convective_mixing
      else
         mixing_type = no_mixing
      end if
   end subroutine get_TDC_solution

   !> Performs a bracket search for the solution to Q=0 over
   !! a domain in which Q is guaranteed to be monotone. Then
   !! refines the result with a Newton solver to both get a better
   !! solution and endow the solution with partial derivatives.
   !!
   !! @param conv_vel_start The convection speed at the start of the step.
   !! @param mixing_length_alpha The mixing length parameter.
   !! @param alpha_TDC_DAMP TDC turbulent damping parameter
   !! @param alpha_TDC_DAMPR TDC radiative damping parameter
   !! @param alpha_TDC_PtdVdt TDC coefficient on P_turb*dV/dt. Physically should probably be 1.
   !! @param The time-step (s).
   !! @param cgrav gravitational constant (erg*cm/g^2).
   !! @param m Mass inside the face (g).
   !! @param report Write debug output if true, not if false.
   !! @param mixing_type Set to semiconvective if convection operates (output).
   !! @param scale The scale for computing residuals to the luminosity equation (erg/s).
   !! @param L Luminosity across a face (erg/s).
   !! @param r radial coordinate of the face (cm).
   !! @param P pressure (erg/cm^3).
   !! @param T temperature (K).
   !! @param rho density (g/cm^3).
   !! @param dV The change in specific volume of the face (cm^3/g) since the start of the step.
   !! @param Cp Specific heat at constant pressure (erg/g/K).
   !! @param opacity opacity (cm^2/g).
   !! @param scale_height The pressure scale-height (cm).
   !! @param gradL The Ledoux temperature gradient dlnT/dlnP
   !! @param grada The adiabatic temperature gradient dlnT/dlnP|s
   !! @param Zlb Lower bound on Z.
   !! @param Zub Upper bound on Z.
   !! @param Y_face The superadiabaticity (dlnT/dlnP - grada, output).
   !! @param tdc_num_iters Number of iterations taken in the TDC solver.
   !! @param ierr Tracks errors (output).
   subroutine bracket_plus_Newton_search( &
         Y_is_positive, conv_vel_start, mixing_length_alpha, alpha_TDC_DAMP, alpha_TDC_DAMPR, alpha_TDC_PtdVdt, dt, cgrav, m, report, &
         mixing_type, scale, L_in, r, P, T, rho, dV, Cp, kap, Hp, gradL_in, grada_in, Zlb, Zub, Y_face, Af, tdc_num_iters, ierr)
      logical, intent(in) :: Y_is_positive
      real(dp), intent(in) :: conv_vel_start, mixing_length_alpha, alpha_TDC_DAMP, alpha_TDC_DAMPR, alpha_TDC_PtdVdt, dt, cgrav, m, scale, Zlb, Zub
      type(auto_diff_real_star_order1), intent(in) :: &
         L_in, r, P, T, rho, dV, Cp, kap, Hp, gradL_in, grada_in
      logical, intent(in) :: report
      type(auto_diff_real_star_order1),intent(out) :: Y_face, Af
      integer, intent(out) :: tdc_num_iters, ierr
      
      type(auto_diff_real_tdc) :: L, A0, c0, L0, Y, Z, Q, Q_lb, Q_ub, Qc, Z_new, correction, lower_bound_Z, upper_bound_Z
      type(auto_diff_real_tdc) :: dQdZ, prev_dQdZ, gradL, grada, Q0
      integer :: iter, line_iter, i
      logical :: converged, first_Q_is_positive, have_derivatives, corr_has_derivatives
      real(dp), parameter :: correction_tolerance = 1d-13
      real(dp), parameter :: residual_tolerance = 1d-8
      real(dp), parameter :: alpha_c = (1d0/2d0)*sqrt_2_div_3
      integer, parameter :: max_iter = 200
      integer, parameter :: max_line_search_iter = 5
      include 'formats'

      ! Set up inputs.
      L = convert(L_in)
      gradL = convert(gradL_in)
      grada = convert(grada_in)
      c0 = convert(mixing_length_alpha*alpha_c*rho*T*Cp*4d0*pi*pow2(r))
      L0 = convert((16d0*pi*crad*clight/3d0)*cgrav*m*pow4(T)/(P*kap)) ! assumes QHSE for dP/dm
      A0 = conv_vel_start/sqrt_2_div_3

      ! We start by bisecting to find a narrow interval around the root.
      lower_bound_Z = Zlb
      upper_bound_Z = Zub

      ! Perform bisection search.
      call Q_bisection_search(mixing_length_alpha, alpha_TDC_DAMP, alpha_TDC_DAMPR, alpha_TDC_PtdVdt, dt, &
                              Y_is_positive, lower_bound_Z, upper_bound_Z, Q_ub, Q_lb, &
                              c0, L, L0, A0, T, rho, dV, Cp, kap, Hp, gradL, grada, ierr)
      if (ierr /= 0) return
      Z = (upper_bound_Z + lower_bound_Z) / 2d0
      Z%d1val1 = 1d0 ! Set derivative dZ/dZ=1 for Newton iterations.
      if (report) write(*,*) 'Z from bracket search', Z%val

      ! Now we refine the solution with a Newton solve.
      ! This also let's us pick up the derivative of the solution with respect
      ! to input parameters.

      ! Initialize starting values for TDC Newton iterations.
      dQdz = 0d0
      converged = .false.
      have_derivatives = .false. ! Tracks if we've done at least one un-clipped Newton iteration.
                                 ! Need to do this before returning to endow Y with partials
                                 ! with respect to the structure variables.
      do iter = 1, max_iter
         Y = set_Y(Y_is_positive, Z)
         call compute_Q(mixing_length_alpha, alpha_TDC_DAMP, alpha_TDC_DAMPR, alpha_TDC_PtdVdt, dt, &
            Y, c0, L, L0, A0, T, rho, dV, Cp, kap, Hp, gradL, grada, Q, Af)

         if (abs(Q%val)/scale <= residual_tolerance .and. have_derivatives) then
            ! Can't exit on the first iteration, otherwise we have no derivative information.
            if (report) write(*,2) 'converged', iter, abs(Q%val)/scale, residual_tolerance
            converged = .true.
            exit
         end if

         ! We use the fact that Q(Y) is monotonic to iteratively refined bounds on Q.
         if (Q > 0d0) then
            ! Q(Y) is monotonic so this means Z is a lower-bound.
            lower_bound_Z = Z
         else
            ! Q(Y) is monotonic so this means Z is an upper-bound.
            upper_bound_Z = Z
         end if

         prev_dQdZ = dQdZ
         dQdZ = differentiate_1(Q)
         if (is_bad(dQdZ%val) .or. abs(dQdZ%val) < 1d-99) then
            ierr = 1
            exit
         end if

         correction = -Q/dQdz
         corr_has_derivatives = .true.

         ! Do a line search to avoid steps that are too big.
         do line_iter=1,max_line_search_iter

            if (abs(correction) < correction_tolerance .and. have_derivatives) then
               ! Can't get much more precision than this.
               converged = .true.
               exit
            end if

            Z_new = Z + correction
            if (corr_has_derivatives) then
               have_derivatives = .true.
            end if

            ! If the correction pushes the solution out of bounds then we know
            ! that was a bad step. Bad steps are still in the same direction, they just
            ! go too far, so we replace that result with one that's halfway to the relevant bound.
            if (Z_new > upper_bound_Z) then
               Z_new = (Z + upper_bound_Z) / 2d0
            else if (Z_new < lower_bound_Z) then
               Z_new = (Z + lower_bound_Z) / 2d0
            end if

            Y = set_Y(Y_is_positive,Z_new)

            call compute_Q(mixing_length_alpha, alpha_TDC_DAMP, alpha_TDC_DAMPR, alpha_TDC_PtdVdt, dt, &
            Y, c0, L, L0, A0, T, rho, dV, Cp, kap, Hp, gradL, grada, Qc, Af)

            if (abs(Qc) < abs(Q)) then
               exit
            else
               correction = 0.5d0 * correction
            end if
         end do

         if (report) write(*,3) 'i, li, Z_new, Z, low_bnd, upr_bnd, Q, dQdZ, pdQdZ, corr', iter, line_iter, &
            Z_new%val, Z%val, lower_bound_Z%val, upper_bound_Z%val, Q%val, dQdZ%val, prev_dQdZ%val, correction%val
         Z_new%d1val1 = 1d0 ! Ensures that dZ/dZ = 1.
         Z = Z_new

         Y = set_Y(Y_is_positive,Z)

      end do

      if (.not. converged) then
         ierr = 1
         if (report) then
         !$OMP critical (tdc_crit0)
            write(*,*) 'failed get_TDC_solution TDC_iter', &
               iter
            write(*,*) 'scale', scale
            write(*,*) 'Q/scale', Q%val/scale
            write(*,*) 'tolerance', residual_tolerance
            write(*,*) 'dQdZ', dQdZ%val
            write(*,*) 'Y', Y%val
            write(*,*) 'dYdZ', Y%d1val1
            write(*,*) 'exp(Z)', exp(Z%val)
            write(*,*) 'Z', Z%val
            write(*,*) 'Af', Af%val
            write(*,*) 'dAfdZ', Af%d1val1
            write(*,*) 'A0', A0%val
            write(*,*) 'c0', c0%val
            write(*,*) 'L', L%val
            write(*,*) 'L0', L0%val
            write(*,*) 'grada', grada%val
            write(*,*) 'gradL', gradL%val
            write(*,'(A)')
         !$OMP end critical (tdc_crit0)
         end if
         return
      end if

      ! Unpack output
      Y_face = unconvert(Y)
      tdc_num_iters = iter          
   end subroutine get_TDC_solution
         

   !> Q is the residual in the TDC equation, namely:
   !!
   !! Q = (L - L0 * gradL) - (L0 + c0 * Af) * Y
   !!
   !! @param mixing_length_alpha Mixing length parameter
   !! @param alpha_TDC_DAMP TDC turbulent damping parameter
   !! @param alpha_TDC_DAMPR TDC radiative damping parameter
   !! @param alpha_TDC_PtdVdt TDC coefficient on P_turb*dV/dt. Physically should probably be 1.
   !! @param dt Time-step
   !! @param Y superadiabaticity
   !! @param c0_in A proportionality factor for the convective luminosity
   !! @param L_in luminosity
   !! @param L0_in L0 = (Lrad / grad_rad) is the luminosity radiation would carry if dlnT/dlnP = 1.
   !! @param A0 Initial convection speed
   !! @param T Temperature
   !! @param rho Density (g/cm^3)
   !! @param dV 1/rho_face - 1/rho_start_face (change in specific volume at the face)
   !! @param Cp Heat capacity
   !! @param kap Opacity
   !! @param Hp Pressure scale height
   !! @param gradL_in gradL is the neutrally buoyant dlnT/dlnP (= grad_ad + grad_mu),
   !! @param grada_in grada is the adiabatic dlnT/dlnP,
   !! @param Q The residual of the above equaiton (an output).
   !! @param Af The final convection speed (an output).
   subroutine compute_Q(mixing_length_alpha, alpha_TDC_DAMP, alpha_TDC_DAMPR, alpha_TDC_PtdVdt, dt, &
         Y, c0, L, L0, A0, T, rho, dV, Cp, kap, Hp, gradL, grada, Q, Af)
      real(dp), intent(in) :: mixing_length_alpha, alpha_TDC_DAMP, alpha_TDC_DAMPR, alpha_TDC_PtdVdt, dt
      type(auto_diff_real_star_order1), intent(in) :: &
         T, rho, dV, Cp, kap, Hp
      type(auto_diff_real_tdc), intent(in) :: A0, Y, c0, L, L0, gradL, grada
      type(auto_diff_real_tdc), intent(out) :: Q, Af
      type(auto_diff_real_tdc) :: xi0, xi1, xi2

      call eval_xis(mixing_length_alpha, alpha_TDC_DAMP, alpha_TDC_DAMPR, alpha_TDC_PtdVdt, dt, &
         Y, T, rho, Cp, dV, kap, Hp, grada, xi0, xi1, xi2)          

      Af = eval_Af(dt, A0, xi0, xi1, xi2)
      Q = (L - L0*gradL) - (L0 + c0*Af)*Y

   end subroutine compute_Q

   !! Calculates the coefficients of the TDC velocity equation.
   !! The velocity equation is
   !!
   !! 2 dw/dt = xi0 + w * xi1 + w**2 * xi2 - Lambda
   !!
   !! where Lambda (currently set to zero) captures coupling between cells.
   !!
   !! The coefficients xi0/1/2 are given by
   !!
   !! xi0 = (epsilon_q + S * Y) / w
   !! xi1 = (-D_r + p_turb dV/dt) / w^2    [here V = 1/rho is the volume]
   !! xi2 = -D / w^3
   !!
   !! Note that these terms are evaluated on faces, because the convection speed
   !! is evaluated on faces. As a result all the inputs must either natively
   !! live on faces or be interpolated to faces.
   !!
   !! This function also has some side effects in terms of storing some of the terms
   !! it calculates for plotting purposes.
   !!
   !! @param mixing_length_alpha Mixing length parameter
   !! @param alpha_TDC_DAMP TDC turbulent damping parameter
   !! @param alpha_TDC_DAMPR TDC radiative damping parameter
   !! @param alpha_TDC_PtdVdt TDC coefficient on P_turb*dV/dt. Physically should probably be 1.
   !! @param dt Time-step
   !! @param Y superadiabaticity
   !! @param T temperature (K)
   !! @param rho density (g/cm^3)
   !! @param Cp heat capacity (erg/g/K)
   !! @param dV 1/rho_face - 1/rho_start_face (change in specific volume at the face)
   !! @param kap opacity (cm^2/g)
   !! @param Hp pressure scale height (cm)
   !! @param grada is the adiabatic dlnT/dlnP.
   !! @param xi0 Output, the constant term in the convective velocity equation.
   !! @param xi1 Output, the prefactor of the linear term in the convective velocity equation.
   !! @param xi2 Output, the prefactor of the quadratic term in the convective velocity equation.
   subroutine eval_xis(mixing_length_alpha, alpha_TDC_DAMP, alpha_TDC_DAMPR, alpha_TDC_PtdVdt, dt, &
         Y, T, rho, Cp, dV, kap, Hp, grada, xi0, xi1, xi2) 
      ! eval_xis sets up Y with partial wrt Z
      ! so results come back with partials wrt Z
      real(dp), intent(in) :: mixing_length_alpha, alpha_TDC_DAMP, alpha_TDC_DAMPR, alpha_TDC_PtdVdt, dt
      type(auto_diff_real_star_order1), intent(in) :: T, rho, dV, Cp, kap, Hp
      type(auto_diff_real_tdc), intent(in) :: Y, grada
      type(auto_diff_real_tdc), intent(out) :: xi0, xi1, xi2
      type(auto_diff_real_tdc) :: S0, D0, DR0
      type(auto_diff_real_star_order1) :: gammar_div_alfa, Pt0, dVdt
      real(dp), parameter :: x_ALFAS = (1.d0/2.d0)*sqrt_2_div_3
      real(dp), parameter :: x_CEDE  = (8.d0/3.d0)*sqrt_2_div_3
      real(dp), parameter :: x_ALFAP = 2.d0/3.d0
      real(dp), parameter :: x_GAMMAR = 2.d0*sqrt(3.d0)

      S0 = convert(x_ALFAS*mixing_length_alpha*Cp*T/Hp)*grada
      S0 = S0*Y
      D0 = convert(alpha_TDC_DAMP*x_CEDE/(mixing_length_alpha*Hp))
      gammar_div_alfa = alpha_TDC_DAMPR*x_GAMMAR/(mixing_length_alpha*Hp)
      DR0 = convert(4d0*boltz_sigma*pow2(gammar_div_alfa)*pow3(T)/(pow2(rho)*Cp*kap))
      Pt0 = alpha_TDC_PtdVdt*x_ALFAP*rho
      if (dt > 0) then
         dVdt = dV/dt
      else
         dVdt = 0d0
      end if
      xi0 = S0
      xi1 = -(DR0 + convert(Pt0*dVdt))
      xi2 = -D0
   end subroutine eval_xis

   !! Calculates the solution to the TDC velocity equation.
   !! The velocity equation is
   !!
   !! 2 dw/dt = xi0 + w * xi1 + w**2 * xi2 - Lambda
   !!
   !! where Lambda (currently set to zero) captures coupling between cells.
   !! The xi0/1/2 variables are constants for purposes of solving this equation.
   !!
   !! An important related parameter is J:
   !! 
   !! J^2 = xi1^2 - 4 * xi0 * xi2
   !!
   !! When J^2 > 0 the solution for w is hyperbolic in time.
   !! When J^2 < 0 the solution is trigonometric, behaving like tan(J * t / 4 + c).
   !!
   !! In the trigonometric branch note that once the solution passes through its first
   !! root the solution for all later times is w(t) = 0. This is not a solution to the
   !! convective velocity equation as written above, but *is* a solution to the convective
   !! energy equation (multiply the velocity equation by w), which is the one we actually
   !! want to solve (per Radek Smolec's thesis). We just solve the velocity form
   !! because it's more convenient.
   !!
   !! @param dt Time-step
   !! @param A0 convection speed from the start of the step (cm/s)
   !! @param xi0 The constant term in the convective velocity equation.
   !! @param xi1 The prefactor of the linear term in the convective velocity equation.
   !! @param xi2 The prefactor of the quadratic term in the convective velocity equation.            
   !! @param Af Output, the convection speed at the end of the step (cm/s)
   function eval_Af(dt, A0, xi0, xi1, xi2) result(Af)
      real(dp), intent(in) :: dt    
      type(auto_diff_real_tdc), intent(in) :: A0, xi0, xi1, xi2
      type(auto_diff_real_tdc) :: Af ! output
      type(auto_diff_real_tdc) :: J2, J, Jt, Jt4, num, den, y_for_atan, root, lk 

      J2 = pow2(xi1) - 4d0 * xi0 * xi2

      if (J2 > 0d0) then ! Hyperbolic branch
         J = sqrt(J2)
         Jt = dt * J
         Jt4 = 0.25d0 * Jt
         num = safe_tanh(Jt4) * (2d0 * xi0 + A0 * xi1) + A0 * J
         den = safe_tanh(Jt4) * (xi1 + 2d0 * A0 * xi2) - J
         Af = num / den 
         if (Af < 0d0) then
            Af = -Af
         end if
      else if (J2 < 0d0) then ! Trigonometric branch
         J = sqrt(-J2)
         Jt = dt * J

         ! This branch contains decaying solutions that reach A = 0, at which point
         ! they switch onto the 'zero' branch. So we have to calculate the position of
         ! the first root to check it against dt.
         y_for_atan = xi1 + 2d0 * A0 * xi2
         root = safe_atan(J, xi1) - safe_atan(J, y_for_atan)

         ! The root enters into a tangent, so we can freely shift it by pi and
         ! get another root. We care about the first positive root, and the above prescription
         ! is guaranteed to give an answer between (-2*pi,2*pi) because atan produces an answer in [-pi,pi],
         ! so we add/subtract a multiple of pi to get the root into [0,pi).
         if (root > pi) then
            root = root - pi
         else if (root < -pi) then
            root = root + 2d0*pi
         else if (root < 0d0) then
            root = root + pi
         end if

         if (0.25d0 * Jt < root) then
            num = -xi1 + J * tan(0.25d0 * Jt + atan(y_for_atan / J)) 
            den = 2d0 * xi2
            Af = num / den
         else
            Af = 0d0
         end if
      else ! if (J2 == 0d0) then         
         Af = A0            
      end if

   end function eval_Af



end module tdc
