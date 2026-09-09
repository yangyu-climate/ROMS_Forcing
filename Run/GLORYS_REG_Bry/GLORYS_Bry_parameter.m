% Time and coordinate control
%--------------------------------------------------------------------------
title       = 'NESS';
time_begin  = [2026 2 20 0 0 0];
time_end    = [2026 2 25 0 0 0];
obc         = [1 1 1 1];
theta_s     = 6.0;
theta_b     = 2.0;
hc          = 250;
layer_N     = 40;
%--------------------------------------------------------------------------
Data_dir    = ['F:\Data\GLORYS\glorys_reanalysis'];
IF_Separate = 1;
add_to_ssh  = 'zos_';
add_to_temp = 'thetao_';
add_to_salt = 'so_';
add_to_u    = 'uo_';
add_to_v    = 'vo_';
%--------------------------------------------------------------------------
IF_Monthly_output = 0;
