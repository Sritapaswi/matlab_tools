function t = MatrixOfStressStrainInVM(v)
% MatrixOfStressStrainInVM - Converts vectorized stress (strain) to a
% matrix
%
%   USAGE:
%
%   t = MatrixOfStressStrainInVM(v)
%
%   INPUT:
%
%   v
%       modified Voight-Mandel stress (strain) vector in [11, 22, 33, 12,
%       13, 23] order. Shears are expected to have factor of sqrt(2)
%       multiplied to them already.
%
%   t
%       stress (strain) matrix.

v   = v(:);
if length(v) == 6
    s2  = sqrt(2);
    t   = [ ...
        v(1)    v(4)/s2 v(5)/s2; ...
        v(4)/s2    v(2) v(6)/s2; ...
        v(5)/s2 v(6)/s2 v(3); ...
        ];
else
    disp('input vector size incorrect');
end