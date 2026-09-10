clear
clc
warning off 

Run_dir = ['../../'];
addpath(Run_dir)
start
% warning off

HYCOM_Ini_parameter

Save_dir    = [pwd,'/Data'];
mkdir(Save_dir)

H_file      = 'hycom';
ref_time    = [2000 1 1 0 0 0];

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

T_ini = Ini_time;
time  = datenum(T_ini);
year  = T_ini(1);
month = T_ini(2);
day   = T_ini(3);
hour  = T_ini(4);
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
H_name = [year_num,month_num,day_num,hour_num];

if IF_Separate
file_name = [H_file,'*',H_name,'*',add_to_ssh,'.nc'];
else
file_name = [H_file,'*',H_name,'*.nc'];
end
filename  = dir([Data_dir,'/',file_name]);    
    
if ~isempty(filename)
    file_name = filename.name;
    if IF_Separate
    file_name = file_name(1:end-length([add_to_ssh,'.nc']));
    fileN = [Data_dir,'/',file_name,add_to_ssh,'.nc'];
    else
    file_name = file_name(1:end-length(['.nc']));
    fileN = [Data_dir,'/',file_name,'.nc'];
    end
    T_NUM   = ncload_1D(fileN,'time');
	T_NUM   = T_NUM/24; % hour to day
    T_NUM   = T_NUM  + datenum(ref_time);
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
    fileN  = [Data_dir,'/',file_name,add_to_temp,'.nc'];
    else
    fileN  = [Data_dir,'/',file_name,'.nc'];
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
    fileN = [Data_dir,'/',file_name,add_to_ssh,'.nc'];
    else
    fileN = [Data_dir,'/',file_name,'.nc'];
    end
    var_nam   = 'surf_el';
    lon_nam   = 'lon';
    lat_nam   = 'lat';
    wrt_nam   = 'ssh';
    [x,y,var] = ncload_2D_select(fileN,var_nam,lon_nam,lat_nam,lon_lim,lat_lim);
    [x,y]     = meshgrid(x,y);
    x         = reshape(x  ,size(x  ,1)*size(x  ,2),1);
    y         = reshape(y  ,size(y  ,1)*size(y  ,2),1);
    var       = reshape(var,size(var,1)*size(var,2),1);
    loc       = find(~isnan(var));
    x         = x(loc);
    y         = y(loc);
    var       = var(loc);
    var_s     = griddata(x,y,var,lonr,latr)';    
    var_s(isnan(var_s))=0;
    ncwrite(S_file,wrt_nam,var_s)    
    clear x y var var_s
          
    %TEMP   
    if IF_Separate
    fileN = [Data_dir,'/',file_name,add_to_temp,'.nc'];
    else
    fileN = [Data_dir,'/',file_name,'.nc'];
    end   
    var_nam   = 'water_temp'; 
    lon_nam   = 'lon';   
    lat_nam   = 'lat';    
    dep_nam   = 'depth'; 
    wrt_nam   = 'temp';    
    [X,Y,V]   = ncload_3D_select(fileN,var_nam,lon_nam,lat_nam,dep_nam,lon_lim,lat_lim);    
    [X,Y]     = meshgrid(X,Y);   
    for layer = 1:size(V,1)
        var       = squeeze(V(layer,:,:));
        x         = reshape(X  ,size(X  ,1)*size(X  ,2),1);
        y         = reshape(Y  ,size(Y  ,1)*size(Y  ,2),1);
        var       = reshape(var,size(var,1)*size(var,2),1);
        loc       = find(~isnan(var));
        if length(loc)>1
        x         = x(loc);
        y         = y(loc);
        var       = var(loc);
        var_s(:,:,layer)= griddata(x,y,var,lonr,latr)';
        else
        var_s(:,:,layer)= NaN;
        end
    end   
    ncwrite(S_file,wrt_nam,var_s)   
    clear x y var var_s
       
    %SALT    
    if IF_Separate
    fileN = [Data_dir,'/',file_name,add_to_salt,'.nc'];
    else
    fileN = [Data_dir,'/',file_name,'.nc'];
    end  
    var_nam   = 'salinity';   
    lon_nam   = 'lon';    
    lat_nam   = 'lat';    
    dep_nam   = 'depth';    
    wrt_nam   = 'salt';
    [X,Y,V]   = ncload_3D_select(fileN,var_nam,lon_nam,lat_nam,dep_nam,lon_lim,lat_lim);    
    [X,Y]     = meshgrid(X,Y);   
    for layer = 1:size(V,1)
        var       = squeeze(V(layer,:,:));
        x         = reshape(X  ,size(X  ,1)*size(X  ,2),1);
        y         = reshape(Y  ,size(Y  ,1)*size(Y  ,2),1);
        var       = reshape(var,size(var,1)*size(var,2),1);
        loc       = find(~isnan(var));
        if length(loc)>1
        x         = x(loc);
        y         = y(loc);
        var       = var(loc);
        var_s(:,:,layer)= griddata(x,y,var,lonr,latr)';
        else
        var_s(:,:,layer)= NaN;
        end
    end   
    ncwrite(S_file,wrt_nam,var_s)   
    clear x y var var_s
    
    %U   
    if IF_Separate
    fileN = [Data_dir,'/',file_name,add_to_u,'.nc'];
    else
    fileN = [Data_dir,'/',file_name,'.nc'];
    end
    var_nam   = 'water_u';    
    lon_nam   = 'lon';   
    lat_nam   = 'lat';    
    dep_nam   = 'depth';    
    wrt_nam   = 'u_eastward'; 
    [X,Y,V]   = ncload_3D_select(fileN,var_nam,lon_nam,lat_nam,dep_nam,lon_lim,lat_lim);    
    [X,Y]     = meshgrid(X,Y);   
    for layer = 1:size(V,1)
        var       = squeeze(V(layer,:,:));
        x         = reshape(X  ,size(X  ,1)*size(X  ,2),1);
        y         = reshape(Y  ,size(Y  ,1)*size(Y  ,2),1);
        var       = reshape(var,size(var,1)*size(var,2),1);
        loc       = find(~isnan(var));
        if length(loc)>1
        x         = x(loc);
        y         = y(loc);
        var       = var(loc);
        var_s(:,:,layer)= griddata(x,y,var,lonr,latr)';
        else
        var_s(:,:,layer)= NaN;
        end
    end   
    ncwrite(S_file,wrt_nam,var_s)   
    clear x y var var_s

    %V    
    if IF_Separate
    fileN = [Data_dir,'/',file_name,add_to_v,'.nc'];
    else
    fileN = [Data_dir,'/',file_name,'.nc'];
    end
    var_nam   = 'water_v';    
    lon_nam   = 'lon';    
    lat_nam   = 'lat';    
    dep_nam   = 'depth';   
    wrt_nam   = 'v_northward';   
    [X,Y,V]   = ncload_3D_select(fileN,var_nam,lon_nam,lat_nam,dep_nam,lon_lim,lat_lim);    
    [X,Y]     = meshgrid(X,Y);   
    for layer = 1:size(V,1)
        var       = squeeze(V(layer,:,:));
        x         = reshape(X  ,size(X  ,1)*size(X  ,2),1);
        y         = reshape(Y  ,size(Y  ,1)*size(Y  ,2),1);
        var       = reshape(var,size(var,1)*size(var,2),1);
        loc       = find(~isnan(var));
        if length(loc)>1
        x         = x(loc);
        y         = y(loc);
        var       = var(loc);
        var_s(:,:,layer)= griddata(x,y,var,lonr,latr)';
        else
        var_s(:,:,layer)= NaN;
        end
    end   
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

