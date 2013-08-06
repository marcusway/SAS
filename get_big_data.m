function [data,rowHead,colHead] = get_tsv(file)

fid = fopen(file);
t = fgetl(fid);
colHead = textscan(t,'%s');
%get # data columns
length = size(colHead{1,1},1);
%make string with correct format for length data
format = ['%s',repmat('%f',1,length)];

%get parameters for buffer size
%get number column characters
[status, num_columns] = system( ['head -n 1 ', file, '| wc -m'] );
num_columns = str2num(num_columns);
%get number of rows
[status, num_rows] = system( ['wc -l ', file] );
num_rows = textscan(num_rows,'%f');
num_rows = cell2mat(num_rows);

bufsize = num_columns * num_rows(1);
data = textscan(fid,format,'BufSize',bufsize);

%store data
colHead = [colHead{:}];
rowHead = data{1};
data = [data{2:end}];
end