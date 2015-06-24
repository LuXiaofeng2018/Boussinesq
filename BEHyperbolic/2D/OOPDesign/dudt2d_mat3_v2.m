function [ cg0 ] = dudt2d_mat3_v2(x,y,c,beta1)
%DUDT0 Summary of this function goes here
%   Detailed explanation goes here
%beta2 == alpha == 1;

if (nargin == 3) beta1=3; end
if (nargin == 2) beta1=3; c=0.27; end

beta2=1;

R2 = x .^ 2 + y .^ 2;
R = sqrt(R2);
R212 = R2 .^ 1.2;
R2105 = R2 .^ 1.05;

CSR2 = cosh(R);
SNR2 = sinh(R);

o1R2 = 0.095 .* R2;
o2R2 = 0.24 .* R2;
o3R2 = 0.22 .* R2;
o4R2 = 0.769199e2 .* R2; 
o5R2 = 0.312172e2 .* R2;
X_Y = x .^ 2 - y .^ 2;

cg0 = -0.1152e1 .* y .* c ./ CSR2 .* (0.1e1 + o1R2) .^ (-0.15e1) + 0.24e1 .* (0.1e1 + o2R2) ./ CSR2 .^ 2 .* (0.1e1 + o1R2) .^ (-0.15e1) .* SNR2 .* R2 .^ (-0.1e1 ./ 0.2e1) .* y .* c + 0.68400e0 .* (0.1e1 + o2R2) ./ CSR2 .* (0.1e1 + o1R2) .^ (-0.25e1) .* y .* c + c .^ 2 .* (-0.5097600000e0 .* (1 - beta1) .* R2 .^ 0.200000000e0 .* y .* c ./ CSR2 ./ (0.1e1 + 0.11e0 .* R2105) - 0.12e1 .* (1 - beta1) .* (0.1e1 - 0.177e0 .* R212) ./ CSR2 .^ 2 ./ (0.1e1 + 0.11e0 .* R2105) .* SNR2 .* R2 .^ (-0.1e1 ./ 0.2e1) .* y .* c - 0.2772000000e0 .* (1 - beta1) .* (0.1e1 - 0.177e0 .* R212) ./ CSR2 ./ (0.1e1 + 0.11e0 .* R2105) .^ 2 .* R2 .^ 0.50000000e-1 .* y .* c + 0.528e0 .* beta1 .* y .* c ./ CSR2 ./ (0.1e1 + 0.11e0 .* R212) - 0.12e1 .* beta1 .* (0.1e1 + o3R2) ./ CSR2 .^ 2 ./ (0.1e1 + 0.11e0 .* R212) .* SNR2 .* R2 .^ (-0.1e1 ./ 0.2e1) .* y .* c - 0.3168000000e0 .* beta1 .* (0.1e1 + o3R2) ./ CSR2 ./ (0.1e1 + 0.11e0 .* R212) .^ 2 .* R2 .^ 0.200000000e0 .* y .* c) + c .^ 2 .* ((1 - beta1) .* (-0.624344e2 .* y .* c + 0.302502e2 .* R .* y .* c - 0.1591476e2 .* R2 .* y .* c + 0.1743714e0 .* R2 .^ 2 .* y .* c) ./ (0.1e1 + 0.779734e2 .* R - o4R2+ 0.554646e2 .* R2 .^ (0.3e1 ./ 0.2e1) - 0.129335e2 .* R2 .^ 2 + 0.10351e1 .* R2 .^ (0.5e1 ./ 0.2e1) + 0.628801e0 .* R2 .^ 3 - 0.573272e-2 .* R2 .^ 4) - (1 - beta1) .* (o5R2 - 0.100834e2 .* R2 .^ (0.3e1 ./ 0.2e1) + 0.397869e1 .* R2 .^ 2 - 0.290619e-1 .* R2 .^ 3) ./ (0.1e1 + 0.779734e2 .* R - o4R2+ 0.554646e2 .* R2 .^ (0.3e1 ./ 0.2e1) - 0.129335e2 .* R2 .^ 2 + 0.10351e1 .* R2 .^ (0.5e1 ./ 0.2e1) + 0.628801e0 .* R2 .^ 3 - 0.573272e-2 .* R2 .^ 4) .^ 2 .* (-0.779734e2 .* R2 .^ (-0.1e1 ./ 0.2e1) .* y .* c + 0.1538398e3 .* y .* c - 0.1663938e3 .* R .* y .* c + 0.517340e2 .* R2 .* y .* c - 0.51755e1 .* R2 .^ (0.3e1 ./ 0.2e1) .* y .* c - 0.3772806e1 .* R2 .^ 2 .* y .* c + 0.4586176e-1 .* R2 .^ 3 .* y .* c) + beta1 .* (-0.624344e2 .* y .* c + 0.302502e2 .* R .* y .* c - 0.1591476e2 .* R2 .* y .* c + 0.1743714e0 .* R2 .^ 2 .* y .* c) ./ (0.1e1 + 0.779734e2 .* R - o4R2+ 0.554646e2 .* R2 .^ (0.3e1 ./ 0.2e1) - 0.129335e2 .* R2 .^ 2 + 0.10351e1 .* R2 .^ (0.5e1 ./ 0.2e1) + 0.628801e0 .* R2 .^ 3 - 0.573272e-2 .* R2 .^ 4) - beta1 .* (o5R2 - 0.100834e2 .* R2 .^ (0.3e1 ./ 0.2e1) + 0.397869e1 .* R2 .^ 2 - 0.290619e-1 .* R2 .^ 3) ./ (0.1e1 + 0.779734e2 .* R - o4R2+ 0.554646e2 .* R2 .^ (0.3e1 ./ 0.2e1) - 0.129335e2 .* R2 .^ 2 + 0.10351e1 .* R2 .^ (0.5e1 ./ 0.2e1) + 0.628801e0 .* R2 .^ 3 - 0.573272e-2 .* R2 .^ 4) .^ 2 .* (-0.779734e2 .* R2 .^ (-0.1e1 ./ 0.2e1) .* y .* c + 0.1538398e3 .* y .* c - 0.1663938e3 .* R .* y .* c + 0.517340e2 .* R2 .* y .* c - 0.51755e1 .* R2 .^ (0.3e1 ./ 0.2e1) .* y .* c - 0.3772806e1 .* R2 .^ 2 .* y .* c + 0.4586176e-1 .* R2 .^ 3 .* y .* c)) .* (X_Y) ./ R2 + 0.2e1 .* c .^ 3 .* ((1 - beta1) .* (o5R2 - 0.100834e2 .* R2 .^ (0.3e1 ./ 0.2e1) + 0.397869e1 .* R2 .^ 2 - 0.290619e-1 .* R2 .^ 3) ./ (0.1e1 + 0.779734e2 .* R - o4R2+ 0.554646e2 .* R2 .^ (0.3e1 ./ 0.2e1) - 0.129335e2 .* R2 .^ 2 + 0.10351e1 .* R2 .^ (0.5e1 ./ 0.2e1) + 0.628801e0 .* R2 .^ 3 - 0.573272e-2 .* R2 .^ 4) + beta1 .* (o5R2 - 0.100834e2 .* R2 .^ (0.3e1 ./ 0.2e1) + 0.397869e1 .* R2 .^ 2 - 0.290619e-1 .* R2 .^ 3) ./ (0.1e1 + 0.779734e2 .* R - o4R2+ 0.554646e2 .* R2 .^ (0.3e1 ./ 0.2e1) - 0.129335e2 .* R2 .^ 2 + 0.10351e1 .* R2 .^ (0.5e1 ./ 0.2e1) + 0.628801e0 .* R2 .^ 3 - 0.573272e-2 .* R2 .^ 4)) .* y ./ R2 + 0.2e1 .* c .^ 3 .* ((1 - beta1) .* (o5R2 - 0.100834e2 .* R2 .^ (0.3e1 ./ 0.2e1) + 0.397869e1 .* R2 .^ 2 - 0.290619e-1 .* R2 .^ 3) ./ (0.1e1 + 0.779734e2 .* R - o4R2+ 0.554646e2 .* R2 .^ (0.3e1 ./ 0.2e1) - 0.129335e2 .* R2 .^ 2 + 0.10351e1 .* R2 .^ (0.5e1 ./ 0.2e1) + 0.628801e0 .* R2 .^ 3 - 0.573272e-2 .* R2 .^ 4) + beta1 .* (o5R2 - 0.100834e2 .* R2 .^ (0.3e1 ./ 0.2e1) + 0.397869e1 .* R2 .^ 2 - 0.290619e-1 .* R2 .^ 3) ./ (0.1e1 + 0.779734e2 .* R - o4R2 + 0.554646e2 .* R2 .^ (0.3e1 ./ 0.2e1) - 0.129335e2 .* R2 .^ 2 + 0.10351e1 .* R2 .^ (0.5e1 ./ 0.2e1) + 0.628801e0 .* R2 .^ 3 - 0.573272e-2 .* R2 .^ 4)) .* (X_Y) ./ R2 .^ 2 .* y;
