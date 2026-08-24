function [sort_cell_expanding_weights_idx]=weight_idx_cut_deltaF_rev3(app,cell_nonzero_deltaF)




%%%%%%%%%%%%%%%%%%Simple version
uni_link_list_deltaF=unique(vertcat(cell_nonzero_deltaF(:,1),cell_nonzero_deltaF(:,6)));
num_link=length(uni_link_list_deltaF);
cell_expanding_weights_idx=cell(num_link,4);
%%%%%%1) Name of Link,
%%%%%2) Weight (Number of nearby links),
%%%%%3) Name of Connected Links + Center Link Name
%%%%%%4) idx of subgroup in cell_nonzero_deltaF (used for expanding node)
%tic;
for i=1:1:num_link
    %i/num_link*100
% % %     design_idx=find(contains(cell_nonzero_deltaF(:,1),uni_link_list_deltaF{i}));
% % %     envir_idx=find(contains(cell_nonzero_deltaF(:,6),uni_link_list_deltaF{i}));

    design_idx=find(matches(cell_nonzero_deltaF(:,1),uni_link_list_deltaF{i}));
    envir_idx=find(matches(cell_nonzero_deltaF(:,6),uni_link_list_deltaF{i}));

    %%%%%%%%%%%%%Idx in cell_nonzero_deltaF of the center/primary node.
    center_node_idx=unique(vertcat(design_idx,envir_idx));

    %%%%%%%%Find the unique connected links (switch 1 <-> 6) with the name of the center node
    uni_connected_links=unique(vertcat(uni_link_list_deltaF{i},cell_nonzero_deltaF(design_idx,6),cell_nonzero_deltaF(envir_idx,1)));

    %%%%%%%And all the secondary
    cell_expanding_weights_idx{i,1}=uni_link_list_deltaF{i};
    cell_expanding_weights_idx{i,2}=length(uni_connected_links);
    cell_expanding_weights_idx{i,3}=uni_connected_links;
    cell_expanding_weights_idx{i,4}=center_node_idx;
end
array_weights=cell2mat(cell_expanding_weights_idx(:,2));
[~,weight_sort_idx]=sort(array_weights,'descend');
sort_cell_expanding_weights_idx=cell_expanding_weights_idx(weight_sort_idx,:);
%toc;