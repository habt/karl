
num_prots=3;

bws={'5mbit','10mbit','20mbit','30mbit','40mbit','50mbit','60mbit','70mbit'};
bw_bps_arr=[5000000,10000000 20000000 30000000 40000000 50000000 60000000 70000000];

%all buffs included BDP/2, BDP , 2BDP, 4BDP, 8BDP

buffs={'10buf','20buf','40buf','80buf','160buf'; %5mbit
       '20buf','40buf','80buf','160buf','320buf'; %10mbit
       '40buf','80buf','160buf','320buf','640buf'; %20mbit
       '60buf','120buf','240buf','480buf','960buf'; %30 mbit
       '80buf','160buf','320buf','640buf','1280buf'; %40mbit
       '100buf','200buf','400buf','800buf','1600buf'; %50mbit 
       '120buf','240buf','480buf','960buf','1920buf'; %60mbit
       '140buf','280buf','560buf','1120buf','2240buf'}; %70mbit

buffs_dim=size(buffs);

burst = 1600;

lrs={'0%perc'};
schemes={'0.0','0.4'};%i.e. start delay of first small flow


exp_sizes={'1000000MB'};%reps 10,20
sma_sizes={'1000000MB'}

ccas={'1000000MB'}
spacings={'0.0gap','0.1gap','0.2gap','0.3gap','0.4gap','0.5gap'}


lr=lrs;
%sch=schemes;
exp=exp_sizes;
sma=sma_sizes;

ccas={'bbr','cubic','reno'}
cca_legend={};

%cd files/point4_point8;
cd files;
test_bw_idx=7;
test_buf_idx=2;

markers={'-','.','-.'};
colors={'g','m','r'};
clrs=[1 0 0 ; 0 1 0; 0 0 1];
gap=spacings(2);
ite=1;

count=0;
for sch_idx = 1:1%length(schemes)
    sch=schemes(sch_idx);
    for lar_idx=1:1%length(ccas)-2
        cca_one=ccas(lar_idx);
        for sma_idx=2:2%length(ccas)-1
            cca_two=ccas(sma_idx);
            for bw_idx=2:2%length(bw)
                bw=bws(bw_idx);
                for bdp_idx = 4:4%buffs_dim(2)
                    %bdp_idx= 1;
                    for count = 1:1
                        %count=count+1;
                        if count==1
                            cca1=cca_one;
                            cca2=cca_one;
                        elseif count==2
                            cca1=cca_one;
                            cca2=cca_two;
                        else
                            cca1=cca_two;
                            cca2=cca_two;
                        end
                        buf=buffs(bw_idx,bdp_idx);
                        file_end = char(strcat(num2str(ite),'_ifb0.txt'));
                        filename_regex = char(strcat(cca1,'*',exp(1),'*',cca2,'*',sma(1),'*',bw,'_',buf,'_',lr(1),'_',sch,'_',gap,'*',file_end));
                        str = char(filename_regex);
                        all_prot_exp_files = dir(filename_regex);
                        M=csvread(all_prot_exp_files(1).name);

                        sz=size(M)
                        dur=M(sz(1),1)-M(1,1)
                        dur = dur/1000
                        x=0:dur/sz(1):dur;
                        bw_bps=bw_bps_arr(bw_idx);
                        q_sec= M(:,2)*(burst*8/bw_bps)*(1000); %queue drain time in ms                       
                        %pl=plot(x(1:length(M)),M(:,2),char(colors(count)));
                        %pl.Color=clrs(count,:);
                        plot(x(1:length(M)),q_sec,char(colors(sch_idx)));
                        hold on;
                        buf_str=char(buf);
                        buf_str=buf_str(1:end-3);
                        buf_val=str2double(buf_str);
                        %plot([x(1) x(length(M))],[buf_val buf_val])
                        %refline(0,buf_val);
                        %{
                        if strcmp(cca_one,'bbr')
                            large_legend='BBR';
                        elseif strcmp(cca_one,'cubic')
                            large_legend='CUBIC';
                        else
                            large_legend='NEW RENO';
                        end

                        if strcmp(cca_two,'reno')
                            small_legend='new reno';
                        else
                            small_legend=cca_two;
                        end
                        %}
                        large_legend=cca1;
                        small_legend=cca2;
                        cca_legend(end+1)= strcat(large_legend,'-',small_legend,'-',bw,'-',buf,'-',sch,'-',gap);

                        hold on
                    end
                end
            end
        end
    end
end

%cd ../.. ;
cd ..;
%ppty=char(file_end1);
%ppty=ppty(1:end-4);
%title(char(strcat(ppty,'-',sch,'-',l_data,'-',s_data)));
ylabel('Packet queue(ms)','FontSize',14);
xlabel('Time (sec)','FontSize',14);
lgd=legend(cca_legend);
lgd.FontSize=12;

