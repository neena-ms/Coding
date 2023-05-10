hamming_encoder('huffmancode.txt');
function hamming_encoder(fname)
    file=fopen(fname,'r');
    filearray=fscanf(file,'%c');        %reading input file
    fout=fopen('hammingcode.txt','w');
    padbits=rem(length(filearray),4);
    if (padbits~=0)
        for i=1:padbits
            filearray=append(filearray,'0');
        end
    end
    for i=1:4:(length(filearray)-3)        %taking 4 bits at a time and finding output of the message bits multiplied by generator matrix
        x=[filearray(i),filearray(i+1),filearray(i+2),filearray(i+3)];   %identity matrix bits
        x=[x,num2str(rem(str2num(filearray(i))+str2num(filearray(i+1))+str2num(filearray(i+3)),2))];  %parity matrix bits
        x=[x,num2str(rem(str2num(filearray(i))+str2num(filearray(i+2))+str2num(filearray(i+3)),2))];    %parity matrix bits
        x=[x,num2str(rem(str2num(filearray(i+1))+str2num(filearray(i+2))+str2num(filearray(i+3)),2))];   %parity matrix bits
        fprintf(fout,x);    %4 bit code is converted to 7 bit code and outputted into file
    end
end
