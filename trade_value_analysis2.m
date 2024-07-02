
    % Load the data from the Excel file
    Trade = readtable('ProjectPPOC.xlsx', 'Sheet', 'Trading_Values');
    GDP = readtable('ProjectPPOC.xlsx', 'Sheet', 'GDP');
    TFI = readtable('ProjectPPOC.xlsx', 'Sheet', 'TFI');
    ECI = readtable('ProjectPPOC.xlsx', 'Sheet', 'ECI');

    % Define the coordinates of New Delhi
    delhi_coords = [28.6139, 77.2090];

    % Coordinates of G20 capitals
    g20_coords = [
        34.6037, -58.3816;   % Buenos Aires, Argentina
        -35.2809, 149.1300;  % Canberra, Australia
        -15.7942, -47.8822;  % Brasília, Brazil
        45.4215, -75.6972;   % Ottawa, Canada
        39.9042, 116.4074;   % Beijing, China
        48.8566, 2.3522;     % Paris, France
        52.5200, 13.4050;    % Berlin, Germany
        -6.2088, 106.8456;   % Jakarta, Indonesia
        41.9028, 12.4964;    % Rome, Italy
        35.6895, 139.6917;   % Tokyo, Japan
        19.4326, -99.1332;   % Mexico City, Mexico
        55.7558, 37.6173;    % Moscow, Russia
        24.7136, 46.6753;    % Riyadh, Saudi Arabia
        -25.7479, 28.2293;   % Pretoria, South Africa
        37.5665, 126.9780;   % Seoul, South Korea
        39.9334, 32.8597;    % Ankara, Turkey
        51.5074, -0.1278;    % London, United Kingdom
        38.9072, -77.0369;   % Washington D.C., United States
    ];

    % Calculate distances from New Delhi to G20 capitals
    distances = zeros(size(g20_coords, 1), 1);
    for i = 1:size(g20_coords, 1)
        distances(i) = haversine(delhi_coords(1), delhi_coords(2), g20_coords(i, 1), g20_coords(i, 2));
    end

    % Extract data for G20 countries
    g20_countries = {'Argentina', 'Australia', 'Brazil', 'Canada', 'China', 'France', ...
                     'Germany', 'Indonesia', 'Italy', 'Japan', 'Mexico', ...
                     'Russia', 'Saudi Arabia', 'South Africa', 'South Korea', ...
                     'Turkey', 'United Kingdom', 'United States'};

    g20_GDP = GDP(ismember(GDP.Country, g20_countries), :);
    g20_GDP = sortrows(g20_GDP, 'Country');
    g20_ECI = ECI(ismember(ECI.Country, g20_countries), :);
    g20_ECI = sortrows(g20_ECI, 'Country');
    g20_TFI = TFI(ismember(TFI.Country, g20_countries), :);
    g20_TFI = sortrows(g20_TFI, 'Country');
    g20_Trade = Trade(ismember(Trade.Country, g20_countries), :);
    g20_Trade = sortrows(g20_Trade, 'Country');

    % Ensure all tables are aligned by country
    g20_GDP = g20_GDP(:, {'Country', 'GDP'});
    g20_ECI = g20_ECI(:, {'Country', 'ECI'});
    g20_TFI = g20_TFI(:, {'Country', 'TFI'});
    g20_Trade = g20_Trade(:, {'Country', 'Trade_value'});

    GDP_India = 3.41665E+12;
    ECI_India = 0.643776498;
    TFI_India = 52.9;

    % Calculate expected trade value
    LnXij_expected = zeros(length(g20_countries), 1);
    for i = 1:length(g20_countries)
        LnXij_expected(i) = log(GDP_India) + log(g20_GDP.GDP(i)) -2  * log(distances(i)) +...
                            ECI_India + g20_ECI.ECI(i) + TFI_India + g20_TFI.TFI(i);
    end

    % Convert expected trade value from log to actual value
    Xij_Billion = exp(LnXij_expected*0.05);
    Xij_expected = Xij_Billion*10000000;
    % Plot present trade value vs expected trade value
  % Plot present trade value vs expected trade value
    figure;
    bar(categorical(g20_Trade.Country), [g20_Trade.Trade_value, Xij_expected]);
    xlabel('Country');
    ylabel('Trade Value');
    title('Present Trade Value vs Expected Trade Value');
    legend('Present Trade Value', 'Expected Trade Value');
    grid on;




function distance = haversine(lat1, lon1, lat2, lon2)
    R = 6371;  % Earth radius in kilometers
    dlat = deg2rad(lat2 - lat1);
    dlon = deg2rad(lon2 - lon1);
    a = sin(dlat / 2) ^ 2 + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * sin(dlon / 2) ^ 2;
    c = 2 * atan2(sqrt(a), sqrt(1 - a));
    distance = R * c;
end
