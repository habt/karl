ccas = {'bbr','cubic','reno'}
bws={'5mbit','10mbit','20mbit','30mbit','40mbit','50mbit','60mbit','70mbit'}
%buffer-BDP/2 , BDP ,  2BDP   ,  4BDP  , 8BDP
buffs={'10buf','20buf','40buf','80buf','160buf'; %5mbit
       '20buf','40buf','80buf','160buf','320buf'; %10mbit
       '40buf','80buf','160buf','320buf','640buf'; %20mbit
       '60buf','120buf','240buf','480buf','960buf'; %30 mbit
       '80buf','160buf','320buf','640buf','1280buf'; %40mbit
       '100buf','200buf','400buf','800buf','1600buf'; %50mbit 
       '120buf','240buf','480buf','960buf','1920buf'; %60mbit
       '140buf','280buf','560buf','1120buf','2240buf'}; %70mbit
iters={'0_ss','1_ss','2_ss','3_ss','4_ss','5_ss','6_ss','7_ss','8_ss','9_ss'};
file_ends={'cwnd.txt','send.txt','prate.txt','backed.txt','tstamp.txt','rtt.txt'};
sub_dirs={'cwnd/','send/','prate/','backed/','tstamp/','rtts/'};
schs={'0.0'};

% constant parameters
first_data='1000000MB';
second_data='1000000MB';
rtt='45ms';
lr='0%perc';
space='0.1gap';

% variable parameters
sch=schs(1);
iter=iters(2);

bw_idx=7; % 1-10mbit, 2-20mbit, 3-30mbit ...
bw=bws(bw_idx);
bdp_idx=3; % 1-BDP/2, 2-BDP, 3-2BDP, 4-4BDP, 5-8BDP
buf=buffs(bw_idx,bdp_idx);
buf_dim=size(buffs);
%dirct='files/parsed_0.0gap/';
dirct='files/parsed/';
file_end1=file_ends(6); 
sub_dir=strcat(dirct,sub_dirs(6));

cca_legend={};

selected_cca=ccas(2);



%cd files/parsed;
figure
for bw_idx=5:5%length(bws)
    bw=bws(bw_idx);
    for bdp_idx=4:4%buf_dim(2)
        buf=buffs(bw_idx,bdp_idx);
        for cca1_idx=1:2%length(ccas)
            cca_one=ccas(cca1_idx);
            for cca2_idx = 2:2%length(ccas)
                cca_two=ccas(cca2_idx);
                if strcmp(cca_two,'bbr')
                    cca_two=cca_one;
                    cca_one='bbr';
                elseif strcmp(cca_one,'reno')
                    cca_one=cca_two;
                    cca_two='reno';
                end
                
                if strcmp(selected_cca,cca_one)
                    plotted_flow=strcat(cca_one,'one');
                    other_flow=strcat(cca_two,'two');
                    cca_legend(end+1)=strcat('vs ',cca_two,'-',bw,'-',buf);
                else
                    plotted_flow=strcat(cca_two,'two');
                    other_flow=strcat(cca_one,'one');
                    cca_legend(end+1)=strcat('vs ',cca_one,'-',bw,'-',buf);
                end
                
                
                %file1=char(strcat(dir,cca_one,'_',first_data,'_',rtt,'_',cca_two,'_',second_data,'_',rtt,'_',bw,'_',buf,'_',lr,'_',sch,'_',space,'_',iter,'_',plotted_flow,'_',file_end1));
                file_regex_selected_cca=char(strcat(dirct,cca_one,'_',first_data,'_',rtt,'_',cca_two,'_',second_data,'_',rtt,'_',bw,'_',buf,'_',lr,'_',sch,'_',space,'_','*','_',plotted_flow,'_',file_end1));
                files_list_selected_cca = dir(file_regex_selected_cca);
                
                file_regex_other_cca=char(strcat(dirct,cca_one,'_',first_data,'_',rtt,'_',cca_two,'_',second_data,'_',rtt,'_',bw,'_',buf,'_',lr,'_',sch,'_',space,'_','*','_',other_flow,'_',file_end1));
                files_list_other_cca = dir(file_regex_other_cca);
                
                all_rtts=[];
                for i=1:length(files_list_selected_cca)
                   
                    rtts_per_iter=importdata(strcat(dirct,files_list_selected_cca(i).name));
                    all_rtts=[all_rtts ; rtts_per_iter];

                    t=[1:length(rtts_per_iter)]/100; % each point represents 10ms advance. divide by 100 to change to equivalent seconds.
                    %cdfplot(rtts_per_iter)
                    %mu = mean(rtts);
                    %sigma = std(rtts);
                    %pd = makedist('Normal',mu,sigma);
                    %cdf_rtt=cdf(pd,rtts);
                    %plot(cdf_rtt);
                    %plot(t,rtts)
                    %xlabel('Time (sec)')
                    %ylabel(strcat('RTTs of ',selected_cca))
                    %hold on
                    
                end 
                %size(all_rtts)
               
                %cdfplot(all_rtts)
                %hold on
            end
            
            plot(rtts_per_iter)
            hold on
        end
    end
end

ppty=char(file_end1);
ppty=ppty(1:end-4);
ttle= char(strcat(ppty,' of  ',selected_cca,'-',sch,'-',space,'-',bw,'-',buf,'-',first_data,'-',second_data))
title(ttle)
lgd=legend(cca_legend);
lgd.FontSize=14;

%figure
%plot(rtts_per_iter);



