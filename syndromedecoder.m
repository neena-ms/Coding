syndrome_decoder('errorhammingcode.txt');
function syndrome_decoder(fname)      
    file=fopen('hammingcode.txt','r');
    filearray=fscanf(file,'%c');     %reading input file
    fout=fopen('syndromedecoded.txt','w');
    data=filearray;
    for i=1:7:length(filearray)           %taking 7 bits at a time and finding syndrome vector
        s=[num2str(rem(str2num(filearray(i))+str2num(filearray(i+1))+str2num(filearray(i+3))+str2num(filearray(i+4)),2))];
        s=[s,num2str(rem(str2num(filearray(i))+str2num(filearray(i+2))+str2num(filearray(i+3))+str2num(filearray(i+5)),2))];
        s=[s,num2str(rem(str2num(filearray(i+1))+str2num(filearray(i+2))+str2num(filearray(i+3))+str2num(filearray(i+6)),2))];
        if(~(strcmp(s,"000")))       %if syndrome vector=000, no error
            if(strcmp(s,"110"))       %finding error bit by comparing syndrome vector with columns of parity check matrix
                errorbit=1;
            elseif(strcmp(s,"101"))
                errorbit=2;
            elseif(strcmp(s,"011"))
                errorbit=3;
            elseif(strcmp(s,"111"))
                errorbit=4;
            elseif(strcmp(s,"100"))
                errorbit=5;
            elseif(strcmp(s,"010"))
                errorbit=6;
            elseif(strcmp(s,"001"))
                errorbit=7;
            end
            if(data(i+errorbit-1)=="0")     %in case of error, invert the error bit
                data(i+errorbit-1)="1";
            elseif(data(i+errorbit-1)=="1")
                data(i+errorbit-1)="0";
            end
        end
        received=append(data(i),data(i+1),data(i+2),data(i+3));   %decode the 7 bit into 4 bits by taking only the first 4 bits
        fprintf(fout,received);
    end
end
