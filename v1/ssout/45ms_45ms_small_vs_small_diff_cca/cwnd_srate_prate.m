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
file_ends={'cwnd.txt','send.txt','prate.txt','backed.txt','tstamp.txt','rtt.txt'}
schs={'0.0'};

% constant parameters
first_data='1000000MB';
second_data='1000000MB';
rtt='45ms';
lr='0%perc';
space='0.1gap';

% variable parameters
file_end1=file_ends(1); %1-cwnd, 2-send ,3-prate,4-backed
sch=schs(1);
iter=iters(2);

bw_idx=7; % 1-10mbit, 2-20mbit, 3-30mbit ...
bw=bws(bw_idx);
buf_idx=3; % 1-BDP/2, 2-BDP, 3-2BDP, 4-4BDP, 5-8BDP
buf=buffs(bw_idx,buf_idx);
buf_dim=size(buffs);
dir='files/parsed/';

cca_legend={};
cca_large=ccas(2);


%selected_bw={bws(1),bw(2)}
%selected_bufs={bws(1),bw(2)}

selected_cca=ccas(2);

for bw_idx = 8:8%length(bws)
    bw=bws(bw_idx);
    for buf_idx=3:3%buf_dim(2)
        buf=buffs(bw_idx,buf_idx);
        for cca1_idx=1:2%length(ccas)
            cca_one=ccas(cca1_idx);
            %for cca2_idx = 2:2%length(ccas)-2
                cca_two=ccas(2);
                %for idx=2:2
                    %cca_two=selected_cca;
                    
                    if strcmp(selected_cca,'bbr')
                        cca_two=cca_one;
                        cca_one=selected_cca;
                        %plotted_flow=strcat(cca_one,selected_flow);
                    elseif strcmp(cca_two,'bbr')
                        temp=cca_one;
                        cca_one=cca_two;
                        cca_two=temp;
                    elseif strcmp(cca_one,'reno')
                        temp=cca_two;
                        cca_two=char('reno');
                        cca_one=temp;
                    else %no change
                        cca_one=cca_one;
                        cca_two=cca_two;
                    end
                   
                    if strcmp(selected_cca,cca_one)
                        plotted_flow=strcat(cca_one,'one');
                        cca_legend(end+1)=strcat('vs ',cca_two,'-',bw,'-',buf);
                    else
                        plotted_flow=strcat(cca_two,'two');
                        cca_legend(end+1)=strcat('vs ',cca_one,'-',bw,'-',buf);
                    end
                    %if strcmp(selected_flow,'one')
                       % plotted_flow=strcat(cca_one,selected_flow);
                    %else
                     %   plotted_flow=strcat(cca_two,selected_flow);
                    %end
                    
                    file1=char(strcat(dir,cca_one,'_',first_data,'_',rtt,'_',cca_two,'_',second_data,'_',rtt,'_',bw,'_',buf,'_',lr,'_',sch,'_',space,'_',iter,'_',plotted_flow,'_',file_end1));
                    B=importdata(file1);

                    %{
                    if strcmp(cca_two,'reno')
                        second_legend='new reno';
                    elseif strcmp(cca_one,'reno')  
                        first_legend='new reno';
                    else 
                        first_legend=cca_one;
                        second_legend=cca_two;
                    end

                    if strcmp(selected_flow,'one')
                        cca_legend(end+1)= strcat(first_legend,'-',bw,'-',buf);
                    else
                        cca_legend(end+1)= strcat(second_legend,'-',bw,'-',buf);
                    end
                    %}
                    t=[1:length(B)]/100; % each point represents 10ms advance. divide by 100 to change to equivalent seconds.


                    if (strcmp(file_end1,'cwnd.txt'))
                        plot(t,B)
                        xlabel('Time (sec)')
                        ylabel(strcat('CWND of ',selected_cca))
                        bw_str=char(buffs(bw_idx,buf_idx)); % 2-for bdp
                        bw_str=bw_str(1:end-3);
                        buf_val=str2double(bw_str);
                        %refline(0,buf_val);
                    end

                    if (strcmp(file_end1,'send.txt')  ||  strcmp(file_end1,'prate.txt'))
                        %idx=B>140;
                        %B(idx)=B(idx)/1000;
                        plot(t,B)
                        xlabel('Time (sec)')
                        if strcmp(analyzed_flow,'large')
                            ylabel('Rate of large flow (Mbps)')
                        else
                           ylabel('Rate of small flow (Mbps)') 
                        end;
                        bw_str=char(bw);
                        bw_str=bw_str(1:end-4);
                        bw_val=str2double(bw_str);
                        refline(0,bw_val);
                    end
                    hold on
                %end
            %end  
        end
    end
end
ppty=char(file_end1);
ppty=ppty(1:end-4);
title(char(strcat(ppty,'-',sch,'-',bw,'-',buf,'-',first_data,'-',second_data)));
lgd=legend(cca_legend);
lgd.FontSize=14;