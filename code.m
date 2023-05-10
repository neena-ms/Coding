code_huff=huffman_encoder('inputfile.txt');
huffman_decoder('huffmancode.txt','huffman_decoded.txt',code_huff);
code_lemp=lempelziv_encoder('inputfile.txt');
lempel_decoder('lempelcode.txt',code_lemp);

%calculating size of compressed files
fhuffcode=fopen('huffmancode.txt','r');
filearrayhuff=fscanf(fhuffcode,'%c');
flempelcode=fopen('lempelcode.txt','r');
filearraylemp=fscanf(flempelcode,'%c');
finput=fopen('inputfile.txt','r');
filearr=fscanf(finput,'%c');

%calculating size of huffman mapping table
bitsnum=values(code_huff);
bitshuff=0;
for i=1:length(bitsnum)
    bitshuff=bitshuff+length(convertStringsToChars(bitsnum(i)));
end

%calculating size of lempel-ziv mapping table
bitsnum=values(code_lemp);
bitschar=keys(code_lemp);
bitslemp=0;
for i=1:length(bitsnum)
    bitslemp=bitslemp+length(convertStringsToChars(bitsnum(i)));
    bitslemp=bitslemp+length(convertStringsToChars(bitschar(i)));
end

%calculating and displaying compression ratios
compression_ratio_huffman=(8*length(filearr))/(length(filearrayhuff)+numEntries(code_huff)+bitshuff);
compression_ratio_lempel=(8*length(filearr))/(length(filearraylemp)+bitslemp);
display(compression_ratio_huffman);
display(compression_ratio_lempel);

hamming_encoder('huffmancode.txt');
error_generator('hammingcode.txt');
syndrome_decoder('errorhammingcode.txt');
huffman_decoder('syndromedecoded.txt','huffman_decoded_channel.txt',code_huff);

function codemap= huffman_encoder(fname)
    file=fopen(fname,'r');
    filearray=fscanf(file,'%c'); %reading the input file
    filearr=filearray.';
    [GC,GR]=groupcounts(filearr);   %GR and GC contains unique characters and their corresponding number of occurences in the input file respectively
    prob=zeros(1,length(GC));
    inputchar=string.empty();
    for i=1:length(GC)
        prob(i)=GC(i)/length(filearr); %storing probabilities of characters in prob
    end
    for i=1:length(GR)
        inputchar(i)=GR(i);      %storing unique characters in inputchar
    end
    char=inputchar;
    codemap=dictionary(char,repmat(" ",1,length(char))); %creating mapping table
    for a=1:(length(GC)-1)    %building Huffman tree
        if(prob(1)<=prob(2))    
            j=1;
            k=2;
        else
            k=1;
            j=2;
        end
        for i=3:length(prob)   %finding 2 least probable characters
            if (prob(i)<prob(j))
                k=j;
                j=i;
            elseif (prob(i)<prob(k))
                k=i;
            end
        end
        charver=char.';
        comb=charver(j);
        for f=1:strlength(comb)
            sym=extract(comb,f);
            if (codemap(sym)==" ")
                codemap(sym)="0";    %if left leaf node, code='0'
            else
                codemap(sym)=convertCharsToStrings(append(codemap(sym),'0'));  %if internal left node, append '0' to code
            end
        end
        comb=charver(k);
        for f=1:strlength(comb)
            sym=extract(comb,f);
            if (codemap(sym)==" ")
                codemap(sym)="1";   %if right leaf node, code='1'
            else
                codemap(sym)=convertCharsToStrings(append(codemap(sym),'1'));  %if internal right node, append '1' to code
            end
        end
        char(length(char)+1)=append(char(j),char(k)); %add parent node to tree(appended string)
        prob(length(prob)+1)=prob(j)+prob(k);         %add its corresonding probability
        char(j)=[];
        prob(j)=[];
        if (j<k)                                     %delete the individual nodes from the list
            char(k-1)=[];
            prob(k-1)=[];
        else
            char(k)=[];
            prob(k)=[];
        end
    end
    revcode=values(codemap);
    for i=1:length(revcode)
        revcode(i)=reverse(revcode(i));         %reverse the reversed huffman codes
    end
    codemap=dictionary(inputchar,revcode.');
    display("Code table for Huffman code : ")
    display(codemap);                          %displaying mapping table of Huffman code
    fclose('all');
    output=fopen('huffmancode.txt','w');       %encoding input file
    for i=1:length(filearray)
        fprintf(output,codemap(filearray(i)));
    end
end

function huffman_decoder(fname,fout,codeset)
    file=fopen(fname,'r');
    fileout=fopen(fout,'w');
    filearray=fscanf(file,'%c');
    filearray=filearray.';
    comb=" ";
    char=keys(codeset);
    code=values(codeset);
    for j=1:length(filearray)   
        next=filearray(j);     %if combination is empty, form new combination
        if (comb==" ")     
            comb=next;
        else
            comb=append(comb,next); %if not empty, append next character to existing combination
        end
        a=1;
        ex=0;
        while((a<=length(code)) && (ex~=1))
            if (comb==code(a))          %if code matches any value in mapping table, output the character
                fprintf(fileout,char(a)); 
                comb=" ";      %make combination empty
                ex=1;
            end
            a=a+1;
        end
    end
end

function codemap=lempelziv_encoder(fname)
    file=fopen(fname,'r');
    fout=fopen('lempelcode.txt','w');
    filearr=fscanf(file,'%c');            %reading input file
    asciival=[];
    for i=1:length(filearr)
        asciival(i)=double(filearr(i));  %converting input characters to ascii values
    end
    for i=1:length(asciival)
        binval(i)=convertCharsToStrings(dec2bin(asciival(i),8));   %converting ascii values to 8 bit binary value
    end
    bininput=binval(1);
    for i=2:length(binval)
        bininput=append(bininput,binval(i));
    end 
    bininput=convertStringsToChars(bininput);  %binary string is formed
    symb=[bininput(1)];
    codemap=dictionary(bininput(1),bininput(1));   %map first bit to itself
    symnum=[1];
    comb=" ";
    for i=2:length(bininput)               %mapping other bits
        if (comb==" ")
            comb=bininput(i);              %forming next combination
        else
            comb=append(comb,bininput(i));
        end
        j=1;
        ex=0;
        while((j<=length(symb)) && (ex~=1))  %check if combination is already mapped
            if (strcmp(symb(j),comb))         
                ex=1;
            end
            j=j+1;
        end
        if (ex==0)                 %if combination is not mapped, map it
            if (length(comb)==1)
                codemap(comb)=comb;  %if 1 bit combination, map it to itself
                symb=[symb;comb];
                symnum(length(symnum)+1)=length(symnum)+1;   %store the symbol's number
            else
                pos=find(symb==prev);  %if more than 1 bit combination,append the last bit to symbol number of previous combination
                codeout=append(num2str(symnum(pos(1))),bininput(i));   
                codemap(comb)=codeout;
                comb=convertCharsToStrings(comb);
                symb=[symb;comb];
                symnum(length(symnum)+1)=length(symnum)+1;  %store symbol number 
            end
            comb=" ";
        else
            prev=comb;
        end
    end
    numbits=ceil(log2(numEntries(codemap)));     %calculate number of bits for encoding symbol number
    code=values(codemap);
    symval=keys(codemap);
    for i=1:length(code)
        if(strlength(code(i))==1)
            newbit=code(i);
            prevbit='0';   
            for y=2:numbits
                prevbit=append(prevbit,'0');     %if symbol number is null, append 0
            end
        else
            string=convertStringsToChars(code(i));
            newbit=string(length(string));
            prevbit=string(1:end-1);
            prevbit=dec2bin(str2double(prevbit),numbits);  %append binary encoded value of symbol number
        end
        fprintf(fout,prevbit);
        fprintf(fout,newbit);      %print symbol number and new bit into file
        code(i)=append(prevbit,newbit);  %store the code in mapping table
    end
    codemap=dictionary(symval,code);
    display("Code table for Lempel-Ziv code : ")
    display(codemap);
    if (comb~=" ")
        fprintf(fout,codemap(comb));   %encode the left over bits using values in mapping table
    end
end

function lempel_decoder(fname,codemap)
    file=fopen(fname,'r');
    fileout=fopen('lempel_decoded.txt','w');
    filearray=fscanf(file,'%c');        %read the encoded data
    symval=keys(codemap);
    code=values(codemap);
    binval=" ";
    numbits=ceil(log2(numEntries(codemap)));   %calculate number of bits of symbol number
    for i=1:numbits+1:length(filearray)
        bin=filearray(i);
        for y=1:numbits
            bin=append(bin,filearray(i+y));   %extracting binary value of a symbol
        end
        j=1;
        ex=0;
        while((j<=length(code)) && (ex~=1))
            if(code(j)==bin)                   %decoding binary value using mapping table
                if (binval==" ")
                    binval=symval(j);
                else
                    binval=append(binval,symval(j));
                end
                ex=1;
            end
            j=j+1;
        end
    end
    binval=convertStringsToChars(binval);     %decoded binary string
    for i=1:8:(length(binval)-7)
        val=binval(i);
        for j=1:7
            val=append(val,binval(i+j));     %taking 8 bits (since binary encoding was done with 8 bits)
        end
        ascii=bin2dec(val);              %converting 8 bit binary value to ascii
        fprintf(fileout,char(ascii));      %printing character corresponding to the ascii value to output file
    end
end

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
