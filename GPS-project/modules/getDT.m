function [dt] = getDT(vec_site,vec_rho,gw,gs)

mjd = gwgs2mjd(gw,gs);

site_gd = xyz2gd(vec_site);
dlat = deg2rad(site_gd(1));
dlon = deg2rad(site_gd(2));
dhgt = site_gd(3);

[p,~,~] = gpt(mjd,dlat,dlon,dhgt);

ZHD = (0.0022768*p)/ (1-0.00266*cos(2*dlat)-2.8*10^-6*dhgt);

rho_topo = xyz2topo(vec_rho,site_gd(1),site_gd(2));
zd = acos(rho_topo(3)/norm(rho_topo));

[gmfh,~] = gmf(mjd,dlat,dlon,dhgt,zd);

dt = ZHD*gmfh;

end

