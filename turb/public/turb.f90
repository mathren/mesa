module turb
   use const_def
   use num_lib
   use utils_lib
   use auto_diff

   implicit none

   private
   public :: set_thermohaline, set_mlt, set_tdc, set_semiconvection, &
        thermohaline_mode_properties, calc_hg19_w, calc_frg24_w, thermohaline_nusseltC

   contains

   !> Computes the diffusivity of thermohaline mixing when the
   !! thermal gradient is stable and the composition gradient is unstable.
   !!
   !! @param thermohaline_option A string specifying which thermohaline prescription to use.
   !! @param grada Adiabatic gradient dlnT/dlnP
   !! @param gradr Radiative temperature gradient dlnT/dlnP, equals the actual gradient because there's no convection
   !! @param N2_T Structure part of brunt squared (excludes composition term)
   !! @param T Temperature
   !! @param opacity opacity
   !! @param rho Density
   !! @param Cp Heat capacity at constant pressure
   !! @param gradL_composition_term dlnMu/dlnP where Mu is the mean molecular weight.
   !! @param iso The index of the species that drives thermohaline mixing.
   !! @param XH1 Mass fraction of H1.
   !! @param thermohaline_coeff Free parameter multiplying the thermohaline diffusivity.
   !! @param D_thrm Output, diffusivity.
   !! @param ierr Output, error index.
   subroutine set_thermohaline(thermohaline_option, Lambda, grada, gradr, N2_T, T, opacity, rho, Cp, gradL_composition_term, &
                              iso, XH1, thermohaline_coeff, &
                              D, gradT, Y_face, conv_vel, mixing_type, ierr)
      use thermohaline
      character(len=*), intent(in) :: thermohaline_option
      type(auto_diff_real_star_order1), intent(in) :: Lambda, grada, gradr, N2_T, T, opacity, rho, Cp
      real(dp), intent(in) :: gradL_composition_term, XH1, thermohaline_coeff
      integer, intent(in) :: iso

      type(auto_diff_real_star_order1), intent(out) :: gradT, Y_face, conv_vel, D
      integer, intent(out) :: mixing_type, ierr

      real(dp) :: D_thrm

      call get_D_thermohaline(&
         thermohaline_option, grada%val, gradr%val, N2_T%val, T%val, opacity%val, rho%val, &
         Cp%val, gradL_composition_term, &
         iso, XH1, thermohaline_coeff, D_thrm, ierr)

      D = D_thrm
      gradT = gradr
      Y_face = gradT - grada
      conv_vel = 3d0*D/Lambda
      mixing_type = thermohaline_mixing 
   end subroutine set_thermohaline

   !! Helper functions used in turb/plotter for plotting mixing in terms of dimensionless parameters
   subroutine thermohaline_mode_properties(Pr, tau, R0, lamhat, l2hat, ierr, method)
     use fingering_modes

     real(dp), intent(in)               :: Pr
     real(dp), intent(in)               :: tau
     real(dp), intent(in)               :: R0
     real(dp), intent(out)              :: lamhat
     real(dp), intent(out)              :: l2hat
     integer, intent(out)               :: ierr
     character(*), intent(in), optional :: method

     real(dp) :: lhat
     
     if (PRESENT(method)) then
        
        select case(method)
        case('OPT')
           call gaml2max(Pr, tau, R0, lamhat, l2hat, ierr, 'OPT')
        case('CUBIC')
           call gaml2max(Pr, tau, R0, lamhat, l2hat, ierr, 'CUBIC')
        case('2D_ROOT')
           call calc_mode_properties(R0, Pr, tau, l2hat, lhat, lamhat)
        case default
           write(*, *) 'invalid method in call to gaml2max'
           ierr = -1
           return
        end select

      else

         call gaml2max(Pr, tau, R0, lamhat, l2hat, ierr)

      end if

      return
   end subroutine thermohaline_mode_properties

   real(dp) function thermohaline_nusseltC(tau, w, lamhat, l2hat, KB)
     use thermohaline, only: nuC
     real(dp), intent(in) :: tau, w, lamhat, l2hat, KB
     thermohaline_nusseltC = nuC(tau, w, lamhat, l2hat, KB)
     return 
   end function thermohaline_nusseltC

   subroutine calc_hg19_w(HB, l2hat, lamhat, w, ierr)
     use thermohaline, only: solve_hg19_eqn32

     real(dp), intent(in)           :: HB
     real(dp), intent(in)           :: l2hat
     real(dp), intent(in)           :: lamhat
     real(dp), intent(out)          :: w
     integer, intent(out)           :: ierr

     call solve_hg19_eqn32(HB, l2hat, lamhat, w, ierr)
     
   end subroutine calc_hg19_w

   subroutine calc_frg24_w(pr, tau, r0, hb, db, ks, n, w, withTC, ierr, lamhat, l2hat)
     use parasite_model

     real(dp), intent(in) :: pr, tau, r0, hb, db 
     real(dp), intent(in) :: ks(:)
     integer, intent(in) :: n ! n MUST be odd
     real(dp), intent(out) :: w
     logical, intent(in) :: withTC
     integer, intent(out) :: ierr
     real(dp), intent(in), optional :: lamhat, l2hat

     ierr = 0

     ! these calls to wf ignore delta, ideal, badks_exception, get_kmax (0,0,false,false)
     if (present(lamhat)) then
        ! lamhat and l2hat already calculated, so can pass as arguments
        if(withTC) then
           w = wf_withTC(pr, tau, r0, hb, db, ks, n, .false., lamhat, l2hat)
        else
           w = wf(pr, tau, r0, hb, db, ks, n, 0d0, 0, .false., .false., lamhat, l2hat)
        end if
     else
        ! lamhat and l2hat need to be calculated inside the wf routine
        if(withTC) then
           w = wf_withTC(pr, tau, r0, hb, db, ks, n, .false.)
        else
           w = wf(pr, tau, r0, hb, db, ks, n, 0d0, 0, .false., .false.)
        end if
     end if
  
   end subroutine calc_frg24_w
   
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
   !! @param chiT dlnP/dlnT|rho
   !! @param chiRho dlnP/dlnRho|T
   !! @param gradr Radiative temperature gradient.
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
   !! @param conv_vel The convection speed (cm/s).
   !! @param D The chemical diffusion coefficient (cm^2/s).
   !! @param Y_face The superadiabaticity (dlnT/dlnP - grada, output).
   !! @param gradT The temperature gradient dlnT/dlnP (output).
   !! @param tdc_num_iters Number of iterations taken in the TDC solver.
   !! @param ierr Tracks errors (output).
   subroutine set_TDC( &
            conv_vel_start, mixing_length_alpha, alpha_TDC_DAMP, alpha_TDC_DAMPR, alpha_TDC_PtdVdt, dt, cgrav, m, report, &
            mixing_type, scale, chiT, chiRho, gradr, r, P, T, rho, dV, Cp, opacity, &
            scale_height, gradL, grada, conv_vel, D, Y_face, gradT, tdc_num_iters, ierr)
      use tdc
      use tdc_support
      real(dp), intent(in) :: conv_vel_start, mixing_length_alpha, alpha_TDC_DAMP, alpha_TDC_DAMPR, alpha_TDC_PtdVdt, dt, cgrav, m, scale
      type(auto_diff_real_star_order1), intent(in) :: &
         chiT, chiRho, gradr, r, P, T, rho, dV, Cp, opacity, scale_height, gradL, grada
      logical, intent(in) :: report
      type(auto_diff_real_star_order1),intent(out) :: conv_vel, Y_face, gradT, D
      integer, intent(out) :: tdc_num_iters, mixing_type, ierr
      type(tdc_info) :: info
      type(auto_diff_real_star_order1) :: L, grav, Lambda, Gamma
      real(dp), parameter :: alpha_c = (1d0/2d0)*sqrt_2_div_3
      real(dp), parameter :: lower_bound_Z = -1d2
      real(dp), parameter :: upper_bound_Z = 1d2
      real(dp), parameter :: eps = 1d-2 ! Threshold in logY for separating multiple solutions.
      type(auto_diff_real_tdc) :: Zub, Zlb
      include 'formats'

      ! Do a call to MLT
      grav = cgrav * m / pow2(r)
      L = 64 * pi * boltz_sigma * pow4(T) * grav * pow2(r) * gradr / (3d0 * P * opacity)
      Lambda = mixing_length_alpha * scale_height
      call set_MLT('Cox', mixing_length_alpha, 0d0, 0d0, &
                     chiT, chiRho, Cp, grav, Lambda, rho, P, T, opacity, &
                     gradr, grada, gradL, &
                     Gamma, gradT, Y_face, conv_vel, D, mixing_type, ierr)

      ! Pack TDC info
      info%report = report
      info%mixing_length_alpha = mixing_length_alpha
      info%alpha_TDC_DAMP = alpha_TDC_DAMP
      info%alpha_TDC_DAMPR = alpha_TDC_DAMPR
      info%alpha_TDC_PtdVdt = alpha_TDC_PtdVdt
      info%dt = dt
      info%L = convert(L)
      info%gradL = convert(gradL)
      info%grada = convert(grada)
      info%c0 = convert(mixing_length_alpha*alpha_c*rho*T*Cp*4d0*pi*pow2(r))
      info%L0 = convert((16d0*pi*crad*clight/3d0)*cgrav*m*pow4(T)/(P*opacity)) ! assumes QHSE for dP/dm
      info%A0 = conv_vel_start/sqrt_2_div_3
      info%T = T
      info%rho = rho
      info%dV = dV
      info%Cp = Cp
      info%kap = opacity
      info%Hp = scale_height
      info%Gamma = Gamma

      ! Get solution
      Zub = upper_bound_Z
      Zlb = lower_bound_Z
      call get_TDC_solution(info, scale, Zlb, Zub, conv_vel, Y_face, tdc_num_iters, ierr)

      ! Unpack output
      gradT = Y_face + gradL
      D = conv_vel*scale_height*mixing_length_alpha/3d0     ! diffusion coefficient [cm^2/sec]
      if (conv_vel > 0d0) then
         mixing_type = convective_mixing
      else
         mixing_type = no_mixing
      end if
   end subroutine set_TDC

   !> Calculates the outputs of semiconvective mixing theory.
   !!
   !! @param L Luminosity across a face (erg/s).
   !! @param Lambda The mixing length (cm).
   !! @param m Mass inside the face (g).
   !! @param T temperature (K).
   !! @param P pressure (erg/cm^3).
   !! @param Pr radiation pressure (erg/cm^3).
   !! @param beta ratio of gas pressure to radiation pressure.
   !! @param opacity opacity (cm^2/g).
   !! @param rho density (g/cm^3).
   !! @param alpha_semiconvection The semiconvective alpha parameter.
   !! @param semiconvection_option A string specifying which semiconvection theory to use. Currently supported are 'Langer_85 mixing; gradT = gradr' and 'Langer_85'.
   !! @param cgrav gravitational constant (erg*cm/g^2).
   !! @param Cp Specific heat at constant pressure (erg/g/K).
   !! @param gradr The radiative temperature gradient dlnT/dlnP_{rad}
   !! @param grada The adiabatic temperature gradient dlnT/dlnP|s
   !! @param gradL The Ledoux temperature gradient dlnT/dlnP
   !! @param gradL_composition_term The contribution of composition gradients to the Ledoux temperature gradient.
   !! @param gradT The temperature gradient dlnT/dlnP (output).
   !! @param Y_face The superadiabaticity (dlnT/dlnP - grada, output).
   !! @param conv_vel The convection speed (cm/s).
   !! @param D The chemical diffusion coefficient (cm^2/s).
   !! @param mixing_type Set to semiconvective if convection operates (output).
   !! @param ierr Tracks errors (output).
   subroutine set_semiconvection(L, Lambda, m, T, P, Pr, beta, opacity, rho, alpha_semiconvection, &
                                 semiconvection_option, cgrav, Cp, gradr, grada, gradL, &
                                 gradL_composition_term, &
                                 gradT, Y_face, conv_vel, D, mixing_type, ierr)
      use semiconvection
      type(auto_diff_real_star_order1), intent(in) :: L, Lambda, T, P, Pr, beta, opacity, rho
      type(auto_diff_real_star_order1), intent(in) :: Cp, gradr, grada, gradL
      character(len=*), intent(in) :: semiconvection_option
      real(dp), intent(in) :: alpha_semiconvection, cgrav, gradL_composition_term, m
      type(auto_diff_real_star_order1), intent(out) :: gradT, Y_face, conv_vel, D
      integer, intent(out) :: mixing_type, ierr

      call calc_semiconvection(L, Lambda, m, T, P, Pr, beta, opacity, rho, alpha_semiconvection, &
                                 semiconvection_option, cgrav, Cp, gradr, grada, gradL, &
                                 gradL_composition_term, &
                                 gradT, Y_face, conv_vel, D, mixing_type, ierr)
   end subroutine set_semiconvection

   !> Calculates the outputs of convective mixing length theory.
   !!
   !! @param MLT_option A string specifying which MLT option to use. Currently supported are Cox, Henyey, ML1, ML2, Mihalas. Note that 'TDC' is also a valid input and will return the Cox result. This is for use when falling back from TDC -> MLT, as Cox is the most-similar prescription to TDC.
   !! @param mixing_length_alpha The mixing length parameter.
   !! @param Henyey_MLT_nu_param The nu parameter in Henyey's MLT prescription.
   !! @param Henyey_MLT_y_param The y parameter in Henyey's MLT prescription.
   !! @param chiT dlnP/dlnT|rho
   !! @param chiRho dlnP/dlnRho|T
   !! @param Cp Specific heat at constant pressure (erg/g/K).
   !! @param grav The acceleration due to gravity (cm/s^2).
   !! @param Lambda The mixing length (cm).
   !! @param rho density (g/cm^3).
   !! @param T temperature (K).
   !! @param opacity opacity (cm^2/g)
   !! @param gradr The radiative temperature gradient dlnT/dlnP_{rad}
   !! @param grada The adiabatic temperature gradient dlnT/dlnP|s
   !! @param gradL The Ledoux temperature gradient dlnT/dlnP
   !! @param Gamma The convective efficiency parameter (output).
   !! @param gradT The temperature gradient dlnT/dlnP (output).
   !! @param Y_face The superadiabaticity (dlnT/dlnP - grada, output).
   !! @param conv_vel The convection speed (cm/s).
   !! @param D The chemical diffusion coefficient (cm^2/s).
   !! @param mixing_type Set to convective if convection operates (output).
   !! @param ierr Tracks errors (output).
   subroutine set_MLT(MLT_option, mixing_length_alpha, Henyey_MLT_nu_param, Henyey_MLT_y_param, &
                     chiT, chiRho, Cp, grav, Lambda, rho, P, T, opacity, &
                     gradr, grada, gradL, &
                     Gamma, gradT, Y_face, conv_vel, D, mixing_type, ierr)
      use mlt
      type(auto_diff_real_star_order1), intent(in) :: chiT, chiRho, Cp, grav, Lambda, rho, P, T, opacity, gradr, grada, gradL
      character(len=*), intent(in) :: MLT_option
      real(dp), intent(in) :: mixing_length_alpha, Henyey_MLT_nu_param, Henyey_MLT_y_param
      type(auto_diff_real_star_order1), intent(out) :: Gamma, gradT, Y_face, conv_vel, D
      integer, intent(out) :: mixing_type, ierr

      call calc_MLT(MLT_option, mixing_length_alpha, Henyey_MLT_nu_param, Henyey_MLT_y_param, &
                     chiT, chiRho, Cp, grav, Lambda, rho, P, T, opacity, &
                     gradr, grada, gradL, &
                     Gamma, gradT, Y_face, conv_vel, D, mixing_type, ierr)
   end subroutine set_MLT

end module turb
