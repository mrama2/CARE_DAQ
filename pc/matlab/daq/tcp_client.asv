t = tcpclient("192.168.246.140",8080);
configureCallback(t,"byte",600,@readDataFcn);



function readDataFcn(src, ~)
src.UserData = read(src,src.BytesAvailableFcnCount,"uint8");
size(src.UserData)
disp(src.UserData);
end