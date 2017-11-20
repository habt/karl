ccas = {'bbr','cubic','reno'}
bws={'10mbit','20mbit','30mbit','40mbit','50mbit','60mbit','70mbit'}
%buffer-BDP/2 , BDP ,  2BDP   ,  4BDP  , 8BDP
buffs={'20buf','40buf','80buf','160buf','320buf'; %10mbit
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
file_end1=file_ends(3); %1-cwnd, 2-send ,3-prate,4-backed
sch=schs(1);
iter=iters(2);
analyzed_flow= flow_types(1);%1-analyse large flow, 2-analyse small flow

bw_idx=7; % 1-10mbit, 2-20mbit, 3-30mbit ...
bw=bws(bw_idx);
bdp_idx=3; % 1-BDP/2, 2-BDP, 3-2BDP, 4-4BDP, 5-8BDP
buf=buffs(bw_idx,bdp_idx);
buf_dim=size(buffs);
%dir='files/oldparsed/';
dirc=char('files/parsed_1MB_corrected/');

cca_legend={};
cca_large=ccas(1);

%selected_bw={bws(1),bw(2)}
%selected_bufs={bws(1),bw(2)}

for bw_idx = 7:7%length(bws)
    bw=bws(bw_idx);
    for bdp_idx=1:3%bf_dim(2)
        buf=buffs(bw_idx,bdp_idx);
        for idx = 1:1%length(ccas)-2
            cca_small=ccas(idx);

            file1=char(strcat(dirc,cca_large,'_',l_data,'_',rtt,'_',cca_small,'_',s_data,'_',rtt,'_',bw,'_',buf,'_',lr,'_',sch,'_',space,'_',iter,'_',analyzed_flow,'_',file_end1));
            B=importdata(file1);


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
            t=[1:length(B)]/100; % each point represents 10ms advance. divide by 100 to change to equivalent seconds.


            if (strcmp(file_end1,'cwnd.txt'))
                plot(t,B)
                xlabel('Time (sec)')
                if strcmp(analyzed_flow,'large')
                    ylabel('CWND of large flow')
                else
                   ylabel('CWND of small flows') 
                end;
                bw_str=char(buffs(bw_idx,bdp_idx)); % 2-for bdp
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
            if (strcmp(file_end1,'rtt.txt'))
                
            end
            
            hold on
        end
    end
end
ppty=char(file_end1);
ppty=ppty(1:end-4);
title(char(strcat(ppty,'-',sch,'-',l_data,'-',s_data)));
lgd=legend(cca_legend);
lgd.FontSize=14;