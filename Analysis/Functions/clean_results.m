% This function goes through the blobs, clean them up and check the
% criteria passed to it to reject or accept blobs as ripples or
% fast-ripples. It also attempts to find some artifacts. The artifcats are
% rejctions that can have characteristics of an artifact. 
% https://github.com/WolfLabPenn/HFO-Detector
function [event,artifacts_frequency_range,artifacts_amplitude]=clean_results(CC,freqs,z,f,Mu,Sig,time,compare,center,parameters,unimodal)
I=0;
event(1e6) = struct('frequency',[],'time',[],'mean',[],'duration',[],'center',[]);
J=0;
artifacts_frequency_range=zeros(1e6,1);
K=0;
artifacts_amplitude=zeros(1e6,1);
cut_CC=cut_results(CC,freqs,z,time,unimodal);
frequency_range_th=parameters.frequency_range_th*(max(freqs)-min(freqs));
for i=1:length(cut_CC)
    temp_x=cut_CC(i).x;
    temp_y=cut_CC(i).y;
    temp_z=cut_CC(i).z;
    if strcmp(compare,'power')
        temp_z=temp_z.^2;
    end
    if strcmp(center,'max')
        [~,max_ind]=max(temp_z);
        center_f=temp_y(max_ind);
        center_t=temp_x(max_ind);
    else
        center_f=sum(temp_z.*temp_y)/sum(temp_z);
        center_t=sum(temp_z.*temp_x)/sum(temp_z);
    end
    [~,ind_F]=min(abs(temp_y-center_f));
    [~,ind_F_real]=min(abs(f-center_f));
    all_inds=temp_y==temp_y(ind_F);
    temp_range=temp_x(all_inds);
    dT=max(temp_range)-min(temp_range);
    if max(temp_z)<parameters.ext
        if range(temp_y)<frequency_range_th
            if dT>parameters.n_cyles/center_f
                test=mean_amplitude(temp_x,temp_y,temp_z);
                if log(test)>Mu(ind_F_real)+Sig*parameters.mean_th
                    I=I+1;
                    event(I).frequency=temp_y;
                    event(I).time=temp_x;
                    event(I).amplitude=temp_z;
                    event(I).center.frequency=center_f;
                    event(I).center.time=center_t;
                    event(I).duration=dT*1000;
                    event(I).mean=test;
                end
            end
        else
            J=J+1;
            artifacts_frequency_range(J)=center_t;
        end
    else
        K=K+1;
        artifacts_amplitude(K)=center_t;
    end
end
%%
event(I+1:end)=[];
artifacts_frequency_range(J+1:end)=[];
artifacts_amplitude(K+1:end)=[];