clear dir
num_ccas=1;
num_compete_ccas=2;
bws={'5mbit','10mbit','20mbit','30mbit','40mbit','50mbit','60mbit','70mbit'};
%bws={'10mbit'};
%bws={'40mbit'};
%bws={'70mbit'};
buffs={'10buf','20buf','40buf','80buf','160buf'; %5mbit
       '20buf','40buf','80buf','160buf','320buf'; %10mbit
       '40buf','80buf','160buf','320buf','640buf'; %20mbit
       '60buf','120buf','240buf','480buf','960buf'; %30 mbit
       '80buf','160buf','320buf','640buf','1280buf'; %40 mbit
       '100buf','200buf','400buf','800buf','1600buf'; %50mbit 
       '120buf','240buf','480buf','960buf','1920buf'; %60mbit
       '140buf','280buf','560buf','1120buf','2240buf'}; %70mbit
   
buffs_dim=size(buffs);

%buffs={'10buf','20buf','40buf','80buf','160buf'};%5mbit
%buffs={'20buf','40buf','80buf','160buf','320buf'};%10mbit
%buffs={'80buf','160buf','320buf','640buf','1280buf'};%40mbit
%buffs={'140buf','280buf','560buf','1120buf','2240buf'};%70 mbit

buff_markers={'o','s','d','p','h'};
lrs={'0%perc'};
schemes={'0.0'};%,'0.4','0.8'};%i.e. start delay of first small flow
num_iter=10;
spacings={'0.0gap','0.1gap'}%,'0.2gap','0.3gap','0.4gap','0.5gap'}

exp_sizes={'1000000MB'};%reps 10,20
sma_sizes={'1000000MB'}

ccas = {'bbr','cubic','reno'}
cca_colors={[0 0 0]; [0.5 0.5 0.5];[1 1 1] }
cca_color_mapobj = containers.Map(ccas,cca_colors);


cca_labels = {'BBR','Cubic','NewReno'}

analyse_bases = {'cca_small','cca_large'};
selected_base= 2; % 1 for cca_small and 2 for cca_large

num_compete_per_iter= zeros(1,num_ccas);

%durs_per_iter_cca_1= zeros(1,num_ccas);
avg_durs_per_iter_cca_1= zeros(1,num_ccas);
avg_durs_per_iter_cca_2= zeros(1,num_ccas);

sum_avg_durs_cca_1= zeros(1,num_ccas);
sum_avg_durs_cca_2= zeros(1,num_ccas);

key_set1={};
value_set={};

file_end=cell(1,num_compete_ccas);

cd files;
count=1;
for b = 1:length(bws)
    bw=bws(b);
    for bf = 2:4%buffs_dim(2)
        buff=buffs(b,bf);
        for sm = 1:length(sma_sizes)
            sma=sma_sizes(sm);
            for l = 1:length(lrs)
                lr=lrs(l);
                for sc = 1:length(schemes)
                    sch=schemes(sc);
                    for e = 1:length(exp_sizes)
                        exp=exp_sizes(e);
                        for spc_idx = 1:2%length(spacings)
                            gap = spacings(spc_idx);
                            for a1 = 1:length(ccas)
                                cca_one=ccas(a1);
                                for a2 = a1:length(ccas)
                                    cca_two=ccas(a2); % analyse/plot based on small flow's cca
                                    for ite = 0:9
                                            %cd files;
                                            file_end_cca_1= char(strcat(num2str(ite),'_',cca_one,'.dat'));
                                            file_end_cca_2= char(strcat(num2str(ite),'_',cca_two,'.dat'));

                                            filename_regex_cca_1 = char(strcat(cca_one,'*',exp,'*',cca_two,'*',sma,'*',bw,'_',buff,'_',lr,'_',sch,'_',gap,'*',file_end_cca_1));
                                            filename_regex_cca_2 = char(strcat(cca_one,'*',exp,'*',cca_two,'*',sma,'*',bw,'_',buff,'_',lr,'_',sch,'_',gap,'*',file_end_cca_2));

                                            matched_files_list_cca_1 = dir(filename_regex_cca_1);
                                            matched_files_list_cca_2 = dir(filename_regex_cca_2);

                                            for i=1:length(matched_files_list_cca_1) % loop through each matching file(just 1 in this case)
                                                time_data_cca_1 = csvread(matched_files_list_cca_1(i).name); 
                                                time_data_cca_2 = csvread(matched_files_list_cca_2(i).name); 
                                                %large_idx= find(time_data_one(:,1));
                                                %cd ..;
                                                
                                                duration_arr_cca_1 = time_data_cca_1(:,3) - time_data_cca_1(:,2);
                                                start_arr_cca_1 = time_data_cca_1(:,2);
                                                end_arr_cca_1 = time_data_cca_1(:,3);
                                                duration_arr_cca_2 = time_data_cca_2(:,3) - time_data_cca_2(:,2);
                                                start_arr_cca_2 = time_data_cca_2(:,2);
                                                end_arr_cca_2 = time_data_cca_2(:,3);
                                                
                                                %if cca1 small flows complete faster
                                                if end_arr_cca_1(length(end_arr_cca_1))< end_arr_cca_2(length(end_arr_cca_2))
                                                    cca2_competing_mask=start_arr_cca_2<end_arr_cca_1(length(end_arr_cca_1));
                                                    num_cca2_competing= sum(cca2_competing_mask);
                                                    avg_durs_per_iter_cca_1(i)=mean(duration_arr_cca_1);
                                                    avg_durs_per_iter_cca_2(i)=mean(duration_arr_cca_2(1:num_cca2_competing));
                                                    
                                                end
                                                %if cca2 small flows completes faster
                                                if end_arr_cca_2(length(end_arr_cca_2))< end_arr_cca_1(length(end_arr_cca_1))
                                                    cca1_competing_mask=start_arr_cca_1<end_arr_cca_2(length(end_arr_cca_2));
                                                    num_cca1_competing= sum(cca1_competing_mask);
                                                    avg_durs_per_iter_cca_1(i)=mean(duration_arr_cca_1(1:num_cca1_competing));
                                                    avg_durs_per_iter_cca_2(i)=mean(duration_arr_cca_2);
                                                end

                                                begin_time_cca_1=min(start_arr_cca_1);
                                                end_time_cca_1=max(end_arr_cca_1);
                                                begin_time_cca_2=min(start_arr_cca_2);
                                                end_time_cca_2=max(end_arr_cca_1);


                                                %durs_per_iter_cca_1(i)=duration_arr_cca_1;
                                                %durs_per_iter_cca_2(i)=duration_arr_cca_2;
                                                avg_durs_per_iter_cca_1(i)=mean(duration_arr_cca_1);
                                                avg_durs_per_iter_cca_2(i)=mean(duration_arr_cca_2);
                                                   
                                            end

                                            % add new iteration result to previous
                                            % results.
                                            % b-BBR, c-Cubic, r-Newreno
                                            % 1 by 1 values(single/scalar, any one of bb,bc,br,cb,cc,cr,rb,r)
                                            sum_avg_durs_cca_1=sum_avg_durs_cca_1 + avg_durs_per_iter_cca_1;
                                            sum_avg_durs_cca_2=sum_avg_durs_cca_2 + avg_durs_per_iter_cca_2;
                    
                                        %end
                                    end
                                
                                    %take average of all iterations

                                    comp_time_cca_1 = sum_avg_durs_cca_1/num_iter; 
                                    comp_time_cca_2 = sum_avg_durs_cca_2/num_iter;


                                    sum_avg_durs_cca_1= zeros(1,num_ccas);
                                    sum_avg_durs_cca_2= zeros(1,num_ccas);


                                    name_key=char(strcat(cca_one,'-',cca_two,'-',bw,'-',buff,'-',lr,'-',sch,'-',exp,'-',gap))

                                    key_set1(end+1) = {name_key};
                                    %value=[large_durs;overall_durs; small_comp_durs_avg ;small_all_durs_avg];
                                    value=[comp_time_cca_1;comp_time_cca_2];
                                    value_set(end+1) = {value};
                                    count=count+1;
                                end 
                            end
                        end
                    end
                end
            end
        end
    end
end
comp_time_mapobj_45ms_45ms_small_vs_small = containers.Map(key_set1,value_set);
cd ..;


line_color= {'y','m','r'};%one for each CCA
line_styles = {'-','--','-.'}; %one for each CCA
line_markers = {'o','+','*'};%one for each buff size



%markers = {'o','+','x','s','d','p','v','>','<'};% nine markers one for each CCA combination
sz=110;
bw_markers={'o','s','d','p','h','v','^','<'};
%buf_colors = {'k','b','o','c','r'}% o for orange
%buf_colors = [[0 0 0];[0 0 1];[1 0.5 0];[0 0.5 1];[1 0 0]];
buf_colors = [[0 0 0];[0 0 1];[0 1 0];[1 0 0]];
buf_mark_sz=[0 20 100 180];
buff_labels={'BDP/2','BDP','2BDP','4BDP','8BDP'};
group=[];
lgd_str={};


%scatter plot of two CCAs for all bw and all buff sizes(BDP,2BDP,4BDP)
figure
lgd_str={};
cca1_buf_arr=zeros(1,3);
cca2_buf_arr=zeros(1,3)
gap=spacings(2);
for bw_idx = 1:1%length(bws)
    bw=bws(bw_idx);
    lgd_str(end+1)=bw;
    count=1;
    for buf_idx = 2:4%buffs_dim(2)
        buff=buffs(bw_idx,buf_idx);
        %lgd_str(end+1)=bw;%strcat(bw,'-',buff_labels(buf_idx));
        %for cca1_idx =1:1%length(ccas)
            cca1_idx=1;
            cca_one=ccas(cca1_idx);
            %for cca2_idx = 3:3%length(ccas)
                cca2_idx=2;
                cca_two=ccas(cca2_idx)
                dstr= char(strcat(cca_one,'-',cca_two,'-',bw,'-',buff,'-',lr,'-',sch,'-',exp,'-',gap));
                dval=comp_time_mapobj_45ms_45ms_small_vs_small(dstr);
                %{
                cca1=dval(1,:);
                cca2=dval(2,:);
                s=scatter(cca1,cca2,buf_mark_sz(buf_idx),char(bw_markers(bw_idx)))
                s.MarkerEdgeColor=buf_colors(buf_idx,:);
                hold on;
                %}
                cca1_buf_arr(count)=dval(1,:);
                cca2_buf_arr(count)=dval(2,:);
                
            %end
        %end
        count=count+1;
    end
    s=scatter(cca1_buf_arr,cca2_buf_arr,buf_mark_sz(2:4),char(bw_markers(bw_idx)))
    hold on
end
xlabel(cca_one,'FontSize',14);
ylabel(cca_two,'FontSize',14);
%xlim([0 20]);%max 25 for 5mbit
%ylim([0 20]);%max 100 for 5mbit
lgd=legend(lgd_str);
lgd.FontSize=12;
title(strcat(cca_one,'-',cca_two,'-',gap),'FontSize',12);



%bar plot for completion time of a Single CCA(cubic) for all CCA combinations for all bw and all buff sizes(BDP,2BDP,4BDP)
figure
lgd_str={};
eval_3cca_3buf=zeros(3,3)
cca_eval=ccas(2);
gap=spacings(1);
for bw_idx = 3:3%length(bws)
    bw=bws(bw_idx);
    for buf_idx = 2:4%buffs_dim(2)
        buff=buffs(bw_idx,buf_idx);
        for cca1_idx =1:length(ccas)
                cca_one=ccas(cca1_idx);
                               
                if strcmp(cca_eval,'bbr')
                    cca_two=cca_one;
                    cca_one=cca_eval;
                elseif strcmp(cca_one,'reno')
                    cca_two=char('reno');
                    cca_one=cca_eval;
                else
                    cca_two=cca_eval;
                end
                dstr= char(strcat(cca_one,'-',cca_two,'-',bw,'-',buff,'-',lr,'-',sch,'-',exp,'-',gap));
                %dval=comp_time_mapobj_45ms_45ms_small_vs_small(dstr);
                dval=comp_time_mapobj_45ms_45ms_small_vs_small(dstr);

                
                if strcmp(cca_one,cca_eval)
                    eval_3cca_3buf(buf_idx-1, cca1_idx)=dval(1,:);
                else
                   eval_3cca_3buf(buf_idx-1,cca1_idx)=dval(2,:); 
                end
        end
     end
end
bar(eval_3cca_3buf); % x-axis buffur size, labeles are competing ccas
%bar(transpose(eval_3cca_3buf)); % x-axis competing cca, labels are buffers
xlabel('Buffer sizes','FontSize',14);
ylabel(strcat('Completion time of small ',cca_eval,'flow'),'FontSize',14);
set(gca,'XTick',1:9,'XTicklabel',buff_labels(2:4),'FontSize',14);
%xlim([0 20]);%max 25 for 5mbit
%ylim([0 20]);%max 100 for 5mbit
lgd_str=ccas;
lgd=legend(lgd_str);
lgd.FontSize=12;
title(strcat(cca_eval,'-',bw,'-',gap),'FontSize',12);





%{
%completion time of a Single CCA(cubic vs bbr or reno) in line plot with
%one line plot for each buffer and with the x-axis of bandwidth
figure
lgd_str={};
cca_eval=ccas(2);
gap='0.1gap';
eval_allbw_1buf=zeros(1,length(bws));
cca_lines={'--','-',':'};
for cca_idx =1:length(ccas)
    cca_sec=ccas(cca_idx)
    for buf_idx = 2:4%buffs_dim(2)
        for bw_idx = 1:length(bws)
            bw=bws(bw_idx);
            buff=buffs(bw_idx,buf_idx);
            if strcmp(cca_eval,'bbr')
                cca_two=cca_sec;
                cca_one=cca_eval;
            elseif strcmp(cca_sec,'bbr')
                cca_one=cca_sec;
                cca_two=cca_eval;
            elseif strcmp(cca_one,'reno')
                cca_two=char('reno');
                cca_one=cca_eval;
            else
                cca_one=cca_eval;
                cca_two=cca_sec;
            end
                dstr= char(strcat(cca_one,'-',cca_two,'-',bw,'-',buff,'-',lr,'-',sch,'-',exp,'-',gap));
                dval=comp_time_mapobj_45ms_45ms_small_vs_small(dstr);

            if strcmp(cca_one,cca_eval)
                eval_allbw_1buf(1,bw_idx)=dval(1,:);
            else
                eval_allbw_1buf(1,bw_idx)=dval(2,:); 
            end              
        end
        p=plot(eval_allbw_1buf,char(cca_lines(cca_idx)));
        %p.Marker=cca_lines(cca_idx);
        lgd_str(end+1)=strcat(buff_labels(buf_idx),'-vs ',cca_sec);

        hold on
    end
end
xlabel('Bottleneck bandwidths','FontSize',14);
ylabel(strcat('Completion time of small ',cca_eval,'flow'),'FontSize',14);
set(gca,'XTick',1:9,'XTicklabel',bws,'FontSize',14);
%xlim([0 20]);%max 25 for 5mbit
%ylim([0 20]);%max 100 for 5mbit
%lgd_str=buff_labels(2:4);
lgd=legend(lgd_str);
lgd.FontSize=12;
%title(strcat(cca_eval,'-vs-',cca_sec),'FontSize',12);

%}
