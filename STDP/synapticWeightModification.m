% SYNAPTICWEIGHTMODIFICATION Function from Graphitti STDP implementation
%
%   Used to graph the STDPLearning function in plotSTDPLearning.m. Outputs
%   the fractional synaptic weight change based on the deltaT input value.
%
%   Syntax: synapticWeightModification(deltaT)
%
%   Input:  
%   delatT  - the time between pre/post spikes
%
%   Output:
%   dw - the fractional synaptic weight change
%   
%
% Author: Vanessa Arndorfer (vanessa.arndorfer@gmail.com)

function dw = synapticWeightModification(deltaT)

% Values taken from Graphitti/configfiles/stdp_fE_0.90_10000.xml
Aneg = -0.26;
Apos = 0.52;
tauneg = 0.0338;
taupos = 0.0148;
STDPGap = 0.002;

dw = int64(0);
if deltaT < -STDPGap
    dw = Aneg * exp(deltaT / tauneg);
elseif deltaT > STDPGap
    dw = Apos * exp(-deltaT / taupos);
end


