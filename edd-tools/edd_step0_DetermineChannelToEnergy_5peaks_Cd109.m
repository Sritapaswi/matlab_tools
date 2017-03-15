clear all
close all
clc

proot   = '/home/s1b/__eval/projects_parkjs/edd_6bm_2017-1/startup_mar17';

format long
%%%%%%%%%%%%%%%%%
% INPUT
%%%%%%%%%%%%%%%%%
% USE Cd109 decay data
%%% DET1
% pname_Cd109_spec    = 'det1_Cd109_120s';
% fname_Cd109_spec    = 'det1_Cd109_120s-001-hv.xy';
% det_id  = 1;

%%% DET2
pname_Cd109_spec    = 'det2_Cd109_120s';
fname_Cd109_spec    = 'det2_Cd109_120s-001-hv.xy';
det_id  = 2;
%%%%%

pfname_Cd109_spec   = fullfile(proot, pname_Cd109_spec, fname_Cd109_spec);
data    = load(pfname_Cd109_spec);

x   = 1:1:8192;
if det_id == 1
    y   = data(:,1); %%% ChToEnergyConversion    = [0.0347612 0.0375123];
elseif det_id == 2
    y   = data(:,2); %%% ChToEnergyConversion    = [0.0347878 0.00546895];
end

%%%%%%%%%%%%%%%
% Cd109 radioactive decay data (keV) - lbl.gov
% E  88.045 2.634 2.806 2.978 2.984 3.15 3.203 3.234 3.256 3.348 3.520 3.743 3.750 21.708 21.990 22.163 24.912 24.943 25.144 25.455 25.511
% I    3.61 0.183 0.508 4.57 2.64 0.144 0.226 0.0305 0.589 0.284 0.0277 0.045 0.00122 29.5 55.7 4.79 9.23 0.0673 2.31 0.487
Cd109_energy	= load('Cd109.decay.data');

%%%%%%%%%%%%%%%%%
% INITIAL GUESS FOR DECAY PEAKS
x0  = [595; 635; 716; 731; 2531];  % v
y0  = [5000; 90570; 20079; 5091; 5091].*50;
g0  = ones(length(x0), 1).*10;
n0  = ones(length(x0), 1).*0.5;
p0  = [y0 g0 n0 x0]';
p0  = p0(:);
p0  = [p0; 0; 1];
pLB = [0; 0; 0; x0(1)-3; 0; 0; 0; x0(2)-3; 0; 0; 0; x0(3)-3; 0; 0; 0; x0(4)-3; 0; 0; 0; x0(5)-3; -inf; -inf];
pUB = [inf; inf; 1; x0(1)+3; inf; inf; 1; x0(2)+3; inf; inf; 1; x0(3)+3; inf; inf; 1; x0(4)+3; inf; inf; 1; x0(5)+3; inf; inf];
%%%%%%%%%%%%%%%%%

p       = lsqcurvefit(@pfunc, p0, x, y, pLB, pUB);

yfit0   = pfunc(p0, x);
yfit    = pfunc(p, x);

Rwp     = ErrorRwp(y, yfit);
Re      = ErrorRe(y, yfit);
Rp      = ErrorRp(y, yfit);

figure(1)
axes('Position', [0.130 0.345238 0.775 0.579762]);
hold on
plot(x, y, 'r.');
plot(x, yfit0, 'g:')
plot(x, yfit, 'k-');
grid on
xlabel('channel number')
ylabel('counts')    
axis([x(1) x(end) min(y) max(y)])

axes('Position', [0.130 0.115 0.775 0.118]);
hold on
plot(x, (y-yfit0)./y, 'g:');
plot(x, (y-yfit)./y, 'k-');
grid on
xlabel('channel number')
ylabel('difference ratio')    
axis([x(1) x(end) min((y-yfit0)./y) max((y-yfit0)./y)])

% ChToEnergyEquivalence   = [ ...
%     p(8) sum(Cd109_energy(14:16,1).*Cd109_energy(14:16,2))./sum(Cd109_energy(14:16,2)); ...
%     p(12) sum(Cd109_energy(17:21,1).*Cd109_energy(17:21,2))./sum(Cd109_energy(17:21,2)); ...
%     p(16) Cd109_energy(1); ...
%     ];

ChToEnergyEquivalence   = [ ...
    p(4) sum(Cd109_energy(14:16,1).*Cd109_energy(14:16,2))./sum(Cd109_energy(14:16,2)); ...
    p(8) sum(Cd109_energy(17:18,1).*Cd109_energy(17:18,2))./sum(Cd109_energy(17:18,2)); ...
    p(12) sum(Cd109_energy(19:21,1).*Cd109_energy(19:21,2))./sum(Cd109_energy(19:21,2)); ...
    p(16) Cd109_energy(1); ...
    ];

ChToEnergyConversion    = polyfit(ChToEnergyEquivalence(:,1), ChToEnergyEquivalence(:,2) , 1);

disp(sprintf('Channel to Energy relathionship'));
disp(sprintf('E (keV) = m * ChannelNumber + b'));
disp(sprintf('m = %f', ChToEnergyConversion(1)));
disp(sprintf('b = %f', ChToEnergyConversion(2)));
disp(sprintf('Channel Number starts from 1'));
disp(sprintf('************* ATTENTION | ACHTUNG | FIGYELEM *****************'))
disp(sprintf('Copy the following command into LINE 8 on step1_DetermineTOA.m'))
disp(sprintf('ChToEnergyConversion    = [%g %g];', ChToEnergyConversion(1), ChToEnergyConversion(2)));
