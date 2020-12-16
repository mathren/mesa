from sympy import *

# Supported unary functions
unary_operators = [
	(lambda x: -1*x, 'unary_minus'),
	(lambda x: exp(x), 'exp'),
	(lambda x: log(x), 'log'),
	(lambda x: log(x), 'safe_log'),
	(lambda x: log(x,10), 'log10'),
	(lambda x: log(x,10), 'safe_log10'),
	(lambda x: sin(x), 'sin'),
	(lambda x: cos(x), 'cos'),
	(lambda x: tan(x), 'tan'),
	(lambda x: sinh(x), 'sinh'),
	(lambda x: cosh(x), 'cosh'),
	(lambda x: tanh(x), 'tanh'),
	(lambda x: asin(x), 'asin'),
	(lambda x: acos(x), 'acos'),
	(lambda x: atan(x), 'atan'),
	(lambda x: asinh(x), 'asinh'),
	(lambda x: acosh(x), 'acosh'),
	(lambda x: atanh(x), 'atanh'),
	(lambda x: sqrt(x), 'sqrt'),
	(lambda x: x**2, 'pow2'),
	(lambda x: x**3, 'pow3'),
	(lambda x: x**4, 'pow4'),
	(lambda x: x**5, 'pow5'),
	(lambda x: x**6, 'pow6'),
	(lambda x: x**7, 'pow7'),
	(lambda x: abs(x), 'abs')
]

# Supported binary functions

def Dim(x,y):
	return (x-y+abs(x-y))/Float(2)

def Sub(x,y):
	return x-y

def Div(x,y):
	return x/y

binary_operators = [
	(Add, 'add'),
	(Sub, 'sub'),
	(Mul, 'mul'),
	(Div, 'div'),
	(Pow, 'pow'),
	(Max, 'max'),
	(Min, 'min'),
	(Dim, 'dim')
]

# Supported comparison operators
comparison_operators = [
	('.eq.', 'equal'),
	('.ne.', 'neq'),
	('.gt.', 'greater'),
	('.lt.', 'less'),
	('.le.', 'leq'),
	('.ge.', 'geq')
]

# Names of functions that map onto intrinsic operators
intrinsics = {'add':'+', 'sub':'-', 'mul':'*', 'div':'/', 'pow':'**', 'unary_minus':'-'}
