% This function converts the blobs to meaningful x(time), y(frequency) and
% z(magnitude or power). It also cuts them if they are not unimodal and
% that is requsted
% https://github.com/WolfLabPenn/HFO-Detector
function cut_CC=cut_results(CC,freqs,z,time,force_unimodal)
sz=CC.ImageSize;
if CC.NumObjects~=0
    cut_CC(CC.NumObjects*2).y=[];
    cut_CC(CC.NumObjects*2).x=[];
    cut_CC(CC.NumObjects*2).z=[];
    I=0;
    for i=1:CC.NumObjects
        index=CC.PixelIdxList{i};
        [row,col] = ind2sub(sz,index);
        temp_z=z(index);
        temp_x=time(col)';
        temp_y=freqs(row)';
        if force_unimodal==true
            unimodal=false;
            new_cut(10).y=[];
            new_cut(10).x=[];
            new_cut(10).z=[];
            J=0;
            while unimodal==false
                [unimodal,temp_x,temp_y,temp_z,temp_cut]=cut_once(temp_x,temp_y,temp_z);
                if unimodal==false
                    J=J+1;
                    new_cut(J)=temp_cut;
                else
                    I=I+1;
                    cut_CC(I)=temp_cut;
                end
            end
            new_cut(J+1:end)=[];
            for j=1:length(new_cut)
                unimodal=false;
                temp_x=new_cut(j).x;
                temp_y=new_cut(j).y;
                temp_z=new_cut(j).z;
                while unimodal==false
                    [unimodal,temp_x,temp_y,temp_z,temp_cut]=cut_once(temp_x,temp_y,temp_z);
                    I=I+1;
                    cut_CC(I)=temp_cut;
                end
            end
        else
            I=I+1;
            cut_CC(I).x=temp_x;
            cut_CC(I).y=temp_y;
            cut_CC(I).z=temp_z;
        end
    end
    cut_CC(I+1:end)=[];
else
    cut_CC=[];
end