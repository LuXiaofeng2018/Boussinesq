clear;clc;
%return
tic
x_st = -8.1;    y_st = -8.1;
x_end = 8.1;    y_end = 8.1;
x_st2 = -15.0;   y_st2 = -15.0;
x_end2 = 15.0;   y_end2 = 21.0;

compBox = struct('x_st',{x_st},'x_end',{x_end},'y_st',{y_st},'y_end',...
    {y_end},'x_st2',{x_st2},'x_end2',{x_end2},'y_st2',{y_st2},'y_end2',{y_end2});

UseExtendedDomain=1;

h = 0.05; 
x=x_st:h:x_end; 
y=y_st:h:y_end; 
%tau = 0.00114425*8;% getTau(h,x_end,y_end)/20;
tau = getTau(h,x_end,y_end)/20;

sx = (length(x)+1)/2
sy = (length(y)+1)/2
   
   al = -1;%99979 izb
   bt1 = 3;bt2 = 1; bt = bt1/bt2;
   c = 0.75; 
   iterMax = 9000000;
   %eps = 1/max(y_end^6,((1-c^2)*x_end^2)^3);
   eps = 1.0e-010;
   ICSwitch=0;
   % IC_switch = 0 ->christov sech formula
   % IC_switch = 1 ->nat42 formula
   plotResidual  = 0;
   plotBoundary  = 0;
   checkBoundary = 0;
   plotAssympt   = 0;
   % if '1' plots the Residual/Boundry
   % if '0' does not plot anything
   prmtrs = struct('h',{h},'tau',{tau},'iterMax',{iterMax},'eps',{eps},'ICSwitch',{ICSwitch},...
       'plotResidual',{plotResidual},'plotBoundary',{plotBoundary},'plotAssympt',{plotAssympt},'checkBoundary',{checkBoundary});
   
   firstDerivative = GetFiniteDifferenceCoeff([-2,-1,0,1,2],1)'/h;
   secondDerivative = GetFiniteDifferenceCoeff([-2,-1,0,1,2],2)'/h^2;
   derivative = struct('first',{firstDerivative},'second',{secondDerivative});
   
  [bigU,bigUTimeDerivative,P,U,bigIC,solutionNorms,theta,c1,c2,zeroX,zeroY,tauVector,angl]=...
  PrepareICForInnerDomain(compBox,prmtrs,al,bt1,bt2,c,derivative);

  if(length(tauVector)<iterMax && UseExtendedDomain == 1 && size(bigUTimeDerivative,1)~=1)
     fprintf('\nLarge Domamin Calculations:\n\n');
     prmtrs.checkBoundary =0;
     prmtrs.eps = 2.0e-012;
     prmtrs.plotResidual = 0;
     prmtrs.tau = tauVector(end);
     [bigU,bigUTimeDerivative,P,U,newBigIC,solutionNorms,theta,c1,c2,zeroX,zeroY,tauVector,angl] =...
     PrepareICForEnlargedDomain(bigU,compBox,prmtrs,al,bt1,bt2,c,c1,theta(end),derivative);
     x=x_st2:h:x_end2; y=y_st2:h:y_end2;
  end
  toc
  save (['SavedWorkspaces\' GetICName(ICSwitch) 'IC_' num2str(floor(x_end2)) '_bt' num2str(bt) '_c0' num2str(floor(c*100)) ...
      '_h0' num2str(h*1000) '_O(h^' num2str(  size( secondDerivative, 2 ) - 1  ) ')']);
    
PlotResidualInfNormTauAndUvsUpInfNorm(solutionNorms,tauVector,angl);
PrintResults(solutionNorms,c1,c2);
PlotAssymptVsSolu( x, y, h, zeroX, zeroY, bigU, c1*theta(end), c/sqrt(bt) );
return;
% Continue from lasth iteration:
lastTheta=theta(end); lastU=U; lastP = P;  last_tau = tauVector(end); 

[bigU,bigUTimeDerivative,P,U,theta,c1,c2,solutionNorms,tauVector,angl] =...
       sol_ch_v9(lastU,x,y,prmtrs,bt1,bt2,al,c,lastTheta,zeroX,zeroY,derivative,lastP);
save (['SavedWorkspaces\' GetICName(ICSwitch) 'IC_' num2str(floor(x_end2)) '_bt' num2str(bt) '_c0' num2str(floor(c*100)) ...
      '_h0' num2str(h*100) '_O(h^' num2str(  size( secondDerivative, 2 ) - 1  ) ')']);
return;
DrawSolution(x,y,h,zeroX,zeroY,al,bt,c,theta,bigU,bigUTimeDerivative,bigIC,U,compBox,secondDerivative);

PlotAssymptVsSolu( x, y, h, zeroX, zeroY, bigU, c1*theta(end), c/sqrt(bt) );
PlotAssymptotics(x,y,h,zeroX,zeroY,bigU);
DrawDerivativesOfSolution(bigU,compBox,x,y,h,zeroX,zeroY,c,derivative);
return;



    [X,Y]=Domain(x,y);

    c12 = 1-c^2;
    %newBigIC = c1*lastTheta*(c12*X.^2-Y.^2)./(c12*X.^2+Y.^2).^2;
    newBigIC =  X.*(c12*X.^2-3*Y.^2)./(c12*X.^2+Y.^2).^3; 
    %newBigIC =  (c12^2* X.^4 - 6*c12 * X.^2 .* Y.^2 + Y.^4)./(c12*X.^2+Y.^2).^4;
    
    fig_ss13=figure(13);
    set(fig_ss13, 'OuterPosition', [0.0      	30.0        380.0     340.0]);
    %*sqrt(1-c^2)
    mesh(x,y,newBigIC');
    xlabel('x');    ylabel('y');
    title('end solution')
    %axis([x_st2 x_end2 y_st2 y_end2 -0.5 1]);
    axis([x_st x_end y_st y_end -0.01 .01]);
    colorbar;
    caxis([-0.001 .001]);
    view(0,90);

