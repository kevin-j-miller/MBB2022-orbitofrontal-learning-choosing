function outliers = identify_outliers_mad(data, thresh)

% Identifies outliers in a data vector, using the median absolute
% dispersion method (Leys ... Licata. JESP 2013)

outliers = abs(data) > (nanmedian(data) + thresh * mad(data));

