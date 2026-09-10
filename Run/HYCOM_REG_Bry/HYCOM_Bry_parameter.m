% Time and coordinate control
%--------------------------------------------------------------------------
title       = 'Bavi';
time_begin  = [2026 7 2  0 0 0];
time_end    = [2026 7 14 0 0 0];
obc         = [1 1 1 1];
theta_s     = 4.5;
theta_b     = 1.5;
hc          = 5;
layer_N     = 50;       
%--------------------------------------------------------------------------
Data_dir    = ['E:\application\TC_Bavi\Bavi\HYCOM\HYCOM_ESPC-D-V02_20260701_15'];
IF_Separate = 1;
add_to_ssh  = '_ssh';
add_to_temp = '_t3z';
add_to_salt = '_s3z';
add_to_u    = '_u3z';
add_to_v    = '_v3z';
%--------------------------------------------------------------------------
IF_Monthly_output = 0;
