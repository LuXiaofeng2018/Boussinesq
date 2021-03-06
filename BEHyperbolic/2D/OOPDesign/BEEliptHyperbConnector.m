clear; clc;
bndPointsToRemove = 0; %'ChristovIC_40_bt1_c045_h0125_O(h^2)' 
% ChristovIC_30_bt3_c045_h01_O(h^4)
% ChristovIC_40_bt3_c045_h0125_O(h^2)  
% ChristovIC_30_bt3_c030_h01_O(h^2)
% ChristovIC_20_bt3_c030_h005_O(h^2)
% ChristovIC_20_bt3_c050_h005_O(h^2)
% ChristovIC_40_bt3_c045_h01_O(h^2)
% ChristovIC_40_bt3_c050_h01_O(h^2)
% ChristovIC_30_bt3_c045_h0075_O(h^2)
% ChristovIC_40_bt1_c045_h0125_O(h^2)
% ChristovIC_30_bt3_c085_h0075_O(h^2)
% ChristovIC_45_bt3_c090_h005_O(h^2)
% ChristovIC_33_bt3_c090_h0075_O(h^2)
% ChristovIC_30_bt3_c098_h0150_O(h^2)
% ChristovIC_15_bt3_c090_h050_O(h^2)
% ChristovIC_15_bt3_c075_h050_O(h^2)
% ChristovIC_15_bt3_c095_h050_O(h^2)
% ChristovIC_8_bt3_c095_h030_O(h^2)
% ChristovIC_12_bt3_c095_h030_O(h^2)
% ChristovIC_15_bt3_c090_h050_O(h^4)
% ChristovIC_15_bt3_c042_h050_O(h^2)
% ChristovIC_15_bt3_c050_h050_O(h^2)
% ChristovIC_15_bt3_c075_h050_O(h^4)
%waveFactory = WaveFactory( 'ChristovIC_15_bt3_c075_h050_O(h^4)', bndPointsToRemove );
waveFactory = WaveFactory( 'BestFitIC' );

    tau = 0.025;
    tEnd=15.0;
    %turnOnCaxis = 0;
    %waveFactory.PlotSingleWave( turnOnCaxis );

    estep = max(floor((1/tau)/10),1); %zapazwat se 20 stypki za edinitsa vreme

    dscrtParams = BEDiscretizationParameters( waveFactory.x, waveFactory.y ,waveFactory.h, waveFactory.order,...
                                             tau, tEnd, estep );
    eqParams = BEEquationParameters( waveFactory.alpha, waveFactory.beta1, waveFactory.beta2, waveFactory.c );
   ic = BEInitialCondition( waveFactory.u_t0 , waveFactory.dudt_t0, waveFactory.mu, waveFactory.theta );   
   engine = BEEngineEnergySaveZeroBnd( dscrtParams, eqParams, ic ); %BEEngineTaylorSoftBnd %BEEngineEnergySaveSoftBnd
   % _____________________________________
   tic

  %(VS) vector scheme: -->  O(tau + h^2)
    %(VS) vector scheme: -->  O(tau + h^2)
  %[tt, max_vv, t ,v1l, v2l]  = BE2D_v6(x,y,h,tau,t_end,beta1,beta2,al,estep,u_t0,dudt_t0); ver = 6;
  %(VC) Explicit method with variable change applied -->  O(tau^2 + h^2)  tau<function(h,beta)<h ..
  %[tt, max_v, t, vl]  = BE2D_v4(x,y,h,tau,t_end,beta1,beta2,al,estep,u_t0,dudt_t0);  ver = 4;
  %(NVC) Explicit method NO variable change -->  O(tau^2 + h^2) 
  %[tt, max_v, t, vl]  = BE2D_v3(x,y,h,tau,t_end,beta1,beta2,al,estep,u_t0,dudt_t0);  ver = 3;
  %Taylor method variable change applied --> O(tau^4 + h^2)  tau<function(h,beta)<h ..
  %[tt, max_v, t, vl]  = BE2D_t1(x,y,h,tau,t_end,beta1,beta2,al,estep,u_t0,dudt_t0);  ver = 1;
  % Taylor method variable change applied --> O(tau^4 + h^4)  tau<function(h,beta)<h ..
  [engine, tt, max_v, t, EN, II, vl, dvl] = engine.BESolver( );
  % Taylor method variable change applied --> O(tau^4/tau^4 + h^8)  tau<function(h,beta)<h ..
  %[tt, max_v, t, EN, II, vl, dvl]  =  BE2D_t8(x,y,h,tau,t_end,beta1,beta2,al,c,c1,ord,0,estep,u_t0,dudt_t0);  ver = 2;
  % Taylor method variable change applied --> O(tau^4 + h^4)  tau<function(h,beta)<h ..
  %[tt, max_v, t, vl, dvl]  =  CH2D_t2(x,y,h,tau,t_end,beta1,beta2,al,c^2,ord,estep,u_t0,dudt_t0);  ver = 222;
  %(NVC sit) Explicit method NO variable change -->  O(tau^2 + h^2) 
  %[tt, max_v, t, vl]  = BE2D_v3_sit(x,y,h,tau,t_end,beta1,beta2,al,estep,u_t0,dudt_t0);  ver = 33;
  %(VC sit) Explicit method with variable change applied -->  O(tau^2 + h

 %{
  xInd(1) = 1;
  sx = length(engine.x)
  sy = length(engine.y)
  xInd(2) = sx;
  yInd(1) = 1;
  yInd(2) = sy;
  %}
  
  curSz = size( vl );

  x = engine.x;
  y = engine.y;
      
  compBoxToShow = waveFactory.compBox;
  compBoxToShow.x_st = x( 1 );
  compBoxToShow.x_end = x( end );
  compBoxToShow.y_st = y( 1 );
  compBoxToShow.y_end = y( end );
  
  topView = 1;
  viewTypeX = 81;
  viewTypeY = 18;
  %MovieForBEHyperbolic( compBoxToShow, viewTypeX, viewTypeY, tt, x, y );
       
    figure(15)
    mesh(x,y,vl')
    title('solution');
    xlabel('x');            ylabel('y');
    figure(16)
    %hold on;
    plot(t(1:end-1),max_v,'k')
    %hold off;
    title('Evolution of the maximum');
    xlabel('time "t"');  ylabel('max(v)');
    figure(17)
    %hold on;
    plot(tt,EN,'k',tt(1),EN(1)+EN(1)/1000.0,tt(end),EN(end)-EN(end)/1000.0 )
    %hold off;
    title('Energy functional');
    xlabel('time "t"');  ylabel('EN');
  
    %DrawEnergyForHyperbolicBE( engine, tt );

     
     
   