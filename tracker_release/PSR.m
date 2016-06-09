function [YN,psr,psr0] = PSR(response)

oldres = response;
[idx,idy]=find(response==max(max(response)));
[m,n]=size(response);
gmax = response(idx,idy);

if idx<6
    if idy<6
        wind = response(1:idx+5,1:idy+5);
        response(1:idx+5,1:idy+5) = zeros(size(response(1:idx+5,1:idy+5)));
    elseif idy>n-5
        wind = response(1:idx+5,idy-5:end);
        response(1:idx+5,idy-5:end) = zeros(size(response(1:idx+5,idy-5:end)));
    else
        wind = response(1:idx+5,idy-5:idy+5);
        response(1:idx+5,idy-5:idy+5) = zeros(size(response(1:idx+5,idy-5:idy+5)));
    end
elseif idx>m-5
    if idy<6
        wind = response(idx-5:end,1:idy+5);
        response(idx-5:end,1:idy+5) = zeros(size( response(idx-5:end,1:idy+5)));
    elseif idy>n-5
        wind = response(idx-5:end,idy-5:end);
        response(idx-5:end,idy-5:end) = zeros(size(response(idx-5:end,idy-5:end)));
    else
        wind = response(idx-5:end,idy-5:idy+5);
        response(idx-5:end,idy-5:idy+5) = zeros(size(response(idx-5:end,idy-5:idy+5)));
    end
else
    if idy<6
        wind = response(idx-5:idx+5,1:idy+5);
        response(idx-5:idx+5,1:idy+5) = zeros(size(response(idx-5:idx+5,1:idy+5)));
    elseif idy>n-5
        wind = response(idx-5:idx+5,idy-5:end);
        response(idx-5:idx+5,idy-5:end) = zeros(size(response(idx-5:idx+5,idy-5:end)));
    else
        wind = response(idx-5:idx+5,idy-5:idy+5);
        response(idx-5:idx+5,idy-5:idy+5) = zeros(size(response(idx-5:idx+5,idy-5:idy+5)));
    end
end

response(idx,idy) = gmax;
u0 = mean2(oldres);
sig0 = std2(oldres);
psr0 = (gmax-u0)/sig0;
u = mean2(response);
sig = std2(response);
psr = (gmax-u)/sig;

if psr < 18
    YN = 1;
else
    YN = 0;
end