num_ccas=1;
bws={'5mbit','10mbit','20mbit','30mbit','40mbit','50mbit','60mbit','70mbit'};
%bws={'10mbit'};
%bws={'40mbit'};
%bws={'70mbit'};
buffs={'10buf','20buf','40buf','80buf','160buf'; %5mbit
       '20buf','40buf','80buf','160buf','320buf'; %10mbit
       '40buf','80buf','160buf','320buf','640buf'; %20mbit
       '60buf','120buf','240buf','480buf','960buf'; %30 mbit
       '80buf','160buf','320buf','640buf','1280buf'; %40mbit
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
schemes={'0.0','0.5'};%i.e. start delay of first small flow
spacings={'0.1gap'}%,'0.1gap','0.2gap'}
num_iter=10;

exp_sizes={'30000000'};%reps 10,20
sma_sizes={'1000000'}

ccas = {'bbr','cubic','reno'}
cca_colors={[0 0 0]; [0.5 0.5 0.5];[1 1 1] }
cca_color_mapobj = containers.Map(ccas,cca_colors);


cca_labels = {'BBR','CUBIC','NewReno'}
buff_labels={'0.5BDP','BDP','2BDP','4BDP','8BDP'};

analyse_bases = {'cca_small','cca_large'};
selected_base= 2; % 1 for cca_small and 2 for cca_large

num_compete_per_iter= zeros(1,num_ccas);

overall_durs_per_iter= zeros(1,num_ccas);
large_durs_per_iter = zeros(1,num_ccas);
small_all_durs_avg_per_iter = zeros(1,num_ccas);
small_comp_durs_avg_per_iter = zeros(1,num_ccas);

num_compete_sum = zeros(1,num_ccas);

sum_overall_durs= zeros(1,num_ccas);
sum_large_durs = zeros(1,num_ccas);
sum_small_all_durs_avg = zeros(1,num_ccas);
sum_small_comp_durs_avg = zeros(1,num_ccas);

no_output=length(bws)*length(buffs)*length(lrs)*length(schemes)*length(exp_sizes)*length(sma_sizes);
key_set1={};
value_set={};
lr=lrs(1);

cd files;
count=1;
for b = 1:length(bws)
    bw=bws(b);
    for bf = 1:buffs_dim(2)
        buff=buffs(b,bf);
        for sm = 1:length(sma_sizes)
            sma_num=sma_sizes(sm);
            sma=strcat(sma_num,'MB');
            for sp_idx = 1:length(spacings)
                sp=spacings(sp_idx);
                for sc = 1:length(schemes)
                    sch=schemes(sc);
                    for e = 1:length(exp_sizes)
                        exp_num=exp_sizes(e); 
                        exp=strcat(exp_num,'MB');
                        for a1 = 1:length(ccas)
                            cca_large=ccas(a1);
                            for a2 = 1:length(ccas)
                                cca_small=ccas(a2); % analyse/plot based on small flow's cca
                                for ite = 0:9
                                    % based on selected base the next few likes
                                    % will match 3 files with different ccas 
                                    % either for large flow or small flow. 
                                    % if selected_base is 1, then this will
                                    % match 3 files, each with different large
                                    % flow ccas for a gived small flow cca .
                                    
                                    file_end= char(strcat(num2str(ite),'.dat'));
                                    filename_regex = char(strcat(cca_large,'*',exp,'*',cca_small,'*',sma,'*',bw,'_',buff,'_',lr,'_',sch,'_',sp,'_',file_end));
                                                                
                                                                                                      
                                    matched_files_list = dir(filename_regex);
                                                                        
                                    for i=1:length(matched_files_list) % loop through each matching file(just 1 in this case)
                                        time_data = csvread(matched_files_list(i).name); 
                                        large_idx= find(time_data(:,1));

                                        duration_arr = time_data(:,3) - time_data(:,2);
                                        start_arr = time_data(:,2);
                                        end_arr = time_data(:,3);

                                        begin_time=min(start_arr);
                                        end_time=max(end_arr);

                                        large_end_time=end_arr(large_idx);
                                        pre_large_end_start_mask=start_arr<large_end_time;
                                        pre_large_end_start_mask(large_idx)=0;
                                        num_compete_per_iter(i)= sum(pre_large_end_start_mask);
                                        n=nnz(pre_large_end_start_mask);
                                        small_comp_durs_arr=pre_large_end_start_mask.*duration_arr;
                                        small_all_durs_arr=[duration_arr(1:large_idx-1,1);duration_arr(large_idx+1:length(duration_arr),1)];

                                        overall_durs_per_iter(i)=end_time-begin_time;
                                        large_durs_per_iter(i)=end_arr(large_idx)-start_arr(large_idx);
                                        small_all_durs_avg_per_iter(i) = mean(small_all_durs_arr);
                                        small_comp_durs_avg_per_iter(i) = sum(small_comp_durs_arr)/n;   
                                    end
                                    
                                    % add new iteration result to previous
                                    % results.
                                    % b-BBR, c-Cubic, r-Newreno
                                    % 1 by 1 values(single/scalar, any one of bb,bc,br,cb,cc,cr,rb,r)
                                    num_compete_sum=num_compete_sum + num_compete_per_iter; 
                                    sum_overall_durs=sum_overall_durs + overall_durs_per_iter;
                                    sum_large_durs = sum_large_durs + large_durs_per_iter;
                                    sum_small_all_durs_avg = sum_small_all_durs_avg + small_all_durs_avg_per_iter;
                                    sum_small_comp_durs_avg = sum_small_comp_durs_avg + small_comp_durs_avg_per_iter;
                                end
                                
                                %take average of all iterations
                                num_compete=num_compete_sum/num_iter;
                                large_durs = sum_large_durs/num_iter ;
                                overall_durs = sum_overall_durs/num_iter; 
                                small_comp_durs_avg = sum_small_comp_durs_avg/num_iter;
                                small_all_durs_avg = sum_small_all_durs_avg/num_iter;
                    
                                num_compete_sum= zeros(1,num_ccas);
                                sum_overall_durs= zeros(1,num_ccas);
                                sum_large_durs = zeros(1,num_ccas);
                                sum_small_all_durs_avg = zeros(1,num_ccas);
                                sum_small_comp_durs_avg = zeros(1,num_ccas);
                                                          
                                name_key=char(strcat(cca_large,'-',cca_small,'-',bw,'-',buff,'-',lr,'-',sch,'-',exp_num,'-',sp))
                                
                                key_set1(end+1) = {name_key};
                                value=[large_durs;overall_durs; small_comp_durs_avg ;small_all_durs_avg;num_compete];
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
comp_time_mapobj_45ms_45ms_diff_cca = containers.Map(key_set1,value_set);
cd ..;

%{
test_change= vertcat(comp_time_mapobj_45ms_45ms_diff_cca('bbr-cubic-40mbit-80buf-0%perc-0.0-30000000MB'),comp_time_mapobj_45ms_45ms_diff_cca('cubic-cubic-40mbit-80buf-0%perc-0.0-30000000MB'),comp_time_mapobj_45ms_45ms_diff_cca('reno-cubic-40mbit-80buf-0%perc-0.0-30000000MB'))
p=bar(test_change)
p(1).FaceColor=[1 1 0];
%p(2).FaceColor=[0 0 0.75];
%p(3).FaceColor=[0 0.8 0];
%Labels={'Large','Total','Small(comp)','Small(all)','Large','Total','Small(comp)','Small(all)','Large','Total','Small(comp)','Small(all)'};
Labels={'L','Tot','SC','S','L','Tot','SC','S','L','Tot','SC','S'};
ylabel('Flow completion time(sec)','FontSize',14);
set(gca,'XTick',1:12,'XTicklabel',Labels,'FontSize',14);
%legend('vs BBR-small','vs CUBIC-small','vs NEW RENO-small');
line([4.5, 4.5], [0, 20], 'Color', 'r');
line([8.5, 8.5], [0, 20], 'Color', 'r');
dim = [0.25 0.57 0.3 0.3]; % x y w h
str = {'bbr-cubic'};
annotation('textbox',dim,'String',str,'FitBoxToText','on','FontSize',14);
dim = [0.50 0.57 0.3 0.3];
str = {'cubic-cubic'};
annotation('textbox',dim,'String',str,'FitBoxToText','on','FontSize',14);
dim = [0.75 0.57 0.3 0.3];
str = {'newreno-cubic'};
annotation('textbox',dim,'String',str,'FitBoxToText','on','FontSize',14);
%}

n_cols=length(buffs);
n_rows=length(ccas)*length(ccas);
L_arr=zeros(n_rows,n_cols);
T_arr=zeros(n_rows,n_cols);
SC_arr=zeros(n_rows,n_cols);
S_arr=zeros(n_rows,n_cols);
n_comp_arr=zeros(n_rows,n_cols);
cca_combs={};
cca_comb_colors=zeros(9,3);% automate this part
key_set2={};
L_value_set={};
T_value_set={};
S_value_set={};
SC_value_set={};
n_comp_value_set={};

count=1;

for sp_idx = 1:length(spacings)
    sp=spacings(sp_idx);
    for sm = 1:length(sma_sizes)
        sma=sma_sizes(sm);
        for sc = 1:length(schemes)
            sch=schemes(sc);
            for e = 1:length(exp_sizes)
                exp=exp_sizes(e);
                for b = 1:length(bws)
                    bw=bws(b);
                    for bf = 1:buffs_dim(2)
                        buff=buffs(b,bf);
                        row=1;
                        for a1 = 1:length(ccas)
                            cca_large=ccas(a1);
                            for a2 = 1:length(ccas)
                                    cca_small=ccas(a2);
                                    dstr= char(strcat(cca_large,'-',cca_small,'-',bw,'-',buff,'-',lr,'-',sch,'-',exp,'-',sp));
                                    %dstr=char(strcat(dstr,'-',sma));
                                    dval=comp_time_mapobj_45ms_45ms_diff_cca(dstr);
                                    
                                    if strcmp(cca_large,'bbr')
                                        large='BBR';
                                    elseif strcmp(cca_large,'cubic')
                                        large='CUBIC';
                                    else
                                        large='NEW RENO';
                                    end
                                    
                                    if strcmp(cca_small,'reno')
                                        small='new reno';
                                    else
                                        small=cca_small;
                                    end
                                    
                                    cca_combs(row,1)={char(strcat(large,'-',small))};
                                    cca_comb_colors(row,:)= (cca_color_mapobj(char(cca_large))+cca_color_mapobj(char(cca_small)))/2;
                                    %cca_comb_colors(row,:)=w/2;
                                    
                                    L_arr(row,bf)=dval(1,:);
                                    T_arr(row,bf)=dval(2,:);
                                    SC_arr(row,bf)=dval(3,:);
                                    S_arr(row,bf)=dval(4,:);
                                    n_comp_arr(row,bf)=dval(5,:);
                                    row=row+1; %row indicates CCA combinations
                            end
                        end
                    end
                    name_key=char(strcat(bw,'-',lr,'-',sch,'-',exp,'-',sma,'-',sp))
                    key_set2(end+1) = {name_key};
                    %L_value=[large_durs;overall_durs; small_comp_durs_avg ;small_all_durs_avg];
                    L_value_set(end+1) = {L_arr};
                    T_value_set(end+1) = {T_arr};
                    S_value_set(end+1) = {S_arr};
                    SC_value_set(end+1) = {SC_arr};
                    n_comp_value_set(end+1)={n_comp_arr};
                    
                end
            end
        end
    end
end
L_mapobj = containers.Map(key_set2,L_value_set)
T_mapobj = containers.Map(key_set2,T_value_set)
S_mapobj = containers.Map(key_set2,S_value_set)
SC_mapobj = containers.Map(key_set2,SC_value_set)
n_comp_mapobj = containers.Map(key_set2,n_comp_value_set)

line_color= {'y','m','r'};%one for each CCA
line_styles = {'-','--','-.'}; %one for each CCA
line_markers = {'o','+','*'};%one for each buff size



%for bf = 1:bf_arr_size(1)
%same CCA bar plots
sp=spacings(1);
sp_names={'dot1gap'};
for bw_idx = 2:length(bws)
    bw=bws(8);
    to_plot=char(strcat(bw,'-',lrs(1),'-',schemes(2),'-',exp_sizes(1),'-',sma_sizes(1),'-',sp))%use bw-lr-sch-large-small
    %sc=SC_mapobj(to_plot);
    lc=L_mapobj(to_plot);
    same_cca_idxs=[1 5 9];%bbr , cubic, newreno idxs
    %same_cca_comp=[sc(same_cca_idxs(1),:) ; sc(same_cca_idxs(2),:) ; sc(same_cca_idxs(3),:)]
    same_cca_comp=[lc(same_cca_idxs(1),:) ; lc(same_cca_idxs(2),:) ; lc(same_cca_idxs(3),:)]
    p=bar(same_cca_comp) % 1 for 80 buf, 2 for 160 buf, 3 for 320 buf
    lgd=legend('BDP/2','BDP','2BDP','4BDP','8BDP','Location','northwest','Orientation','horizontal');    
    %Labels=transpose(cca_combs);
    Labels_three=[cca_combs(same_cca_idxs(1)) cca_combs(same_cca_idxs(2)) cca_combs(same_cca_idxs(3))];
    xlabel('CCA','FontSize',28);
    %ylabel({'Completion times of competing','medium sized flows (sec)'},'FontSize',28,'FontWeight','normal');
    ylabel({'Completion times of',' large flows (sec)'},'FontSize',28);
    set(gca,'XTick',1:3,'XTicklabel',cca_labels,'FontSize',28);
    t=char(strcat(to_plot))
    %t=char(strcat(' large flows-',to_plot))
    title(t,'FontSize',24);
    %---saveas(gcf,char(strcat(bw,'_samecca','_small')),'epsc')
    %saveas(gcf,char(strcat(bw,'_samecca','_large_',sp_names(1))),'epsc')
    fig=gcf;
    fig.PaperUnits='inches';
    fig.PaperPosition = [0 0 20 10];
    print(char(strcat(bw,'_samecca','_large_',sp_names(1))),'-depsc')
    %print(char(strcat(bw,'_samecca','_medium_',sp_names(1))),'-depsc')
end

% plot for percentage of change(increase or decrease) 
sp=spacings(1);
sp_names={'dot1gap'};
buf_x_bw=zeros(5,7);
buf_idx=0;
cca_eval= cca_labels(2);
med_or_lar=0; % 0 for medium, 1 for large
for bw_idx = 2:length(bws)
    bw=bws(bw_idx);
    to_plot=char(strcat(bw,'-',lrs(1),'-',schemes(2),'-',exp_sizes(1),'-',sma_sizes(1),'-',sp))%use bw-lr-sch-large-small
    if med_or_lar == 0
        sc=SC_mapobj(to_plot);
        med_cubic_idxs=[2 5];%vsbbr , vscubic,----for cubic vs bbr
        %med_cubic_idxs=[6 9];%vscubic , vsnewreno, ----- for newreno vs cubic
        
        med_cubic_perc=sc(med_cubic_idxs(1),:)./sc(med_cubic_idxs(2),:);
        %med_cubic_perc=((sc(med_cubic_idxs(1),:)-sc(med_cubic_idxs(2),:))./sc(med_cubic_idxs(2),:))*100;
        buf_x_bw(:,bw_idx-1)=med_cubic_perc(1:5);
    else
        lc=L_mapobj(to_plot);
        lar_cubic_idxs=[4 5];%vsbbr , vscubic,----for cubic vs bbr
        %lar_cubic_idxs=[8 9];%vscubic , vsnewreno, ----- for newreno vs cubic
        
        lar_cubic_perc=lc(lar_cubic_idxs(1),:)./lc(lar_cubic_idxs(2),:); %vsbbr completion/vs cubic completion
        %lar_cubic_perc=((lc(lar_cubic_idxs(1),:)-lc(lar_cubic_idxs(2),:))./lc(lar_cubic_idxs(2),:))*100;
        buf_x_bw(:,bw_idx-1)=lar_cubic_perc(1:5);
    end 

    %plot(lar_cubic_ratio(1:5));
    %hold on
end
ln_markers={'+','*','o','s','d'};
buf_clrs = [[0 0 0];[0 0 1];[1 0.5 0];[0 0.5 1];[1 0 0]];
for i=1:5
    plot(buf_x_bw(i,:),char(strcat('-',ln_markers(i))),'Color',buf_clrs(i,:));
    hold on
end
x_labels={'10','20','30','40','50','60','70'};
set(gca,'XTick',1:7,'XTicklabel',x_labels,'FontSize',28);
lgd=legend(buff_labels,'Location','northwest','Orientation','horizontal','FontSize',28);
xlabel('Bottleneck Bandwidths (Mbps)','FontSize',28);
if med_or_lar == 0
    ylabel({'Quotient of increase in completion',char(strcat('of medium sized ',cca_eval,' flows'))},'FontSize',24);
    t=strcat('Quotient increase for medium ',cca_eval,' flows completion');
else
    ylabel({'Quotient of increase in completion ',char(strcat(' of large ',cca_eval,' flows'))},'FontSize',24);
    t=strcat('Quotient increase for large ',cca_eval,' flows completion');
end

title(t,'FontSize',24);


%{
%Line plot to show the decrease in number of competing flows as BW
%increases
all_bw_n_comp_1_buf=zeros(3,length(bws));
for bw_idx = 1:length(bws)
    bw=bws(bw_idx);
    to_plot=char(strcat(bw,'-',lrs(1),'-',schemes(2),'-',exp_sizes(1),'-',sma_sizes(1)))%use bw-lr-sch-large-small
    buf=3; %1-bdp/2, 2-bdp, 3-
    n=n_comp_mapobj(to_plot);
    same_cca_idxs=[1 5 9];%bbr , cubic, newreno idxs
    same_cca_n_comp=[n(same_cca_idxs(1),:) ; n(same_cca_idxs(2),:) ; n(same_cca_idxs(3),:)]
    %same_cca_comp=[lc(same_cca_idxs(1),:) ; lc(same_cca_idxs(2),:) ; lc(same_cca_idxs(3),:)]
    %p=barh(lc)
    %fig=figure;
    buff_1_n_comps=same_cca_n_comp(:,2);
    all_bw_n_comp_1_buf(:,bw_idx)=buff_1_n_comps;
end
    p=bar(all_bw_n_comp_1_buf) % 1 for 80 buf, 2 for 160 buf, 3 for 320 buf
    lgd=legend('BDP/2','BDP','2BDP','4BDP','8BDP','Location','northwest','Orientation','horizontal');    
    %Labels=transpose(cca_combs);
    Labels_three=[cca_combs(same_cca_idxs(1)) cca_combs(same_cca_idxs(2)) cca_combs(same_cca_idxs(3))];
    ylabel('Number of competing flows','FontSize',14);
    xlabel('Bandwidth(Mbps)','FontSize',14);
    %xlabel('Completion times of large flows (sec)','FontSize',14);
    set(gca,'XTick',1:7,'XTicklabel',bws,'FontSize',14);
    t=char(strcat('Completion times of ',' Competing small flows-',to_plot))
    %t=char(strcat('Completion times of ',' large flows-',to_plot))
    title(t,'FontSize',12);
    %saveas(gcf,char(strcat(bw,'_samecca','_small')),'epsc')
    %print(char(strcat(bw,'_samecca','_small')),'-depsc')
    

%}

sp=spacings(1);
%scatter plot for selected bottleneck bandwidth
%for bw_idx=1:length(bws)
    bw_idx=8;
    bw=bws(bw_idx);
    markers = {'o','+','x','s','d','p','v','>','<'};% nine markers one for each CCA combination
    sz=110;
    buf_markers={'o','s','d','p','h'};
    %buf_colors = {'k','b','o','c','r'}% o for orange
    buf_colors = [[0 0 0];[0 0 1];[1 0.5 0];[0 0.5 1];[1 0 0]];
    buf_mark_sz=[100 200 400 800 1600];
    %buf_mark_sz=[0 20 80 140 200];
    group=[];
    %bws - 1=5mbit, 2=10mbit, 3=20mbit
    to_plot=char(strcat(bw,'-',lrs(1),'-',schemes(2),'-',exp_sizes(1),'-',sma_sizes(1),'-',sp))%use bw-lr-sch-large-small
    sc=SC_mapobj(to_plot);
    lc=L_mapobj(to_plot);
    figure
    for b = 1: buffs_dim(2)
        for cc = 1:length(cca_combs)
            %cl=linspace(0,1,length(cca_combs))
            s=scatter(sc(cc,b),lc(cc,b),buf_mark_sz(b),char(markers(cc)))%,cl,'filled');
            %s=scatter(sc(cc,b),lc(cc,b),1600,char(markers(cc)))%
            s.MarkerEdgeColor=buf_colors(b,:);
            %s.Marker=char(buf_markers(b));
            hold on;
        end
        %lgd=legend(cca_combs);
    end
    xlabel('Competing small flow completion time(sec)','FontSize',24);
    ylabel('Large flow completion time(sec)','FontSize',24);
    xlim([0 6]);%max 25 for 5mbit,  go low until 25,10,5
    ylim([0 20]);%max 100 for 5mbit, go low until 100,50,30
    set(gca,'FontSize',24);

    lgd=legend(cca_combs);
    lgd.FontSize=22;
    title(to_plot,'FontSize',24);
    saveas(gcf,char(strcat(bw,'_large_vs_small_',sp)),'epsc')
%end
%}


sum_comp_time=zeros(21,3);
sum_comp_time_small=zeros(20,3);
%comp_time_small=zeros(20,3);
cca_large=ccas(1);
cca_small=ccas(2);
bw_idx=2;
buf_idx=2;
bw=bws(2);
buf=buffs(bw_idx,buf_idx);
for i=1:9
      file_end= char(strcat(num2str(i),'.dat'));
      to_plot=strcat(cca_large,'_30000000MB_45ms_',cca_small,'_1000000MB_45ms_',bw,'_',buf,'_0%perc_0.5_0.1gap_');
      comp_time=csvread(char(strcat('files/',to_plot,file_end))); 
      sum_comp_time=sum_comp_time+comp_time;
      large_idx= find(comp_time(:,1));
      comp_time_small=[comp_time(1:large_idx-1,:); comp_time(large_idx+1:length(comp_time),:)];%extend this upto 20
      sum_comp_time_small=sum_comp_time_small+comp_time_small;
      plot(comp_time_small(:,3)-comp_time_small(:,2));
      hold on;
end
avg_comp_time_small= sum_comp_time_small./10;   
size(comp_time_small)
figure
plot(avg_comp_time_small(:,3)-avg_comp_time_small(:,2))
ylabel('Completion time(sec)','FontSize',36,'FontWeight','bold');
xlabel('Small flow Index','FontSize',36,'FontWeight','bold');
set(gca,'FontSize',30);
title(char(to_plot),'FontSize',18); % issues warning about string interpreter


