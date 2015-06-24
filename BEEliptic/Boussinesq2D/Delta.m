function zeroMatrix=Delta(M,zeroMatrix,augFunctionPointsLeft,augFunctionPointsRigth,...
            augFunctionPointsBottom,augFunctionPointsTop,finiteDiff)
        
    zeroMatrix = YDerivative(M',zeroMatrix',augFunctionPointsLeft',augFunctionPointsRigth',finiteDiff)' +...
        YDerivative(M,zeroMatrix,augFunctionPointsBottom,augFunctionPointsTop,finiteDiff);
end