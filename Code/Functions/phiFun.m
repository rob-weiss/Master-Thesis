function xk = phiFun(k, xkm1, ukm1, wkm1, Ts, eulerAnglesYPR)
%PHI_FUN System model

noisyEulerAnglesYPR = eulerAnglesYPR + wkm1(4:6,:);

xk = xkm1 + rotationMatrix(noisyEulerAnglesYPR) * (ukm1 + wkm1(1:3, :)) * Ts;

end

