function Y = spread(X,E)
if nargin < 2; E = 4; end
% E is SD of gaussian used as spreading function
W = 4*E;
E = exp(-0.5*[(-W:W)/E].^2); %gaussian 


X = locmax(X); %only local maxima left
Y = 0*X; %preallocate zero matrix
lenx = length(X);
maxi = length(X) + length(E);
spos = 1+round((length(E)-1)/2);
for i = find(X>0)
  EE = [zeros(1,i),E];
  EE(maxi) = 0;
  EE = EE(spos+(1:lenx));
  Y = max(Y,X(i)*EE);
end