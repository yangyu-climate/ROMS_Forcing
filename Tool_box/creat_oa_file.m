function creat_oa_file(frcname,Lp,Mp,N)

L = Lp-1;
M = Mp-1;

nccreate(frcname,'time'       ,'Dimensions',{'time'  ,1                          },'Datatype','double')
nccreate(frcname,'depth'      ,'Dimensions',{'s_rho' ,N                          },'Datatype','double')
nccreate(frcname,'u'          ,'Dimensions',{'xi_u'  ,L  ,'eta_u'  ,Mp,'s_rho' ,N},'Datatype','double')
nccreate(frcname,'v'          ,'Dimensions',{'xi_v'  ,Lp ,'eta_v'  ,M ,'s_rho' ,N},'Datatype','double')
nccreate(frcname,'ssh'        ,'Dimensions',{'xi_rho',Lp ,'eta_rho',Mp           },'Datatype','double')
nccreate(frcname,'temp'       ,'Dimensions',{'xi_rho',Lp ,'eta_rho',Mp,'s_rho' ,N},'Datatype','double')
nccreate(frcname,'salt'       ,'Dimensions',{'xi_rho',Lp ,'eta_rho',Mp,'s_rho' ,N},'Datatype','double')
nccreate(frcname,'var'        ,'Dimensions',{'xi_rho',Lp ,'eta_rho',Mp,'s_rho' ,N},'Datatype','double')
nccreate(frcname,'u_eastward' ,'Dimensions',{'xi_rho',Lp ,'eta_rho',Mp,'s_rho' ,N},'Datatype','double')
nccreate(frcname,'v_northward','Dimensions',{'xi_rho',Lp ,'eta_rho',Mp,'s_rho' ,N},'Datatype','double')

end