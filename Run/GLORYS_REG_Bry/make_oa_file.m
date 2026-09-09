clear
clc
warning off 

Run_dir = ['../../'];
addpath(Run_dir)
start
% warning off

GLORYS_Bry_parameter

Save_dir    = [pwd,'/Data'];
mkdir(Save_dir)

T_buffer    = 1;
T_beg       = datenum(time_begin) - T_buffer;
T_end       = datenum(time_end)   + T_buffer;

H_file      = 'glorys';
ref_time    = [1950 1 1 0 0 0];

grd_file    = [Run_dir,'/Data/Grd.nc'];
h           = ncload_2D(grd_file,'h');
lonr        = ncload_2D(grd_file,'lon_rho');
latr        = ncload_2D(grd_file,'lat_rho');
lonu        = ncload_2D(grd_file,'lon_u');
latu        = ncload_2D(grd_file,'lat_u');
lonv        = ncload_2D(grd_file,'lon_v');
latv        = ncload_2D(grd_file,'lat_v');
angleNC     = ncload_2D(grd_file,'angle');
angle(:,:,1)= angleNC';
[Mp,Lp]     = size(h);
L           = Lp-1;
M           = Mp-1;
ddl         = 1;
lon_lim     = [min(min(lonr))-ddl,max(max(lonr))+ddl];
lat_lim     = [min(min(latr))-ddl,max(max(latr))+ddl];

if IF_Separate
file_name = [add_to_ssh,'*.nc'];
else
file_name = ['*.nc'];
end

filename  = dir([Data_dir,'/',file_name]);
    
if ~isempty(filename)
    for N = 1:length(filename)  
        file_name = filename(N).name;
        if IF_Separate
        file_name = file_name(length(add_to_ssh)+1:end);
        fileN = [Data_dir,'/',add_to_ssh,file_name];
        else
        file_name = file_name(1:end-length(['.nc']));
    	fileN = [Data_dir,'/',file_name,'.nc'];
        end
        T_NUM   = ncload_1D(fileN,'time');
        T_NUM   = T_NUM/24; % hour to day
        T_NUM   = T_NUM  + datenum(ref_time);
        
    if T_NUM>=T_beg&&T_NUM<=T_end
        TIME  = datevec(T_NUM);
        time  = T_NUM;
        year  = TIME(1);
        month = TIME(2);
        day   = TIME(3);
        hour  = TIME(4);
        year_num = num2str(year);
        if month<10
            month_num = ['0',num2str(month)];
        else
            month_num = num2str(month);
        end
        if day<10
            day_num = ['0',num2str(day)];
        else
            day_num = num2str(day);
        end
        if hour<10
            hour_num = ['0',num2str(hour)];
        else
            hour_num = num2str(hour);
        end
        T_name = [year_num,'-',month_num,'-',day_num,'-',hour_num,':00:00'];
        S_name = [year_num,'-',month_num,'-',day_num,'-',hour_num,'-00-00'];
        disp([' '])   
        disp(['Date: ',T_name])   
        
        %Depth
        if IF_Separate
        fileN  = [Data_dir,'/',add_to_temp,file_name];
        else
        fileN  = [Data_dir,'/',file_name];
        end
        depth  = ncload_1D(fileN,'depth'); 
        
        %create oa file
        Dp     = length(depth);
        S_file = [Save_dir,'/',H_file,'_',S_name,'.nc'];
        delete(S_file)
        creat_oa_file(S_file,Lp,Mp,Dp)
        ncwrite(S_file,'time' ,time)
        ncwrite(S_file,'depth',depth)

        %SSH
        if IF_Separate
        fileN = [Data_dir,'/',add_to_ssh,file_name];
        else
        fileN = [Data_dir,'/',file_name];
        end
        var_nam   = 'zos';
        lon_nam   = 'longitude';
        lat_nam   = 'latitude';
        wrt_nam   = 'ssh';
        [x,y,var] = ncload_2D_select(fileN,var_nam,lon_nam,lat_nam,lon_lim,lat_lim);
        var_s     = interp2(x,y,var,lonr,latr)';
        var_s(isnan(var_s))=0;
        ncwrite(S_file,wrt_nam,var_s)
        clear x y var var_s
      
        %TEMP
        if IF_Separate
        fileN = [Data_dir,'/',add_to_temp,file_name];
        else
        fileN = [Data_dir,'/',file_name];
        end
        var_nam   = 'thetao';
        lon_nam   = 'longitude';
        lat_nam   = 'latitude'; 
        dep_nam   = 'depth';
        wrt_nam   = 'temp';
        [x,y,var] = ncload_3D_select(fileN,var_nam,lon_nam,lat_nam,dep_nam,lon_lim,lat_lim);
        [x,y]     = meshgrid(x,y);
        for layer = 1:size(var,1)
            var_s(:,:,layer)= interp_ocean(x,y,squeeze(var(layer,:,:)),lonr,latr)';
        end
        ncwrite(S_file,wrt_nam,var_s)
        clear x y var var_s
        
        %SALT
        if IF_Separate
        fileN = [Data_dir,'/',add_to_salt,file_name];
        else
        fileN = [Data_dir,'/',file_name];
        end
        var_nam   = 'so';
        lon_nam   = 'longitude';
        lat_nam   = 'latitude';
        dep_nam   = 'depth';
        wrt_nam   = 'salt';
        [x,y,var] = ncload_3D_select(fileN,var_nam,lon_nam,lat_nam,dep_nam,lon_lim,lat_lim);
        [x,y]     = meshgrid(x,y);
        for layer = 1:size(var,1)
            var_s(:,:,layer)= interp_ocean(x,y,squeeze(var(layer,:,:)),lonr,latr)';
        end
        ncwrite(S_file,wrt_nam,var_s)
        clear x y var var_s
       
        %U
        if IF_Separate
        fileN = [Data_dir,'/',add_to_u,file_name];
        else
        fileN = [Data_dir,'/',file_name];
        end
        var_nam   = 'uo';
        lon_nam   = 'longitude';
        lat_nam   = 'latitude';
        dep_nam   = 'depth';
        wrt_nam   = 'u_eastward';
        [x,y,var] = ncload_3D_select(fileN,var_nam,lon_nam,lat_nam,dep_nam,lon_lim,lat_lim);
        for layer = 1:size(var,1)
            var_s(:,:,layer)= interp2(x,y,squeeze(var(layer,:,:)),lonr,latr)';
        end
        var_s(isnan(var_s))=0;
        ncwrite(S_file,wrt_nam,var_s)
        clear x y var var_s
        
        %V
        if IF_Separate
        fileN = [Data_dir,'/',add_to_v,file_name];
        else
        fileN = [Data_dir,'/',file_name];
        end
        var_nam   = 'vo';
        lon_nam   = 'longitude';
        lat_nam   = 'latitude';
        dep_nam   = 'depth';
        wrt_nam   = 'v_northward';
        [x,y,var] = ncload_3D_select(fileN,var_nam,lon_nam,lat_nam,dep_nam,lon_lim,lat_lim);
        for layer = 1:size(var,1)
            var_s(:,:,layer)= interp2(x,y,squeeze(var(layer,:,:)),lonr,latr)';
        end
        var_s(isnan(var_s))=0;
        ncwrite(S_file,wrt_nam,var_s)
        clear x y var var_s

        % U&V Rotation
        u_east  = ncread(S_file,'u_eastward');
        v_north = ncread(S_file,'v_northward');
        u_roms  = u_east.*cos(angle)+v_north.*sin(angle);
        v_roms  =-u_east.*sin(angle)+v_north.*cos(angle);
        u_roms  =(u_roms(1:end-1,:,:)+u_roms(2:end,:,:))/2;
        v_roms  =(v_roms(:,1:end-1,:)+v_roms(:,2:end,:))/2;
        ncwrite(S_file,'u',u_roms)
        ncwrite(S_file,'v',v_roms)
    end

    end
end
