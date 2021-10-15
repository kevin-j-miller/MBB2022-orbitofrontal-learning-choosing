function ratdata = remove_ephys_fields(ratdata)
% Removes fields that're specific to ephys datasets, to give back a
% behavior-only ratdata

ephys_fields = {'spiketimes', 'cell_types','unitchannels', 'to_exclude',...
    'c1_times', 's1_times', 'c2_times', 's2_times', 'bad_timing'...
    'sessiondate',...
    };

ratdata = rmfield(ratdata, ephys_fields);


end