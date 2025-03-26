function [methodinfo,structs,enuminfo,ThunkLibName]=treadmill_proto
%TREADMILL_PROTO Create structures to define interfaces found in 'treadmill_remote'.

%This function was generated by loadlibrary.m parser version  on Thu Jan  9 13:00:20 2025
%perl options:'treadmill_remote.i -outfile=treadmill_proto.m -thunkfile=treadmill_remote_thunk_pcwin64.c -header=treadmill_remote.h'
ival={cell(1,0)}; % change 0 to the actual number of functions to preallocate the data.
structs=[];enuminfo=[];fcnNum=1;
fcns=struct('name',ival,'calltype',ival,'LHS',ival,'RHS',ival,'alias',ival,'thunkname', ival);
MfilePath=fileparts(mfilename('fullpath'));
ThunkLibName=fullfile(MfilePath,'treadmill_remote_thunk_pcwin64');
%  int TREADMILL_initialize ( char * ip , char * port ); 
fcns.thunkname{fcnNum}='int32cstringcstringThunk';fcns.name{fcnNum}='TREADMILL_initialize'; fcns.calltype{fcnNum}='Thunk'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'cstring', 'cstring'};fcnNum=fcnNum+1;
%  int TREADMILL_setSpeed ( double left , double right , double acceleration ); 
fcns.thunkname{fcnNum}='int32doubledoubledoubleThunk';fcns.name{fcnNum}='TREADMILL_setSpeed'; fcns.calltype{fcnNum}='Thunk'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'double', 'double', 'double'};fcnNum=fcnNum+1;
%  void TREADMILL_close ( void ); 
fcns.thunkname{fcnNum}='voidvoidThunk';fcns.name{fcnNum}='TREADMILL_close'; fcns.calltype{fcnNum}='Thunk'; fcns.LHS{fcnNum}=[]; fcns.RHS{fcnNum}=[];fcnNum=fcnNum+1;
%  int TREADMILL_initializeUDP ( char * ip , char * port ); 
fcns.thunkname{fcnNum}='int32cstringcstringThunk';fcns.name{fcnNum}='TREADMILL_initializeUDP'; fcns.calltype{fcnNum}='Thunk'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'cstring', 'cstring'};fcnNum=fcnNum+1;
methodinfo=fcns;