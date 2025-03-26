function [grfs, zi] = getGRF(MyClient, zi)

% GRFS = Fy_l Fz_l Mx_l My_l Fy_r Fz_r Mx_r My_r
forcePlateData = pullForcePlateData(MyClient);
[grfs, zi] = filterForcePlateData(forcePlateData, zi);

