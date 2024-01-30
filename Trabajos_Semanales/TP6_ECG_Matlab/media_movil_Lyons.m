% Filename: DC_Removal_for_distribution.m
%
%    Models the " DC Removal" scheme using cascaded
%    recursive running sum (RRS) filters and subtracting  
%    the filter's output from a delayed version of the input.
%    Models single-stage, 2-stage, and 4-stage RRS filters.
%     Richard Lyons, April, 2018

clear, clc

% Set the desired delay line length
D = 31 % WARNING!! For a 1-stage DC blocker 'D' must be an odd number.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Design 1-, 2-, & 4-stage lowpass RRS (moving averaging) filters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
B_1Stage = (1/D)*[1, zeros(1,D-1), -1]; A_1Stage = [1, -1];
B_2Stage = conv(B_1Stage, B_1Stage); A_2Stage = conv(A_1Stage, A_1Stage);
B_4Stage = conv(B_2Stage, B_2Stage); A_4Stage = conv(A_2Stage, A_2Stage);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Add or delete the appropriate percent signs (%) in front of
%  'B_filter' variables to choose the number of deired RSS
%  stages (single-, two-, or four-)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Implement single-stage RSS
%B_filter = B_1Stage; A_filter = A_1Stage; B_delay_line = [zeros(1, (D-1)/2), 1]'; Order = 1;

% Implement two-stage RSS
B_filter = B_2Stage; A_filter = A_2Stage; B_delay_line = [zeros(1, D-1), 1]'; Order = 2;

% Implement four-stage RSS
%B_filter = B_4Stage; A_filter = A_4Stage; B_delay_line = [zeros(1, 2*D-2), 1]'; Order = 4;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analyze freq-domain performance of the DC-removal filter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[ImpRespFilter,T] = impz(B_filter, A_filter, 4*D+10);
[ImpRespDelay,T] = impz(B_delay_line, 1, 4*D+10);
ImpResp_DC_Remove_Filter = ImpRespDelay -ImpRespFilter;

H_Spec_mag = abs(fft(ImpResp_DC_Remove_Filter, 1024));
H_Spec_mag_dB = 20*log10(H_Spec_mag/max(H_Spec_mag));
%H_Spec_mag_dB = thresh(H_Spec_mag_dB, Threshold); % For plotting
FreqAxis = (0:1023)/(1024);
    
    figure(1), clf
    subplot(3,1,1), plot(FreqAxis, H_Spec_mag,'-r')
    axis([0, 0.5, 0, 1.1])
    title('FFT mag. of cascaded imp. responses')
    ylabel('Linear'), grid on, zoom on
    subplot(3,1,2), plot(FreqAxis, H_Spec_mag_dB,'-r')
    axis([0, 0.5, -30, 2])
    ylabel('dB'), grid on, zoom on
    subplot(3,1,3), plot(FreqAxis, H_Spec_mag_dB,'-r')
    axis([0, 0.2, -0.5, 0.1])
    ylabel('dB'), xlabel('Freq (times Fs)'), grid on, zoom on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute & plot group delay to show phase linearity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Turn off warning when plotting group delay
% warning off MATLAB:divideByZero,
[GD,W] = grpdelay(B_filter, A_filter, 1024, 'whole');

    figure(2), clf
    plot(W, GD,'-r', 'linewidth', 1)
    ylabel('Group delay (samples)'), xlabel('Freq in rad./sample')
    grid on, zoom on