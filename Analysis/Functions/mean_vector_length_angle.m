function [MVL,MA]=mean_vector_length_angle(phase,amp)
    
temp=sum(amp.*exp(1i.*phase));    
MVL=abs(temp)/length(phase);
MA=angle(temp);
end