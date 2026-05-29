function dydt = sorensen_odes(t, y, p, u_ins, meal_input)
%SORENSEN_ODES Revised Sorensen glucose-insulin-glucagon ODE system.
%
% Inputs:
%   t          - time [min]
%   y          - 22-state model vector
%   p          - parameter struct from sorensen_parameters
%   u_ins      - external insulin input [mU/min] or function handle
%   meal_input - oral glucose input [mg/min] or function handle

dydt = zeros(22, 1);

%% State unpacking
GBV = y(1);  GBI = y(2);  GH = y(3);   GG = y(4);
GL  = y(5);  GK  = y(6);  GPV = y(7);  GPI = y(8);
IB  = y(9);  IH  = y(10); IG  = y(11); IL  = y(12);
IK  = y(13); IPV = y(14); IPI = y(15);
Gamma = y(16);
qsto1 = y(17); qsto2 = y(18); qgut1 = y(19);
qgut2 = y(20); qgut3 = y(21); qspl = y(22);

%% Inputs
if isa(meal_input, 'function_handle')
    Dmeal = meal_input(t);
else
    Dmeal = meal_input;
end

if isa(u_ins, 'function_handle')
    ins_input = max(u_ins(t), 0);
else
    ins_input = max(u_ins, 0);
end

%% Metabolic rates
rgut = p.f * p.Krj * qspl;

rBGU = p.rBGU;
rHCE = p.rHCE;

GPI_norm = GPI / p.GPI0;
IPI_norm = IPI / p.IPI0;
rPGU = max(p.KPGU * GPI_norm * IPI_norm, 0);

x_IH  = IH / p.IH0;
x_Gam = Gamma / p.Gamma0;
x_GL  = GL / p.GL0;
rHGP = p.rHGP0 * max(0, 0.5 * (1 - x_IH) + 0.5 * x_Gam + 0.5);
rHGL = p.rHGL0 * max(0, 0.5 * x_GL + 0.3 * x_IH + 0.2);

if GK > p.GK_thr
    rGEX = 0.872 * (GK - p.GK_thr) / p.VKG;
else
    rGEX = 0;
end

rLIC = p.Klr * IL;
rKIC = p.Kkic * IK;
rPDU = max((IPI / p.IPI0) * p.rPDU0, 0);

G_ratio = GH / p.GH0;
Y_G = G_ratio ^ 3.27;
rPIR = max(p.rPIR0 * Y_G, 0);

rPGR = p.rPGR0 * max(0, 1.5 - GH / p.GH0);
rGNC = p.rGNC0 * Gamma;

%% ODE system: glucose states
diff_brain = (p.VBI / p.TB) * (GBV - GBI);
diff_peri  = (p.VPI / p.TPG) * (GPV - GPI);

dydt(1) = (1 / p.VBV_G) * (p.QBG * (GH - GBV) - diff_brain);
dydt(2) = (1 / p.VBI)   * (diff_brain - rBGU);
dydt(3) = (1 / p.VHG)   * (p.QBG * GBV + p.QKG * GK + p.QPG_V * GPV ...
    + p.QLG * GL - p.QHG * GH - rHCE);
dydt(4) = (1 / p.VGG)   * (p.QGG * (GH - GG) + rgut);
dydt(5) = (1 / p.VLG)   * (p.QAG * GH + p.QGG * GG - p.QLG * GL + rHGP - rHGL);
dydt(6) = (1 / p.VKG)   * (p.QKG * (GH - GK) - rGEX);
dydt(7) = (1 / p.VPV_G) * (p.QPG_V * (GH - GPV) - diff_peri);
dydt(8) = (1 / p.VPI)   * (diff_peri - rPGU);

%% ODE system: insulin states
diff_ins = (p.VPII / p.TPI) * (IPV - IPI);

dydt(9)  = (1 / p.VBI_I) * (p.QBI * (IH - IB));
dydt(10) = (1 / p.VHI)   * (p.QBI * IB + p.QKI * IK + p.QPI * IPV ...
    + p.QLI * IL - p.QHI * IH + ins_input);
dydt(11) = (1 / p.VGI)   * (p.QGI * (IH - IG));
dydt(12) = (1 / p.VLI)   * (p.QAI * IH + p.QGI * IG - p.QLI * IL + rPIR - rLIC);
dydt(13) = (1 / p.VKI)   * (p.QKI * (IH - IK) - rKIC);
dydt(14) = (1 / p.VPV_I) * (p.QPI * (IH - IPV) - diff_ins);
dydt(15) = (1 / p.VPII)  * (diff_ins - rPDU);

%% ODE system: glucagon
dydt(16) = rPGR - rGNC;

%% ODE system: gastrointestinal absorption
dydt(17) = -p.Kjs * qsto1 + Dmeal;
dydt(18) =  p.Kjs * qsto1 - p.Kjs * qsto2;
dydt(19) =  p.Kjs * qsto2 - p.Kgj * qgut1;
dydt(20) =  p.Kgj * qgut1 - p.Kgj * qgut2;
dydt(21) =  p.Kgj * qgut2 - p.Kgl * qgut3;
dydt(22) =  p.Kgl * qgut3 - p.Krj * qspl;

end
