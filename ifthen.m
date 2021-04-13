function [res] = ifthen(flag,value_if_true,value_if_false)

if flag
    res=value_if_true;
else
    res=value_if_false;
end    
    