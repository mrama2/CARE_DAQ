global ppg;
global packet_received;
global T;
global ecg;
global eT;
global b;
T =0:0.005:(50-1)*0.005;
eT =0:0.005:(50-1)*0.005;
ppg =[];
ecg =[];
t = tcpclient("192.168.13.140",8080);
configureCallback(t,"byte",400,@readDataFcn);
b = fir1(96,[0.008 0.2 ]);

function readDataFcn(src, ~)
global ppg;
global T;
global ecg;
global eT;
global b;
a =1;
sampling_freq = 200;
step = 1/sampling_freq;
src.UserData = read(src,src.BytesAvailableFcnCount,"uint8");
ch_1_data = src.UserData(1:100);
ch_1_data_lsb = uint16(ch_1_data(1:2:100));
ch_1_data_msb = (uint16(ch_1_data(2:2:100)) .* 256);
ch_1_16_bit_data = ch_1_data_msb + ch_1_data_lsb;
%ch_1_16_bit_data1 = filter(b,a,ch_1_16_bit_data);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dynamic PPG Plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,1,1);
  ppg = [ppg, ch_1_16_bit_data];


  sppg = size(ppg);
  plot(T,ppg);
  xlabel('Time(S)')
  ylabel('ADC Output')
  %title ('ElectroCardiography')
  title ('Photoplethysmography')
  grid
  drawnow
   if (sppg(2)>1000)
      ppg = ppg(51:end);
      T = T(51:end);
   end
  add_T = (T(end)+step:step:T(end)+(50*step));
   T = [T, add_T];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ch_2_data = src.UserData(101:200);
ch_2_data_lsb = uint16(ch_2_data(1:2:100));
ch_2_data_msb = (uint16(ch_2_data(2:2:100)) .* 256);
ch_2_16_bit_data = ch_2_data_msb + ch_2_data_lsb;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dynamic ECG Plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,1,2);
  ecg = [ecg, ch_2_16_bit_data];
  secg = size(ecg);
  plot(eT,ecg);
  xlabel('Time(S)')
  ylabel('ADC Output')
  %title ('Photoplethysmography')
  title ('ElectroCardiography')
  grid
  drawnow
   if (secg(2)>1000)
      ecg = ecg(51:end);
      eT = eT(51:end);
   end
 add_eT = (eT(end)+step:step:eT(end)+(50*step));
 eT = [eT, add_eT];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


ch_3_data = src.UserData(201:300);
ch_3_data_lsb = uint16(ch_3_data(1:2:100));
ch_3_data_msb = (uint16(ch_3_data(2:2:100)) .* 256);
ch_3_16_bit_data = ch_3_data_msb + ch_3_data_lsb;

ch_4_data = src.UserData(301:400);
ch_4_data_lsb = uint16(ch_4_data(1:2:100));
ch_4_data_msb = (uint16(ch_4_data(2:2:100)) .* 256);
ch_4_16_bit_data = ch_4_data_msb + ch_4_data_lsb;

packet_received = 1;
%disp(ch_1_16_bit_data);
end