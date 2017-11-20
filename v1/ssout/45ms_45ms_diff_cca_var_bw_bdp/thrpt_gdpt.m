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
flow_types={'large','small'}
file_ends={'cwnd.txt','send.txt','prate.txt','backed.txt','tstamp.txt','rtt.txt'}
schs={'0.0','0.5'};

% constant parameters
l_data='30000000MB';
s_data='1000000MB';
rtt='45ms';
lr='0%perc';
space='0.1gap';

% variable parameters
file_end1=file_ends(4); %1-cwnd, 2-send ,3-prate,4-backed
sch=schs(2);
iter=iters(1);
analyzed_flow= flow_types(1);%1-analyse large flow, 2-analyse small flow
bdp_idx=2; % 1-BDP/2, 2-BDP, 3-2BDP, 4-4BDP, 5-8BDP
bw_idx=1; % 1-10mbit, 2-20mbit, 3-30mbit ...
bw=bws(bw_idx);
buf=buffs(bw_idx,bdp_idx);

%use the two below for tstamp and rtt , i.e throughput and/or goodput computation
rtt_end=file_ends(6);
if strcmp(analyzed_flow,'large')
    tstamp_end=file_ends(5); %5-tstamp,6-rtt
else
    tstamp_end='tstamp_corrected.txt';
end

%dirc='files/parsed/';
dirc=char('files/parsed_1MB_corrected/');


cca_large=ccas(1);
cca_legend={};
line_styles={'-','-.'};

thrpt_or_gdpt=2; %if 1 calculate thrpt else calculate goodput

for bw_idx = 8:8 %length(bws)
    bw=bws(bw_idx);
    for bdp_idx=2:2%buf_dim(2)
        buf=buffs(bw_idx,bdp_idx);
        for idx = 2:2 %length(ccas)-1
                cca_small=ccas(idx);
 
                %file1=char(strcat(dirc,cca_large,'_',l_data,'_',rtt,'_',cca_small,'_',s_data,'_',rtt,'_',bw,'_',buf,'_',lr,'_',sch,'_',space,'_',iter,'_',analyzed_flow,'_',file_end1));

                file1=char(strcat(dirc,cca_large,'_',l_data,'_',rtt,'_',cca_small,'_',s_data,'_',rtt,'_',bw,'_',buf,'_',lr,'_',sch,'_',space,'_',iter,'_',analyzed_flow,'_',file_end1));
                file2=char(strcat(dirc,cca_large,'_',l_data,'_',rtt,'_',cca_small,'_',s_data,'_',rtt,'_',bw,'_',buf,'_',lr,'_',sch,'_',space,'_',iter,'_',analyzed_flow,'_',tstamp_end));
                file3=char(strcat(dirc,cca_large,'_',l_data,'_',rtt,'_',cca_small,'_',s_data,'_',rtt,'_',bw,'_',buf,'_',lr,'_',sch,'_',space,'_',iter,'_',analyzed_flow,'_',rtt_end));

                %file2id = fopen(file2,'r');
                %formatSpec = '%f';

                byte_acked=importdata(file1);
                t_stmp=importdata(file2);
                rtt=importdata(file3);
                %T=fscanf(file2id,formatSpec);

                %fclose(file2id);

                if strcmp(cca_large,'bbr')
                    large_legend='BBR';
                elseif strcmp(cca_large,'cubic')
                    large_legend='CUBIC';
                else
                    large_legend='NEW RENO';
                end

                if strcmp(cca_small,'reno')
                    small_legend='new reno';
                else
                    small_legend=cca_small;
                end


                cca_legend(end+1)= strcat(large_legend,'-',small_legend,'-',bw,'-',buf);

                if thrpt_or_gdpt==1    
                    %compute throughput using timestamps and acked bytes
                    durs=t_stmp-t_stmp(1);% in ms
                    thrpt_tstamp=byte_acked(1:length(durs))./durs;
                    thrpt_tstamp=thrpt_tstamp*8/1000; %convert from KBs to Mbs
                    %figure(f3);
                    t=[1:length(thrpt_tstamp)]/100; % each point represents 10ms advance. divide by 100 to change to equivalent seconds.
                    plot(t,thrpt_tstamp,char(line_styles(idx)))
                    xlabel('Time(secs)');
                    if strcmp(analyzed_flow,'large')
                        ylabel('Throughput of large flow (Mbps)')
                    else
                       ylabel('Throughput of small flow (Mbps)') 
                    end;
                    %hold on 
                    %plot(t,B)
                else  

                    %compute goodput using RTT and change in acked bytes
                    B_shifted=circshift(byte_acked,1);
                    B_shifted(1)=0;
                    B_change=byte_acked-B_shifted;
                    goodpt_rtt=zeros(length(B_change));
                    for n = 1 : length(B_change)
                        goodpt_rtt(n)=B_change(n)/rtt(n);
                        %if thrpt_rtt(n) == 0
                            %thrpt_rtt(n)= thrpt_rtt(n-1);
                        %end
                    end
                    goodpt_rtt=goodpt_rtt*8/1000;
                    %figure(f4);
                    plot(goodpt_rtt);

                end  
                hold on
                %plot(rtt)

        end
    end
end
%title(char(strcat(bw,'-',buf,'-',sch,'-',l_data,'-',s_data)));
legend(cca_legend);