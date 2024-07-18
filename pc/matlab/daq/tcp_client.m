global ppg;
global packet_received;
global T;
global ecg;
global eT;
global b;
global SAMPLE_WINDOW;
global ppg_text;
global ecg_text;
global ecg_text1;

ppg_text =[];
ecg_text =[];
ecg_text1 =[];
SAMPLE_WINDOW = 110;

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
global SAMPLE_WINDOW;
global ppg_text;
global ecg_text;
global ecg_text1;
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
  if (sppg(2)<=1000)
    drawnow
  end
   if (sppg(2)>1000)
      ppg = ppg(51:end);
      T = T(51:end);
      [ppg_pks,ppg_loc]= findpeaks(double(ppg),'MinPeakDistance',SAMPLE_WINDOW);
      Pulse_per_5sec = size(ppg_loc);
      HR =  abs(Pulse_per_5sec(2).*12);
      txt = ['HeartRate: ' num2str(HR) ' BPM'];
      %delete(findall(gcf,'Tag','stream'));
      if(isempty(ppg_text)== 0)
          delete(ppg_text);
      end
      ppg_text = annotation('textbox',[.9 .7 .1 .1], ...
      'String',txt,'EdgeColor','none');
      drawnow;
      % delete(ppg_text);
      %text(T(500),4000,txt);
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
  if (secg(2)<=1000)
    drawnow
  end
   if (secg(2)>1000)
      ecg = ecg(51:end);
      eT = eT(51:end);
      [ecg_pks,ecg_loc]= findpeaks(double(ecg),'MinPeakDistance',SAMPLE_WINDOW);
      ePulse_per_5sec = size(ecg_loc);
      eHR =  abs(ePulse_per_5sec(2).*12);
      txt = ['HeartRate: ' num2str(eHR) ' BPM'];
      %delete(findall(gcf,'Tag','stream'));
      if(isempty(ecg_text1)== 0)
          delete(ecg_text1);
      end
      if(isempty(ecg_text)== 0)
          delete(ecg_text);
      end
      ecg_text1 = annotation('textbox',[.9 .2 .1 .1], ...
      'String',txt,'EdgeColor','none');
      %text(eT(500),4200,txt);
      diff(ecg_loc)
      txt = ['R-R: ' num2str((mean(diff(ecg_loc))*0.005)) ' Seconds'];
      ecg_text = annotation('textbox',[.9 .1 .1 .1], ...
      'String',txt,'EdgeColor','none');
      drawnow
      %delete(ecg_text);
      %text(eT(500),4000,txt);
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