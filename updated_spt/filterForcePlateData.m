function [data_filtered, zi] = filterForcePlateData(forcePlateData, zi)
    % 3rd order, 25 Hz, Butterworth Filter, sampling at 100Hz
    numerator = [0.16666667 0.5 0.5 0.16666667];
    denominator = [1.00000000e+00 -2.73695628e-16 3.33333333e-01 -1.85037171e-17];
    [data_filtered, zi] = filter(numerator, denominator, forcePlateData, zi, 1);
    