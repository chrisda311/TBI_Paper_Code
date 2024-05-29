function color = my_colors(name)
try
    if strncmpi(name,'b',1)
        if strncmpi(name,'brown',2)
            color = convert_to_rgb('#9c755f');
        elseif strncmpi(name,'black',3)
            color = [0,0,0];
        else
            color = convert_to_rgb('#4e79a7');
        end
    elseif strncmpi(name,'p',1)
        
        if strncmpi(name,'pink',2)
            color = convert_to_rgb('#ff9da7');
        else
            color = convert_to_rgb('#b07aa1');
        end
    elseif strncmpi(name,'g',1)
        
        if strncmpi(name,'gray',3)
            color = convert_to_rgb('#bab0ac');
        else
            color = convert_to_rgb('#59a14f');
        end
    elseif strncmpi(name,'red',1)
        color = convert_to_rgb('#e15759');
    elseif strncmpi(name,'orange',1)
        color = convert_to_rgb('#f28e2b');
    elseif strncmpi(name,'cyan',1)
        color = convert_to_rgb('#76b7b2');
        
    elseif strncmpi(name,'yellow',1)
        color = convert_to_rgb('#edc948');
    elseif strncmpi(name,'dark',1)
        color = convert_to_rgb('#555555');
        
    elseif strncmpi(name,'light',1)
        color = convert_to_rgb('#777777');
        
    elseif strncmpi(name,'white',1)
        color = [1,1,1];
    else
        color = [0,0,0];
    end
catch
    warning('Not a valid color name. Using black.')
    color = [0,0,0];
end
end

function rgb=convert_to_rgb(string)
rgb = sscanf(string(2:end),'%2x%2x%2x',[1 3])/255;
end
