
%% Description:  Coefficients of the Hamming window

function c = hamming (m)
  
  if (nargin ~= 1)
   error('hamming (m)\n');
end
  
  %if (!(is_scalar (m) && (m == round (m)) && (m > 0)))
  %  error ('hamming:  m has to be an integer > 0');
  %endif
  
  if (m == 1)
    c = 1;
  else
    m = m - 1;
    c = 0.54 - 0.46 * cos (2 * pi * (0:m)' / m);
end
  
end