function [ uvr_hist,uvr] = read_uvr_hist( file_hist,date )
%function [ uvr_hist,uvr] = read_uvr_hist( file_hist,date )
% analize the uv historic file from uvbrewer
% input
%   file_hist: fullpath of the historic file (uvbrewer format)
%   date: optionsl if date argument is provided returns uvr
%        the response file nearest to the date provided 
%        j=find((uvr_hist.fecha-date)<0,1,'last');
%        uvr is empty if not found
% output
%    uvr_hist : struct with date and the name of the file
%    uvr: is the fullpath of the response file for a given date.
%    empty if not found
aux=fileread(file_hist);
data=textscan(aux,'%02f %02f %04f %12c','delimiter','.','collectOutput',1);
uvr_hist.fecha=(datenum(data{1}(:,3:-1:1)));
uvr_hist.file_resp=data{2};
%uvr_hist.n=unique(cellfun(@(x) size(x,1),data));

if nargin==2
    j=find((uvr_hist.fecha-date)<0,1,'last');
    if ~isempty(j)
      resp_path=fileparts(file_hist);
      uvr=fullfile(resp_path,data{2}(j,:));   
    else
       uvr=[];
    end
end

