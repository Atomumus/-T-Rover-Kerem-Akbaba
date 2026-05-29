function [y0, state_names, units] = sorensen_initial_conditions(p)
%SORENSEN_INITIAL_CONDITIONS Return fasting initial state for Sorensen ODEs.

y0 = [
    p.GBV0;      %  1: Brain vascular glucose
    p.GBI0;      %  2: Brain interstitial glucose
    p.GH0;       %  3: Heart-lung/systemic glucose
    p.GG0;       %  4: Gut glucose
    p.GL0;       %  5: Liver glucose
    p.GK0;       %  6: Kidney glucose
    p.GPV0;      %  7: Peripheral vascular glucose
    p.GPI0;      %  8: Peripheral interstitial glucose
    p.IB0;       %  9: Brain insulin
    p.IH0;       % 10: Heart-lung/systemic insulin
    p.IG0;       % 11: Gut insulin
    p.IL0;       % 12: Liver insulin
    p.IK0;       % 13: Kidney insulin
    p.IPV0;      % 14: Peripheral vascular insulin
    p.IPI0;      % 15: Peripheral interstitial insulin
    p.Gamma0;    % 16: Glucagon
    p.qsto1_0;   % 17: Stomach solid phase
    p.qsto2_0;   % 18: Stomach liquid phase
    p.qgut1_0;   % 19: Intestine segment 1
    p.qgut2_0;   % 20: Intestine segment 2
    p.qgut3_0;   % 21: Intestine segment 3
    p.qspl_0;    % 22: Splanchnic glucose
];

state_names = {
    'GBV'; 'GBI'; 'GH'; 'GG'; 'GL'; 'GK'; 'GPV'; 'GPI'; ...
    'IB'; 'IH'; 'IG'; 'IL'; 'IK'; 'IPV'; 'IPI'; 'Gamma'; ...
    'qsto1'; 'qsto2'; 'qgut1'; 'qgut2'; 'qgut3'; 'qspl'
};

units = {
    'mg/dL'; 'mg/dL'; 'mg/dL'; 'mg/dL'; 'mg/dL'; 'mg/dL'; 'mg/dL'; 'mg/dL'; ...
    'mU/L'; 'mU/L'; 'mU/L'; 'mU/L'; 'mU/L'; 'mU/L'; 'mU/L'; 'pg/mL'; ...
    'mg'; 'mg'; 'mg'; 'mg'; 'mg'; 'mg'
};

end
