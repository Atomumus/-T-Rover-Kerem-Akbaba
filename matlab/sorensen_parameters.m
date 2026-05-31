function p = sorensen_parameters()
%SORENSEN_PARAMETERS Physiological parameters for the revised Sorensen model.
%
% The basal values in this file are chosen so that the fasting state is an
% equilibrium of sorensen_odes when there is no meal input and no external
% insulin input. This is the parameter set used by the Student 3 open-loop
% steady-state validation.

%% Glucose sub-model parameters
p.VBV_G  = 3.5;    p.VBI    = 4.5;    p.VHG    = 13.8;   p.VGG    = 11.2;
p.VLG    = 25.1;   p.VKG    = 6.6;    p.VPV_G  = 10.4;   p.VPI    = 67.4;

p.QBG    = 5.9;    p.QHG    = 43.7;   p.QAG    = 2.5;    p.QGG    = 10.1;
p.QLG    = 12.6;   p.QKG    = 10.1;   p.QPG_V  = 15.1;

p.TB     = 2.1;    p.TPG    = 5.0;

%% Insulin sub-model parameters
p.VBI_I  = 0.26;   p.VHI    = 0.99;   p.VGI    = 0.94;   p.VLI    = 1.14;
p.VKI    = 0.51;   p.VPV_I  = 0.74;   p.VPII   = 6.74;   p.VPI_I  = 6.74;

p.QBI    = 0.45;   p.QHI    = 3.12;   p.QAI    = 0.18;   p.QGI    = 0.72;
p.QLI    = 0.90;   p.QKI    = 0.72;   p.QPI    = 1.05;

p.TPI    = 20.0;

%% Panunzi-style revised parameters
p.Kjs    = 0.026;  p.Kgl    = 0.035;  p.Kgj    = 0.032;  p.Krj    = 0.029;
p.Klr    = 0.026;  p.f      = 1.0;

p.alpha  = 0.014;  p.beta   = 15.558; p.K_pan  = 0.0145; p.gamma  = 2138.76;
p.M1     = 0.00012;p.M2     = 0.2488; p.Q0     = 44310;

p.bpir1  = 4.164;  p.bpir2  = 3.776;  p.bpir3  = 1.837;  p.bpir4  = 3.577;
p.bpir5  = 2.876;

p.Klic   = 0.4;    p.Kkic   = 0.3;    p.GK_thr = 460.0;  p.rGEX_max = 6.0;

%% Basal targets
p.GH0    = 91.0;   % Systemic blood glucose target [mg/dL]
p.IH0    = 15.0;   % Plasma insulin target [mU/L]
p.Gamma0 = 100.0;  % Glucagon target [pg/mL]

%% Basal metabolic rates
p.rBGU   = 70.0;   % Brain glucose uptake
p.KPGU   = 35.0;   % Peripheral glucose uptake coefficient
p.rHCE   = 0.0;    % Heart/erythrocyte consumption, neglected here
p.rPDU0  = 1.5;    % Basal peripheral insulin degradation

%% Basal glucose states from algebraic steady-state balances
p.GBV0 = p.GH0 - p.rBGU / p.QBG;
p.GBI0 = p.GBV0 - p.rBGU * p.TB / p.VBI;

p.GPV0 = p.GH0 - p.KPGU / p.QPG_V;
p.GPI0 = p.GPV0 - p.KPGU * p.TPG / p.VPI;

p.GK0 = p.GH0;
p.GG0 = p.GH0;

p.GL0 = (p.QHG * p.GH0 + p.rHCE ...
    - (p.QBG * p.GBV0 + p.QKG * p.GK0 + p.QPG_V * p.GPV0)) / p.QLG;

p.rHGP0 = 155.0;
p.rHGL0 = p.rHGP0 + p.QAG * p.GH0 + p.QGG * p.GG0 - p.QLG * p.GL0;

%% Basal insulin states from algebraic steady-state balances
p.IB0 = p.IH0;
p.IG0 = p.IH0;
p.IK0 = (p.QKI * p.IH0) / (p.QKI + p.Kkic);

p.IPV0 = p.IH0 - p.rPDU0 / p.QPI;
p.IPI0 = p.IPV0 - p.rPDU0 * p.TPI / p.VPII;

p.IL0 = (p.QHI * p.IH0 ...
    - (p.QBI * p.IB0 + p.QKI * p.IK0 + p.QPI * p.IPV0)) / p.QLI;

% In sorensen_odes, the basal glucose ratio gives Y_G = 1. Therefore rPIR0
% must equal the basal secretion required by the liver insulin balance.
p.rPIR0 = p.QLI * p.IL0 + p.Klr * p.IL0 - (p.QAI * p.IH0 + p.QGI * p.IG0);

%% Basal glucagon balance
p.rPGR0 = 5.0;
p.rGNC0 = (p.rPGR0 * 0.5) / p.Gamma0;

%% Gastrointestinal fasting initial values
p.qsto1_0 = 0.0;  p.qsto2_0 = 0.0;  p.qgut1_0 = 0.0;
p.qgut2_0 = 0.0;  p.qgut3_0 = 0.0;  p.qspl_0  = 0.0;

%% Pancreatic pools retained for compatibility with extended versions
p.Q1_0 = p.Q0;
p.Q2_0 = p.Q0;

end
