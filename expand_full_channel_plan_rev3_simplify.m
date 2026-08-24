function [mod_full_channel_plan]=expand_full_channel_plan_rev3_simplify(app,full_channel_plan,freq_hole_set)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Expand the full_channel_plan to include both permuations of frequency pairs

cell_H=cell(1,1);
cell_H{1}='H';
cell_V=cell(1,1);
cell_V{1}='V';

[num_chan_rows,~]=size(full_channel_plan);
for i=1:1:num_chan_rows
    cell_temp_freq=full_channel_plan{i,3};

    %size(keep_cell_temp_freq)
    cell_temp_freq(:,6)=cell_H;
    cell_temp_freq(:,7)=cell_H;
    horizontal_freq=vertcat(cell_temp_freq);

    vertical_freq=horizontal_freq;
    vertical_freq(:,6)=cell_V;
    vertical_freq(:,7)=cell_V;
    full_channel_plan{i,7}=vertcat(vertical_freq);


    %%%%%%%%%Now Cut the Frequencies based on the freq_hole_set and put in full_channel_plan(:,8)
    %%%%%%%%%%%%Pull from full_channel_plan(:,7) for frequencies
    temp_cell_frequency=full_channel_plan{i,7};
    temp_freq_array=cell2mat(temp_cell_frequency(:,[4]));

    %%%%%%%%%Now Filter freq_hole_set
    %%%%%%%%Need to include bandwidth of transmitter, as these are center frequencies
    temp_half_bw=full_channel_plan{i,6}/2;
    keep_freq1_idx=find((temp_freq_array(:,1)-temp_half_bw)>=(max(freq_hole_set)));
    keep_freq2_idx=find((temp_freq_array(:,1)+temp_half_bw)<=(min(freq_hole_set)));
    keep_row_idx=union(keep_freq1_idx,keep_freq2_idx);
    %temp_cell_frequency(keep_row1_idx,:)

    if isempty(keep_row_idx)
        full_channel_plan(i,:)
        'Error: No Channels Available'
        pause;
    end
    array_freq=temp_freq_array(keep_row_idx,:);

    % % %
    % % %     temp_cell_frequency(keep_row_idx,:)
    % % %     'Add both polarization with two extra columns, dont worry about x_pol at this time'
    % % %     pause;

    full_channel_plan{i,8}=temp_cell_frequency(keep_row_idx,:);
end
mod_full_channel_plan=full_channel_plan;
%%%%%Checked this filtering with different values
