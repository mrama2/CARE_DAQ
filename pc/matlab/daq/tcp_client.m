global ppg;
global packet_received;
global T;
global sppg;
T =0:0.005:(50-1)*0.005;
ppg =[];
t = tcpclient("192.168.246.140",8080);
configureCallback(t,"byte",600,@readDataFcn);


function readDataFcn(src, ~)
global ppg;
global T;
sampling_freq = 200;
step = 1/sampling_freq;
src.UserData = read(src,src.BytesAvailableFcnCount,"uint8");
ch_1_data = src.UserData(1:100);
ch_1_data_lsb = ch_1_data(1:2:100);
ch_1_data_msb = (ch_1_data(2:2:100) .* 256);
ch_1_16_bit_data = ch_1_data_msb + ch_1_data_lsb;
 subplot(6,1,1);
  ppg = [ppg, ch_1_16_bit_data];
  
  sppg = size(ppg);
  st = size(T);
   %st(2)
   %sppg(2)

  plot(T,ppg);
  title ('Photoplethysmography')
  grid
  drawnow
   if (sppg(2)>1000)
      ppg = ppg(51:end);
      T = T(51:end);
   end
  add_T = (T(end)+step:step:T(end)+(50*step));
   T = [T, add_T];


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

packet_received = 1;
%disp(ch_1_16_bit_data);
end