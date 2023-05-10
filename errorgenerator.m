error_generator('hammingcode.txt');
function error_generator(fname)
    file=fopen('hammingcode.txt','r');
    filearray=fscanf(file,'%c');             %reading input file
    fout=fopen('errorhammingcode.txt','w');
    data=filearray;c
    p=0.9;                                %setting probability of bit error=0.04
    for i=1:length(filearray)
        randomnum=randi((ceil(1/p)),1);        %generating a random number in range 1 to 25        
        if (randomnum==14)              %probability of getting a single number= 1/25=0.04
            if(data(i)=="1")            %inverting the bit with 0.04 probability
                fprintf(fout,"0");
            elseif(data(i)=="0")
                fprintf(fout,"1");
            end
        else
            fprintf(fout,data(i));         %print bits into output file after error generation
        end
    end
end
