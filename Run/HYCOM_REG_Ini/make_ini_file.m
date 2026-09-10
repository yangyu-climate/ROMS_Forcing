clear
clc

Run_dir = ['../../'];
addpath(Run_dir)
start
% warning off

HYCOM_Ini_parameter

H_file      = 'hycom';
G_file      = [Run_dir,'Data/Grd.nc'];
S_file      = 'Ini'; 
clobber     = 'write';      
vtransform  = 2;
type        = 'r';

Data_dir    = [pwd,'/Data'];
Save_dir    = [pwd,'/Result'];
mkdir(Save_dir)

grd_file    = G_file;
h           = ncload_2D(grd_file,'h');
lonr        = ncload_2D(grd_file,'lon_rho');
latr        = ncload_2D(grd_file,'lat_rho');
lonu        = ncload_2D(grd_file,'lon_u');
latu        = ncload_2D(grd_file,'lat_u');
lonv        = ncload_2D(grd_file,'lon_v');
latv        = ncload_2D(grd_file,'lat_v');

T       = datenum(Ini_time);
TIME    = datevec(T);
year    = TIME(1);
month   = TIME(2);
day     = TIME(3);
hour    = TIME(4);
tini    = 0;
ininame = [Save_dir,'/',S_file,'_',num2str(year),'.nc'];
grdname = G_file;
delete(ininame)
create_inifile(ininame,grdname,title,...
               theta_s,theta_b,hc,layer_N,...
               tini,clobber,vtransform)
      
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
T_num = [year_num,'-',month_num,'-',day_num,'-',hour_num,':00:00'];         
S_num = [year_num,'-',month_num,'-',day_num,'-',hour_num,'-00-00'];

T_file    = S_num;          
file_name = [H_file,'*',T_file,'*'];             
filename  = dir([Data_dir,'/',file_name]);
 
if ~isempty(filename)     
    disp(T_num)
    file_name = filename.name;
    fileN = [Data_dir,'/',file_name];           
    disp(['Load data from: ',fileN])
    depth = ncload_0D(fileN,'depth');    
    dep   = [0;depth];    
    dep   = dep(2:end)-dep(1:end-1); 
    
    nc    = netcdf(fileN);  
    zeta  = squeeze(nc{'ssh'}(:));
    TEMP  = squeeze(nc{'temp'}(:));
    SALT  = squeeze(nc{'salt'}(:));
    U     = squeeze(nc{'u'}(:));
    V     = squeeze(nc{'v'}(:));
    close(nc)
    
    Z_U   = griddata(lonr,latr,zeta,lonu,latu);
    Z_V   = griddata(lonr,latr,zeta,lonv,latv);
    H_U   = griddata(lonr,latr,h   ,lonu,latu);
    H_V   = griddata(lonr,latr,h   ,lonv,latv);
    
    % Temp & Salt
    for i=1:size(zeta,1)
        for j=1:size(zeta,2)
            HH   = h(i,j);
            ZZ   = zeta(i,j);
            D    = -zlevs(HH,ZZ,theta_s,theta_b,hc,layer_N,type,vtransform);
            varT = interp1(depth,squeeze(TEMP(:,i,j)),D);
            varS = interp1(depth,squeeze(SALT(:,i,j)),D);
            varT(D<min(dep)) = TEMP(1,i,j);
            varS(D<min(dep)) = SALT(1,i,j);
            locT = find(~isnan(varT));
            locS = find(~isnan(varS));
            if ~isempty(locT)&&~isempty(locS)
            varT(isnan(varT)&D>5) = varT(min(locT));
            varS(isnan(varS)&D>5) = varS(min(locS));
            end
            temp(:,i,j) = varT;
            salt(:,i,j) = varS;  
        end
    end
    temp(isnan(temp)) = 14;
    salt(isnan(salt)) = 35;
    
    % U & Ubar
    for i=1:size(Z_U,1)
        for j=1:size(Z_U,2)
            HH   = H_U(i,j);
            ZZ   = Z_U(i,j);
            D    = -zlevs(HH,ZZ,theta_s,theta_b,hc,layer_N,type,vtransform);
            varU = interp1(depth,squeeze(U(:,i,j)),D);
            varU(D<min(dep)) = U(1,i,j);
            u(:,i,j)  = varU;
            ubar(i,j) = trapz(D,squeeze(u(:,i,j)))...
                      / trapz(D,ones(size(D)));
        end
    end
    u(isnan(u))       = 0;
    ubar(isnan(ubar)) = 0;
        
    % V & Vbar
    for i=1:size(Z_V,1)
        for j=1:size(Z_V,2)
            HH   = H_V(i,j);
            ZZ   = Z_V(i,j);
            D    = -zlevs(HH,ZZ,theta_s,theta_b,hc,layer_N,type,vtransform);
            varV = interp1(depth,squeeze(V(:,i,j)),D);
            varV(D<min(dep)) = V(1,i,j);
            v(:,i,j)  = varV;
            vbar(i,j) = trapz(D,squeeze(v(:,i,j)))...
                      / trapz(D,ones(size(D)));
        end
    end
    v(isnan(v))       = 0;
    vbar(isnan(vbar)) = 0;
    
    % Save data
    nc  = netcdf(ininame,'write');
    disp('Writes into Ini file ...')
    nc{'zeta'}(:) = squeeze(zeta);
    nc{'ubar'}(:) = squeeze(ubar);
    nc{'vbar'}(:) = squeeze(vbar);
    nc{'temp'}(:) = squeeze(temp);
    nc{'salt'}(:) = squeeze(salt);
    nc{'u'}(:)    = squeeze(u);
    nc{'v'}(:)    = squeeze(v);
    close(nc)
end

           
           
           
