function [full_channel_plan]=expand_full_channel_plan_rev2_just_vert(app,full_channel_plan,tf_custom_channel_plan,freq_hole_set,tf_just_vert_channels,tf_invert_channels)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Expand the full_channel_plan to include both permuations of frequency pairs
% % 'If we are cutting any frequencies, we can create a modified channel plan easily. or cut all the way to 7750 MHz with the current plan. (625MHz)'
% % 'Insert the custom channel plan into full_channel_plan{i,7} and the filtered into (:,8)'
if tf_custom_channel_plan==1
    'Need to create a custom channel plan logic'
    pause;
end

%tf_just_vert_channels  %%%%%%%1/0, If 1 --> Just the Vertical Channels, if 0 --> H and V Channels

cell_H=cell(1,1);
cell_H{1}='H';
cell_V=cell(1,1);
cell_V{1}='V';

[num_chan_rows,~]=size(full_channel_plan);
for i=1:1:num_chan_rows
    cell_temp_freq=full_channel_plan{i,3};

    %%%%%%Check for NaNs and remove those channels, as we won't be using "single" channels in this first go around
    second_freq=cell2mat(cell_temp_freq(:,5));
    nnan_idx=find(~isnan(second_freq));
    keep_cell_temp_freq=cell_temp_freq(nnan_idx,:);

    %size(keep_cell_temp_freq)
    keep_cell_temp_freq(:,6)=cell_H;
    keep_cell_temp_freq(:,7)=cell_H;

    %%%%%%%%%%Now duplicate and flip and add Polarization
    freq_freq_flip=fliplr(keep_cell_temp_freq(:,[4,5]));
    double_keep_cell_temp_freq=keep_cell_temp_freq;
    double_keep_cell_temp_freq(:,[4,5])=freq_freq_flip;

    if tf_invert_channels==1
        horizontal_freq=vertcat(keep_cell_temp_freq,double_keep_cell_temp_freq);
        %%%%%%%Invert
    else
        horizontal_freq=vertcat(keep_cell_temp_freq);
    end

    vertical_freq=horizontal_freq;
    vertical_freq(:,6)=cell_V;
    vertical_freq(:,7)=cell_V;

    if tf_just_vert_channels==1
        full_channel_plan{i,7}=vertcat(vertical_freq);
    else
        full_channel_plan{i,7}=vertcat(horizontal_freq,vertical_freq);
    end

    %%%%%%%%%Now Cut the Frequencies based on the freq_hole_set and put in full_channel_plan(:,8)
    %%%%%%%%%%%%Pull from full_channel_plan(:,7) for frequencies
    temp_cell_frequency=full_channel_plan{i,7};
    temp_freq_array=cell2mat(temp_cell_frequency(:,[4,5]));

    %%%%%%%%%Now Filter freq_hole_set
    %%%%%%%%Need to include bandwidth of transmitter, as these are center frequencies
    temp_half_bw=full_channel_plan{i,6}/2;
    keep_freq1_idx=find((temp_freq_array(:,1)-temp_half_bw)>=(max(freq_hole_set)));
    keep_freq2_idx=find((temp_freq_array(:,1)+temp_half_bw)<=(min(freq_hole_set)));
    keep_row1_idx=union(keep_freq1_idx,keep_freq2_idx);
    %temp_cell_frequency(keep_row1_idx,:)

    keep_freq3_idx=find((temp_freq_array(:,2)-temp_half_bw)>=(max(freq_hole_set)));
    keep_freq4_idx=find((temp_freq_array(:,2)+temp_half_bw)<=(min(freq_hole_set)));
    keep_row2_idx=union(keep_freq3_idx,keep_freq4_idx);
    %temp_cell_frequency(keep_row2_idx,:)

    keep_row_idx=intersect(keep_row1_idx,keep_row2_idx);
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
%%%%%Checked this filtering with different values


%%%'Save the dna for each increasing Frequency to pull from.'
% % % %%%%%%%%%%%%%Full
% % % 'E->192'
% % % 'D->96'
% % % 'C->264'
% % % %%%%'We are checking to see if the full_channel_plan are empty inside'

end