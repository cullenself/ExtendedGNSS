function [ Q ] = rotate( theta, axis )
%Rotate - returns the directional cosine tranformation matrix specified by
%   theta - angle in radians
%   axis - which primary axis
    Q = feval(sprintf('r%d',axis),theta);
end
function [Q] = r1(x) % rotational matrices
Q = [[1,0,0];[0,cos(x),-sin(x)];[0,sin(x),cos(x)]];
end
function [Q] = r2(x)
Q = [[cos(x),0,sin(x)];[0,1,0];[-sin(x),0,cos(x)]];
end
function [Q] = r3(x)
Q = [[cos(x),-sin(x),0];[sin(x),cos(x),0];[0,0,1]];
end
