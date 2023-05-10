code_lemp=lempelziv_encoder('inputfile.txt');
lempel_decoder('lempelcode.txt',code_lemp);
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
