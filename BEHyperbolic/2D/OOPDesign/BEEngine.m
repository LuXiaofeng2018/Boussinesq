classdef (ConstructOnLoad) BEEngine
   % Class help goes here
  properties ( SetAccess = protected, GetAccess = public)
    %Discretization parameters
    x
    y
    h
    order
    tau
    tEnd
    estep
    % Equation parameters
    alpha
    beta1
    beta2
    beta
    c
    % IC
    u_t0
    dudt_t0
    mu
    theta
    % helpers
    sx
    sy
    eigenFinDiffMat
    IminusDHdiag
    minusDHdiag
    vdah
    %used to save maximum on the boundary for current iteration
    maximumOnBnd
  end 
  
  methods  %properties
    function [ value ] = get.x( this )
          value = this.x;
      end
      function [ value ] = get.y( this )
          value = this.y;
      end
  end
  
  methods ( Access = protected )
    % BEEngie internal
    function this = BEEngine( dscrtParams, eqParams, ic )
        % Method help here
        delete SOL\*
        if( dscrtParams.order ~= 2 && dscrtParams.order ~= 4 && dscrtParams.order ~= 6 )
            error( 'order must be a number among: 2, 4 and 6!' );
        end
        this.x = dscrtParams.x;
        this.y = dscrtParams.y;
        this.h = dscrtParams.h;
        this.order = dscrtParams.order;
        this.tau = dscrtParams.tau;
        this.tEnd = dscrtParams.tEnd;
        this.estep = dscrtParams.estep;

        this.alpha = eqParams.alpha;
        this.beta = eqParams.beta1/eqParams.beta2;
        this.c = eqParams.c;
        this.beta1 = eqParams.beta1;
        this.beta2 = eqParams.beta2;

        this.u_t0 = ic.u_t0;
        this.dudt_t0 = ic.dudt_t0;
        this.mu = ic.mu;
        this.theta = ic.theta;
        
        this.sy = length(this.y);
        this.sx = length(this.x);
        
        if( this.order == 4 )
            [ ff, dhb ] = BEUtilities.GetFinDiffMat( this.sx, this.h );
        else %this.order == 2
            [ dhb, ff ] = BEUtilities.GetFinDiffMat( this.sx, this.h );
        end
        [ this.eigenFinDiffMat, w ] = eig( -dhb );
        [ this.IminusDHdiag, this.minusDHdiag ] = this.DiagonalizeAndGetDiagOfFinDiffMat();
        this.vdah = zeros( this.sx, this.sy );
        numberOfBndPnts = this.order/2;
        this.maximumOnBnd = this.GetBndMax( this.u_t0, numberOfBndPnts );
    end
    
    % GetFd2ndDer internal
    function fd2ndDer = GetFd2ndDer( this )
        fdEndPoint = this.order/2;
        fd2ndDer = BEUtilities.GetFinDiffCoeff( -fdEndPoint:fdEndPoint, 2 )';
    end
    
    % GetFDIminusDH internal
    function [fd] = GetFDIminusDH( this )
        mid = ( this.order/2 + 1 );
        fd2ndDer = this.GetFd2ndDer( );
        fd2ndDer( mid ) = 2*fd2ndDer( this.order/2 + 1 ) - this.h^2;
        fd = - fd2ndDer;
    end
    
    % GetFDIminusDH internal
    function [fd] = GetFDminusDH( this )
        mid = ( this.order/2 + 1 );
        fd2ndDer = this.GetFd2ndDer( );
        fd2ndDer( mid ) = 2*fd2ndDer( this.order/2 + 1 );
        fd = - fd2ndDer;
    end
    
    % DiagonalizeAndGetDiagOfFinDiffMat internal
    function [ IminusDHdiag, minusDHdiag ] = DiagonalizeAndGetDiagOfFinDiffMat( this, sxSize )

        if( nargin == 1 )
            sxSize = this.sx
        end
        mid = ( this.order/2 + 1 );
        DD = zeros( 1, sxSize );
        IminusDHdiag = DD;
        minusDHdiag = DD;

        diag = this.GetFDIminusDH();
        diag2 = this.GetFDminusDH();
        for i = 1:sxSize
            IminusDHdiag(i) = this.eigenFinDiffMat(:,i)'*...
                BEUtilities.BandMatMult( diag, this.eigenFinDiffMat(:,i)', diag( mid )  )';%dhb*W(:,i);
            minusDHdiag(i) = this.eigenFinDiffMat(:,i)'*...
                BEUtilities.BandMatMult( diag2, this.eigenFinDiffMat(:,i)', diag2( mid ) )';
        end
    end
    
	% GetNonLinTerm internal
    function nonlinTerm = GetNonLinTerm( this, derOrd, fun )
         
        switch( derOrd )
             case 0,
                 nonlinTerm = this.alpha*this.beta*fun(:,:,1).*fun(:,:,1);
                 return;
             case 1, 
                 nonlinTerm = 2*this.alpha*this.beta*fun(:,:,2).*fun(:,:,1);
                 return;
             case 2,
                 nonlinTerm = 2*this.alpha*this.beta*(fun(:,:,2).*fun(:,:,2) + fun(:,:,1).*fun(:,:,3) );
                 return;
             case 3,
                 nonlinTerm = 2*this.alpha*this.beta*(3*fun(:,:,2).*fun(:,:,3) + fun(:,:,1).*fun(:,:,4) );
                 return;
             case 4,
                 nonlinTerm = 2*this.alpha*this.beta*(3*fun(:,:,3).*fun(:,:,3) + 4*fun(:,:,2).*fun(:,:,4) + fun(:,:,1).*fun(:,:,5));
                 return;                 
        end

    end
              
    function [ augDhDomainOnly ] = GetDhAugDomainOnly( this, t, cutCrap )
        
        if( nargin == 2 )
        end
        augDhDomainOnly = zeros( size( this.vdah, 1 ), size( this.vdah, 2), this.order-1 );
        domainUtilsP2 = BEDomainUtilsP2( this.x, this.y, this.order, this.beta, this.c, this.mu, this.theta );
        
        left = domainUtilsP2.GetDersBndLeft( t );
        right = domainUtilsP2.GetDersBndRight( t );
        top = domainUtilsP2.GetDersBndTop( t );
        btm = domainUtilsP2.GetDersBndBtm( t );
       
        fdEndPoint = this.order/2;
        fd2ndDer = BEUtilities.GetFinDiffCoeff( -fdEndPoint:fdEndPoint, 2 );
        for i =1:this.order-1
            augDhDomainOnly(:,:,i) = domainUtilsP2.YDerivative( this.vdah,...
                                                              left(:,:,i),...
                                                              right(:,:,i),...
                                                              fd2ndDer' );
            augDhDomainOnly(:,:,i) = augDhDomainOnly(:,:,i) +...
                                   domainUtilsP2.XDerivative( this.vdah,...
                                                              top(:,:,i),... 
                                                              btm(:,:,i),...
                                                              fd2ndDer' );
        end
        
        if( nargin == 2 )
            return;
        end
        numAuxPnts = this.order / 2;
        augDhDomainOnly = augDhDomainOnly( numAuxPnts+1:end - numAuxPnts,...
                                           numAuxPnts+1:end - numAuxPnts,: );
        
    end
    
    function [ augDtDomainOnly ] = GetDtAugDomainOnly( this, t, cutCrap )
        augDtDomainOnly = zeros( size( this.vdah, 1 ), size( this.vdah, 2), this.order-1 );
        domainUtilsP2 = BEDomainUtilsP2( this.x, this.y, this.order, this.beta, this.c, this.mu, this.theta );
        
        left = domainUtilsP2.GetDersBndLeft( t );
        right = domainUtilsP2.GetDersBndRight( t );
        top = domainUtilsP2.GetDersBndTop( t );
        btm = domainUtilsP2.GetDersBndBtm( t );
       
        fdEndPoint = this.order/2;
        fd2ndDer = BEUtilities.GetFinDiffCoeff( -fdEndPoint:fdEndPoint, 2 );
        for i =1:this.order-1
            augDtDomainOnly(:,:,i) = domainUtilsP2.YDerivative( this.vdah,...
                                                              left(:,:,i+2),...
                                                              right(:,:,i+2),...
                                                              fd2ndDer' );
            augDtDomainOnly(:,:,i) = augDtDomainOnly(:,:,i) +...
                                   domainUtilsP2.XDerivative( this.vdah,...
                                                              top(:,:,i+2),... 
                                                              btm(:,:,i+2),...
                                                              fd2ndDer' );
        end
        
        if( nargin == 2 )
            return;
        end
        numAuxPnts = this.order / 2;
        augDtDomainOnly = augDtDomainOnly( numAuxPnts+1:end - numAuxPnts,...
                                           numAuxPnts+1:end - numAuxPnts,: );
                                       
    end
    
    function [ augPowDomainOnly ] = GetPowAugDomainOnly( this, t )
        augPowDomainOnly = zeros( size( this.vdah, 1 ), size( this.vdah, 2), this.order-1 );
        domainUtilsP2 = BEDomainUtilsP2( this.x, this.y, this.order, this.beta, this.c, this.mu );
        
        left = domainUtilsP2.GetDersBndLeft( t );
        right = domainUtilsP2.GetDersBndRight( t );
        top = domainUtilsP2.GetDersBndTop( t );
        btm = domainUtilsP2.GetDersBndBtm( t );
       
        fdEndPoint = this.order/2;
        fd2ndDer = BEUtilities.GetFinDiffCoeff( -fdEndPoint:fdEndPoint, 2 );
        for i = 1:this.order-1
            nonlinTermLeft = this.GetNonLinTerm( i-1, left );
            nonlinTermRight = this.GetNonLinTerm( i-1, right );
            nonlinTermTop = this.GetNonLinTerm( i-1, top );
            nonlinTermBtm = this.GetNonLinTerm( i-1, btm );
            augPowDomainOnly(:,:,i) = domainUtilsP2.YDerivative( this.vdah,...
                                                              nonlinTermLeft,...
                                                              nonlinTermRight,...
                                                              fd2ndDer' );
            augPowDomainOnly(:,:,i) = augPowDomainOnly(:,:,i) +...
                                   domainUtilsP2.XDerivative( this.vdah,...
                                                              nonlinTermTop,... 
                                                              nonlinTermBtm,...
                                                              fd2ndDer' );
        end
    end
        
    function [ mmax ] = GetBndMax( this, vz, numberOfBndPnts )
        
        topMax = max( max( abs( vz( 1:numberOfBndPnts, : ) ) ) );
        leftMax = max( max( abs( vz( :, 1:numberOfBndPnts ) ) ) );
        btmMax = max( max( abs( vz( end-numberOfBndPnts+1:end, : ) ) ) );
        rightMax = max( max( abs( vz(:, end-numberOfBndPnts+1:end ) ) ) );
        mmax = max([ topMax leftMax btmMax rightMax ]);           
    end
    
    % Check for divergence on the boundary
    % Set maximum on the boundary first
    % 1 Divergence
    % 0 Ok
    
    function [ flag, maximum ] = CheckForDivergenceOnBnd( this, vz, numberOfBndPnts )
        
        mmax = GetBndMax( this, vz, numberOfBndPnts );

        if( mmax > 1.1 * this.maximumOnBnd )
            flag = 1; % Divergence
            maximum = 1.02 * this.maximumOnBnd;   % increase maximum on bnd
        else
            flag = 0; % Ok - do not change maximum on bnd
            maximum = this.maximumOnBnd; 
        end
           
    end
    
    function SaveSolutionOnIterStep( this, time, vu, vz, vmo )
        
        str = ['SOL\vu_' num2str( time ) '.mat'];
        save( str, 'vu' );
        
        if( nargin > 3 ) 
            str = ['SOL\vz_' num2str( time ) '.mat'];
            save( str, 'vz' );
        end
        
        if( nargin > 4 )
            str = ['SOL\vmo_' num2str( time ) '.mat'];
            save( str, 'vmo' ); 
        end        
    end
  end
  
  methods ( Abstract = true )
    % virtual:
    BESolver( this )
  end

  methods ( Access = public )      
          
      function [e] = GetEnergy( this, vz, vpo, t )
        
        vt = (vpo - vz)/this.tau;
        wvt = this.eigenFinDiffMat'*vt;
        
        domainUtilsP2 = BEDomainUtilsP2( this.x, this.y, this.order, this.beta, this.c, this.mu, this.theta );
        
        do = 0;
        %left = domainUtilsP2.GetDersBndLeft( t, do ) + domainUtilsP2.GetDersBndLeft( t + this.tau, do );
        %right = domainUtilsP2.GetDersBndRight( t, do ) + domainUtilsP2.GetDersBndRight( t + this.tau, do );
        %top = domainUtilsP2.GetDersBndTop( t, do ) + domainUtilsP2.GetDersBndTop( t + this.tau, do );
        %btm = domainUtilsP2.GetDersBndBtm( t, do ) + domainUtilsP2.GetDersBndBtm( t + this.tau, do );
        
        fd2ndDer = this.GetFd2ndDer();
        mid = ( this.order/2 + 1 );
        %idhv = vz+vpo - domainUtilsP2.DeltaH( vz+vpo, fd2ndDer, 0*left(:,:,1), 0*right(:,:,1), 0*top(:,:,1), 0*btm(:,:,1) )/this.h^2;
        idhv = vz+vpo - domainUtilsP2.DeltaH( vz+vpo, fd2ndDer )/this.h^2;
        VV = zeros( size( this.vdah ) );
        for j=1:this.sx
            diag = [ -fd2ndDer(1:mid-1) this.minusDHdiag(j) -fd2ndDer(mid+1:end) ]/this.h^2;
            %diag = [(1/12) (-16/12) this.IminusDHdiag(j) (-16/12) 1/12];
            if( this.order == 2 )      
                VV(j,:) = BEUtilities.TridiagSolv( diag, wvt(j,:) );
            end
            if( this.order == 4 )   
                VV(j,:) = BEUtilities.PentSolv( this.minusDHdiag(j), diag, wvt(j,:));
            end
        end
        
        vec1 = this.eigenFinDiffMat*VV;  %/h^2
        sigma = 0;  
        IDhvt = vt - domainUtilsP2.DeltaH( vt, fd2ndDer )/this.h^2;
        Le= this.h^2*( sum( sum( vec1.*vt ) ) ) + this.h^2 * sum( sum( vt.*vt ) ) +...
            this.h^2 * this.tau^2 * ( sigma - 1/4 ) * sum( sum( IDhvt.*vt ) ) +...
            (this.h^2/4) * sum( sum( idhv.*( vz+vpo ) ) );

        NLe = ( this.h^2*this.alpha*this.beta/3 ) * (  sum( sum( vz.^3 ) ) +...
              sum( sum( vpo.^3 ) ) ) + ( this.h^2 * ( this.beta-1 )/2 ) *...
              ( sum( sum( vz.^2 ) ) + sum( sum( vpo.^2 ) ) ); 

        e = Le + NLe;
  
      end
    
  end
end