code_huff=huffman_encoder('inputfile.txt');
huffman_decoder('huffmancode.txt','huffman_decoded.txt',code_huff);
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
