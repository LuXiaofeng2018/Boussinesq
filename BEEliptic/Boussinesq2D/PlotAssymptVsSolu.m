function PlotAssymptVsSolu( x, y, h, zeroX, zeroY, bigU, muTheta, c )

    shift = ceil(6/h);
    stX = zeroX+shift-1;
    stY = zeroY+shift-1;
    newX = x(stX:end);
    newY = y(stY:end);
    
    assymptYeqZero = + muTheta * newX.^2 ./ ( (1-c^2)*newX.^2 );
    assymptXeqZero = - muTheta * newY.^2 ./ newY.^2;

    figure(5)
    plot(newY, (newY.^2).* bigU(zeroY,stY:end), 'b', newY, assymptXeqZero, 'k' ) %(1+end)/2
    xlabel('y')
    title('x==0 Cross section');
    
    figure(6)
    plot(newX,(newX'.^2).*bigU(stX:end,zeroY), 'b', newX, assymptYeqZero, 'k' )
    xlabel('x')
    title('y==0 Cross section');
    
end