program test_math
  
  use const_lib
  use math_lib

  implicit none

  real(dp), parameter :: XS(3) = [0.1_dp, 0.2_dp, 0.4_dp]

  integer  :: i
  real(dp) :: x

  call math_init()

  write(*, *) MATH_BACKEND

  write(*, *)

  do i = 1, SIZE(XS)

     x = XS(i)

     print 100, 'Function', 'Value (x= ', x, ' )'
100  format(1X, A10, 1X, A10, E24.16, A2)

     write(*, 110) 'log', log(x)
     write(*, 110) 'log10', log10(x)
     write(*, 110) 'log1p', log1p(x)
     write(*, 110) 'log2', log2(x)
     write(*, 110) 'safe_log', safe_log(x)
     write(*, 110) 'safe_log10', safe_log10(x)
     write(*, 110) 'exp', exp(x)
     write(*, 110) 'exp10', exp10(x)
     write(*, 110) 'expm1', expm1(x)
     write(*, 110) 'pow(,2)', pow(x, 2)
     write(*, 110) 'pow(,2.)', pow(x, 2._dp)
     write(*, 110) 'pow2', pow2(x)
     write(*, 110) 'pow3', pow3(x)
     write(*, 110) 'pow4', pow4(x)
     write(*, 110) 'pow5', pow5(x)
     write(*, 110) 'pow6', pow6(x)
     write(*, 110) 'pow7', pow7(x)
     write(*, 110) 'pow8', pow8(x)
     write(*, 110) 'cos', cos(x)
     write(*, 110) 'sin', sin(x)
     write(*, 110) 'tan', tan(x)
     write(*, 110) 'cospi', cospi(x)
     write(*, 110) 'sinpi', sinpi(x)
     write(*, 110) 'tanpi', tanpi(x)
     write(*, 110) 'acos', acos(x)
     write(*, 110) 'asin', asin(x)
     write(*, 110) 'atan', atan(x)
     write(*, 110) 'acospi', acospi(x)
     write(*, 110) 'asinpi', asinpi(x)
     write(*, 110) 'atanpi', atanpi(x)
     write(*, 110) 'cosh', cosh(x)
     write(*, 110) 'sinh', sinh(x)
     write(*, 110) 'tanh', tanh(x)

110  format(1X, A10, 1X, E24.16)

     print *

  end do

end program test_math

