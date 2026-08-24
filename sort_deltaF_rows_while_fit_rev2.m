function [cell_cell_sort_deltaF_check_idx]=sort_deltaF_rows_while_fit_rev2(app,sort_cell_expanding_weights_idx,cell_nonzero_deltaF)
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Start of Function: sort_deltaF_rows_while_fit_rev1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     First sort the order at which we check the deltas to be based on the weights. (1 is at the top of the list.
    %     1-2
    %     1-3
    %     1-4 …
    %
    %     2-3
    %     2-4
    %     2-5 …
    %
    %     3-4
    %     3-5
    %     3-6 …


    %%%%%%%%%%%Find all the cell_nonzero_deltaF and based on the sort_cell_expanding_weights_idx

    node_list_order=sort_cell_expanding_weights_idx(:,1);
    num_list=length(node_list_order);
    cell_cell_sort_deltaF_check_idx=cell(num_list,1);

    %%%%%%%Only Check "Rx" as design, now finding both
    for rx_idx=1:1:num_list
        temp_rx_id=node_list_order{rx_idx,1};
        temp_deltaF_row1_idx=find(matches(cell_nonzero_deltaF(:,1),temp_rx_id));
        temp_deltaF_row2_idx=find(matches(cell_nonzero_deltaF(:,6),temp_rx_id));
        rx_match_row_idx=unique(vertcat(temp_deltaF_row1_idx,temp_deltaF_row2_idx));

        %%%%%%%%%Need to remove the nested loops.
        if ~isempty(rx_match_row_idx)
            tx_deltaF_rows=cell_nonzero_deltaF(rx_match_row_idx,:);
            temp_uni_tx1=unique(vertcat(tx_deltaF_rows(:,6))); %%%%%%%%Only need to check column 6 now for the tx
            temp_uni_tx2=unique(vertcat(tx_deltaF_rows(:,1)));
            temp_uni_tx=unique(vertcat(temp_uni_tx1,temp_uni_tx2));


            %%%%Need to remove the temp_rx_id from temp_uni_tx
            rx_name_row_idx=find(matches(temp_uni_tx,temp_rx_id));
            temp_uni_tx(rx_name_row_idx)=[];

            %%%%%%%%%%%%%%%%%%%Need to sort the temp_uni_tx via the node_list_order
            sorted_uni_tx_list=cell(num_list,1);
            if rx_idx+1<=num_list
                for j=rx_idx+1:1:num_list
                    idx1=find(matches(temp_uni_tx,node_list_order{j}));
                    if ~isempty(idx1)
                        sorted_uni_tx_list{j}=node_list_order{j};
                    end
                end
            else
                %'Empty list, add logic'
                %rx_idx
                %pause;
            end
            %%%%%%%%Remove empty cells
            sorted_uni_tx_list=sorted_uni_tx_list(~cellfun('isempty',sorted_uni_tx_list));

            if ~isempty(sorted_uni_tx_list)
                num_tx_int=length(sorted_uni_tx_list);
                %%%%%%%%%%%Now find those rows with temp_rx_id and the sorted_uni_tx_list
                %%%%%%Make the temp_cell_int_idx/temp_cell_vic_idx a single array with two rows
                cell_cell_tx_deltaF_idx=cell(num_tx_int,1);
                for tx_idx=1:1:num_tx_int  %%%%%%The "Interfering" TX
                    %%%%%%%%%So now we find the frequencies of the tx and rx and check the deltaF matrix
                    temp_tx_id=sorted_uni_tx_list{tx_idx};

                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%'Need to find the same tx_deltaF_rows --> keep_rows_idx among the entire cell_nonzero_deltaF '
                    temp_tx_row1_idx=find(matches(tx_deltaF_rows(:,6),temp_tx_id));
                    temp_tx_row2_idx=find(matches(tx_deltaF_rows(:,1),temp_tx_id));
                    temp_tx_row_idx=unique(vertcat(temp_tx_row1_idx,temp_tx_row2_idx));

                    check_names_list=unique(vertcat(tx_deltaF_rows(temp_tx_row_idx,1),tx_deltaF_rows(temp_tx_row_idx,6)));
                    tf_name1=any(matches(check_names_list,temp_tx_id));
                    tf_name2=any(matches(check_names_list,temp_rx_id));
                    if tf_name1~=1 || tf_name2~=1
                        'Error on name check'
                        pause;
                    end

                    rx_tx_row_idx=rx_match_row_idx(temp_tx_row_idx);
                    if ~isempty(rx_tx_row_idx)
                        rx_tx_deltaF_rows=cell_nonzero_deltaF(rx_tx_row_idx,:);

                        check_names_list=unique(vertcat(rx_tx_deltaF_rows(:,1),rx_tx_deltaF_rows(:,6)));
                        tf_name1=any(matches(check_names_list,temp_tx_id));
                        tf_name2=any(matches(check_names_list,temp_rx_id));
                        if tf_name1~=1 || tf_name2~=1
                            'Error on name check 2'
                            pause;
                        end

                        %%%%%%%%%%%%%Same Polarization for
                        %%%%%%%%%%%%%last since it is
                        %%%%%%%%%%%%%pop-dna specific and
                        %%%%%%%%%%%%%will change

                        %%%%%%%%%Now check all the Configs: A --> D
                        %%%%%%%Find all the unique configs
                        uni_configs=unique(rx_tx_deltaF_rows(:,11));
                        num_configs=length(uni_configs);

                        %%%%%%%%%%%%%%%%%%%%%%Just keep all 15 the cell_deltaF
                        cell_cell_config_deltaF=cell(num_configs,1);
                        for config_idx=1:1:num_configs
                            temp_config=uni_configs{config_idx};

                            %%%%%%%%%%Now find the temp_config in the pol_match_deltaF
                            config_row_idx=find(contains(rx_tx_deltaF_rows(:,11),temp_config));
                            rx_tx_config_row_idx=rx_tx_row_idx(config_row_idx);
                            %cell_nonzero_deltaF(rx_tx_config_row_idx,:)

                            %%%%%%%%Triple Check
                            tf_name1=any(matches(cell_nonzero_deltaF(rx_tx_config_row_idx,1),temp_tx_id));
                            tf_name2=any(matches(cell_nonzero_deltaF(rx_tx_config_row_idx,6),temp_rx_id));
                            tf_name3=any(matches(cell_nonzero_deltaF(rx_tx_config_row_idx,1),temp_rx_id));
                            tf_name4=any(matches(cell_nonzero_deltaF(rx_tx_config_row_idx,6),temp_tx_id));

                            if all(horzcat(tf_name1,tf_name2)) || all(horzcat(tf_name3,tf_name4))
                                %%%%%%%%%No error
                            else
                                'Error on rx_tx_config_row_idx'
                                rx_tx_config_row_idx
                                pause;
                            end
                            cell_cell_config_deltaF{config_idx,1}=cell_nonzero_deltaF(rx_tx_config_row_idx,:);
                        end  %%%%%%%End of Configure
                    else
                        'Empty rx_tx_row_idx, fill in logic'
                        pause;
                    end
                    cell_cell_tx_deltaF_idx{tx_idx,1}=cell_cell_config_deltaF;
                end
                cell_tx_deltaF_data=vertcat(cell_cell_tx_deltaF_idx{:}); %%%%%%%%Each set of rows is something to check
                cell_cell_sort_deltaF_check_idx{rx_idx,1}=vertcat(cell_tx_deltaF_data{:});
            else
                %'Empty sorted_uni_tx_list, fill in logic'
                %'No data to save'
                %pause;
            end
        else
            'Empty rx_match_row_idx, fill in logic'
            pause;
        end
    end
    %%%%%%%%%%%This is the NEW cut_cell_nonzero_deltaF
    %'Remove the empty cells'
    cell_cell_sort_deltaF_check_idx=cell_cell_sort_deltaF_check_idx(~cellfun('isempty',cell_cell_sort_deltaF_check_idx)); 
    

    sort_cell_nonzero_deltaF=vertcat(cell_cell_sort_deltaF_check_idx{:});
    %%%%'These two should be the same size'
    [num_partition_rows,~]=size(sort_cell_nonzero_deltaF)
    [num_og_rows,~]=size(cell_nonzero_deltaF)
    if num_partition_rows~=num_og_rows
        'Error in the deltaF rows?'
        pause;
    end
    %toc;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%End of Function: sort_deltaF_rows_while_fit_rev1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
