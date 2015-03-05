function y = mySigmoid(x,b,a,x1,x2,prec)
%MYSIGMOID Similar to Matlab's logsig() function
% y = logsig(x) = 1/(1+exp(-x))
%
% mySigmoid allows two more constants to change the shape of the curves
%   y = mySigmoid(x,b,a) = 1/(1+exp(-a*x+b))
%   a: influences steepness of the curve. a->\infty, sigmoid->step
%   b: center position (y==0.5) equivalent (x=0) shifted by value b/a, i.e. @ x=b/a, y=0.5
%
% A good way to fit a sigmoid to a Gaussian-like distribution is to use
%   b: mean(data)/std(data)
%   a: 1/std(data)
%
% Other way is to make sure sigmoid spans x1 -- x2 region completely.
% Specify prec which is value f(x) @ x1. Can then fix the sigmoid based on that
% Defaults are
%     f(x) = 0.001 @ x1
%     f(x) = 0.999 @ x2
%         log(1/0.001 - 1) == 6.9068 (the multiplier when prec not specified)
%     a = 2 * 6.9068 / (x2 - x1)
%     b = 6.9068 * (x2 + x1) / (x2 - x1)
%
% Author: Makarand Tapaswi
% Last modified: 27-09-2013

%% Example working
% x = -10:0.01:10;
% figure, hold on; grid on;
% plot(x,1./(1+exp(-x)),'b');
% plot(x,1./(1+exp(-2*x)),'r');
% plot(x,1./(1+exp(-x+2)),'g');
% plot(x,1./(1+exp(-2*x+4)),'k');
% legend('-x','-2*x','-x+2','-2*x+4');

%% mySigmoid
if nargin == 6
    % autofit to x1, x2 @ given precision. (precision is value @ x1)
    p = log(1/prec - 1);
    a = 2 * p / (x2 - x1);
    b = p * (x2 + x1) / (x2 - x1);
elseif nargin == 5
    % autofit using x1, x2, precision = 0.001 and 0.999
    a = 2 * 6.9068 / (x2 - x1);
    b = 6.9068 * (x2 + x1) / (x2 - x1);
elseif nargin == 3
    % do nothing, i.e. a and b are correctly provided
elseif nargin == 2
    % only b is provided, use default a = 1
    a = 1;
elseif nargin == 1
    % only x given, use default a = 1, b = 0
    a = 1; b = 0;
else
    % something wrong / missing
    error('Wrong number of input arguments!');
end

% compute the actual sigmoid
y = 1./(1+exp(-a*x+b));

end

