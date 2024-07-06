t = tcpclient("192.168.246.140",8080);
configureCallback(t,"byte",600,@readDataFcn);



function readDataFcn(src, ~)
src.UserData = read(src,src.BytesAvailableFcnCount,"uint8");
ch_1_data = src.UserData(1:100);
ch_1_data_lsb = ch_1_data(1:2:100);
ch_1_data_msb = (ch_1_data(2:2:100) .* 256);
ch_1_16_bit_data = ch_1_data_msb + ch_1_data_lsb;

ch_2_data = src.UserData(101:200);
ch_2_data_lsb = ch_2_data(1:2:100);
ch_2_data_msb = (ch_2_data(2:2:100) .* 256);
ch_2_16_bit_data = ch_2_data_msb + ch_2_data_lsb;

ch_3_data = src.UserData(201:300);
ch_3_data_lsb = ch_3_data(1:2:100);
ch_3_data_msb = (ch_3_data(2:2:100) .* 256);
ch_3_16_bit_data = ch_3_data_msb + ch_3_data_lsb;

ch_4_data = src.UserData(301:400);
ch_4_data_lsb = ch_4_data(1:2:100);
ch_4_data_msb = (ch_4_data(2:2:100) .* 256);
ch_4_16_bit_data = ch_4_data_msb + ch_4_data_lsb;

ch_5_data = src.UserData(401:500);
ch_5_data_lsb = ch_5_data(1:2:100);
ch_5_data_msb = (ch_5_data(2:2:100) .* 256);
ch_5_16_bit_data = ch_5_data_msb + ch_5_data_lsb;

ch_6_data = src.UserData(501:600);
ch_6_data_lsb = ch_6_data(1:2:100);
ch_6_data_msb = (ch_6_data(2:2:100) .* 256);
ch_6_16_bit_data = ch_6_data_msb + ch_6_data_lsb;

disp(ch_1_16_bit_data);
end