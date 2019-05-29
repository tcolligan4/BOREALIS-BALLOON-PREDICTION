% CONSTANTS %
g = 9.81; %m/s^2
Earth_Radius = 6371.0; %km
Degrees_to_Radians = pi/180.0;
Radians_to_Degrees = 180.0/pi;
Alt_Increment = 150.0; %m
Parachute_Drag = 0.5;
Sphere_Drag = 0.48;
Dry_Air_Gas_Constant = 287.058; %J/kgK
Mass_Per_Mole_Helium = 4.0026; %g/mol
Mass_Per_Mole_Air = 28.96644; %g/mol

% WRF time index %
time = 0;

% Get destination %

% http://www.movable-type.co.uk/scripts/latlong.html
% ***** distance must be entered as km since Earth_Radius is in km *****
function [end_lat, end_lon] = destination(distance, bearing, lat, lon)
lat = lat *Degrees_to_Radians;
lon = lon *Degrees_to_Radians;
bearing = bearing *Degrees_to_Radians;

end_lat = asin(sin(lat) * cos(distance/Earth_Radius) + ...
    cos(lat) * sin(distance/Earth_Radius) * cos(bearing));
end_lon = lon + atan2(sin(bearing) * sin(distance/Earth_Radius) ...
    * cos(lat), cos(distance/Earth_Radius) - sin(lat) * sin(end_lat));
end_lon = mod((end_lon + pi), (2*pi) - pi); % normalize to -180...+180

end_lat = end_lat*Radians_to_Degrees;
end_lon = end_lon*Radians_to_Degrees;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   CALCULATED ASCENT & DESCENT RATES   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Descent rate %

function [descent_rate] = getDescentRate(pressure, temperature, ...
    radius, mass_balloon, mass_payload)
% Area
A = pi *radius^2;
% Density
density = pressure/(temperature*Dry_Air_Gas_Constant);
% Descent rate
descent_rate = -sqrt(2.0 * g *(mass_payload + 0.7 * mass_balloon)/...
    (A * Parachute_Drag * density));
end

% Ascent rate %

function [ascent_rate] = getAscentRate(surface_pressure, ...
    surface_temperature, pressure, temperature, ...
    radius_balloon, mass_balloon, mass_payload)
% volume of balloon (surface)
V_surface = 4.0/3.0 * pi * radius_balloon^3;
% density
density = pressure/(temperature * Dry_Air_Gas_Constant);
% surface density
density_surface = surface_pressure/...
    (surface_temperature * Dry_Air_Gas_Constant);
% mass of heliums
mass_helium = Mass_Per_Mole_Helium * V_surface * density_surface /...
    Mass_Per_Mole_Air;
% volume (changing with altitude)
V = V_surface * density_surface / density;
% ascent rate calculation
force_bouyant = (V * density * g) - ...
    ((mass_payload + mass_balloon + mass_helium) * g);
cross_area = pi * (3.0 * V/(4.0 * pi))^(2.0/3.0);
ascent_rate = sqrt((2.0 * force_bouyant)/...
    (Sphere_Drag * cross_area * density));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    SPECIFIC ASCENT & DESCENT RATES    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [rise_rate] = getRiseRate(alt, ascent)
ascent_rates = [2000,5.34; ...
    3000,5.43; ...
    4000,5.22; ...
    5000,5.14; ...
    6000,4.79; ...
    7000,4.93; ...
    8000,5.28; ...
    9000,4.97; ...
    10000,4.98; ...
    11000,5.22; ...
    12000,4.91; ...
    13000,4.99; ...
    14000,5.0; ...
    15000,4.88; ...
    16000,5.07; ...
    17000,4.93; ...
    18000,5.63; ...
    19000,4.99; ...
    20000,5.15; ...
    21000,4.65; ...
    22000,5.36; ...
    23000,5.49; ...
    24000,5.57; ...
    25000,5.42; ...
    26000,5.83; ...
    27000,5.55; ...
    28000,5.0; ...
    29000,5.0; ...
    30000,5.0]
descent_rates = [30000,-39.5; ...
    28000,-38.0; ...
    26000,-37.7; ...
    24000,-30.8; ...
    22000,-27.4; ...
    20000,-26.55; ...
    18000,-24.2; ...
    16000,-19.7; ...
    14000,-17.4; ...
    12000,-7.4; ...
    10000,-6.5; ...
    8000,-5.9; ...
    6000,-4.9; ...
    4000,-4.8]
    if ascent
        rise_rates = ascent_rates;
    else
        rise_rates = descent_rates;
    end    
    rise_rate = 0;
    getRiseRate_error = 0;
    getRiseRate_previous_error = 9999;
    for i=1:size(rise_rates)
        getRiseRate_error = abs(alt - rise_rates(i,1));
        if getRiseRate_error < getRiseRate_previous_error
            rise_rate = rise_rates(i,2);
            getRiseRate_previous_error = getRiseRate_error;
        end
    end
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTTING %
function [plot_points] = Plotting(points, sizex, sizey)
points = points;
x = points(:,1);
y = points(:,0);
z = points(:,2);
end

