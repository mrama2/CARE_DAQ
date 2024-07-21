global ppg;
global ppg_for_bp;
global packet_received;
global sbp_net;
global dbp_net;
global YPred_sbp;
global YPred_dbp;
global sbp;
global dbp;
global bp_calculated;
global T;
global ecg;
global eT;
global b;
global SAMPLE_WINDOW;
global ppg_text;
global sbp_text;
global dbp_text;
global ecg_text;
global ecg_text1;

ppg_text =[];
ecg_text =[];
ecg_text1 =[];
SAMPLE_WINDOW = 110;
bp_calculated =0;
T =0:0.005:(50-1)*0.005;
eT =0:0.005:(50-1)*0.005;
ppg =[];
ppg_for_bp= [];
ecg =[];
sbp =[];
dbp =[];
t = tcpclient("192.168.13.140",8080);
configureCallback(t,"byte",400,@readDataFcn);
b = fir1(96,[0.008 0.2 ]);

function readDataFcn(src, ~)
global ppg;
global ppg_for_bp;
global T;
global ecg;
global eT;
global b;
global SAMPLE_WINDOW;
global ppg_text;
global sbp_text;
global dbp_text;
global ecg_text;
global ecg_text1;
global sbp_net;
global dbp_net;
global YPred_sbp;
global YPred_dbp;
global sbp;
global dbp;
global bp_calculated;
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
ppg_for_bp = [ppg_for_bp, ch_1_16_bit_data];  

  sppg = size(ppg);
  sppg_for_bp = size(ppg_for_bp);
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
      if (bp_calculated == 1)
       txt = ['SBP: ' num2str(YPred_sbp(1)) ' mmHg'];
      if(isempty(sbp_text)== 0)
          delete(sbp_text);
      end
       sbp_text = annotation('textbox',[.9 .6 .1 .1], ...
      'String',txt,'EdgeColor','none');
       txt = ['DBP: ' num2str(YPred_dbp(1)) ' mmHg'];
       if(isempty(dbp_text)== 0)
          delete(dbp_text);
       end       
       dbp_text = annotation('textbox',[.9 .5 .1 .1], ...
      'String',txt,'EdgeColor','none');
       bp_calculated = 0;
      end

      drawnow;
      % delete(ppg_text);
      %text(T(500),4000,txt);
   end
  add_T = (T(end)+step:step:T(end)+(50*step));
   T = [T, add_T];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% To Find BP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (sppg_for_bp(2)>4800)

    %It gives 5000 points. So make it 4800
    ppg_for_bp =double(ppg_for_bp(1:4800));
       % Define the original sampling frequency
    fs_original = 200; % Hz
    
    % Define the target sampling frequency
    fs_target = 125; % Hz
    
    % Calculate the resampling factor
    resampling_factor = fs_target / fs_original;
    
    % Resample the signal using interpolation
    resampled_signal = resample(ppg_for_bp, 5, 8); % Resampling factor 5/4
    
    % Limit the resampled signal to 3000 points
    resampled_signal = resampled_signal(1:3000);
    
    % Normalize the resampled PPG signal amplitudes
    normalized_signal = (resampled_signal / max(resampled_signal)) * 3;
    
    % Define filter coefficients
    b = fir1(48,[0.008*pi 0.2*pi]);
    a = 1;
    
    % Apply the filter to the normalized signal
    filtered_signal = filter(b, a, normalized_signal);
    
    % Scale the filtered signal to the desired range [0, 3]
    scaled_filtered_signal = (filtered_signal - min(filtered_signal)) / (max(filtered_signal) - min(filtered_signal)) * 3;
    
    % Code for creating the scalogram for SBP
    signalLength = 3000;  % No of datapoints
    tempdir_sbp_scalogram = 'C:\Users\mrama\OneDrive\Desktop\ICMLDE_2024\esp32_daq\pc\matlab\daq\temp'; % Directory for saving SBP scalograms
    target_label_sbp = 120;
    s_sbp = filtered_signal;  % Filtered PPG signal for SBP
    fb_sbp = cwtfilterbank('SignalLength',signalLength,'VoicesPerOctave',12);
    cfs_sbp = abs(fb_sbp.wt(s_sbp));
    im_sbp = ind2rgb(im2uint8(rescale(cfs_sbp)), jet(128));
    imgLoc_sbp = fullfile(tempdir_sbp_scalogram, num2str(target_label_sbp));
    mkdir(imgLoc_sbp); % Create folder for the current label
    imFileName_sbp = strcat(char(num2str(target_label_sbp)), '_', num2str(1), '.jpg');
    imwrite(imresize(im_sbp, [224 224]), fullfile(imgLoc_sbp, imFileName_sbp));
    
    % Code for creating the scalogram for DBP
    tempdir_dbp_scalogram = 'C:\Users\mrama\OneDrive\Desktop\ICMLDE_2024\esp32_daq\pc\matlab\daq\temp'; % Directory for saving DBP scalograms
    target_label_dbp = 80;
    s_dbp = filtered_signal;  % Filtered PPG signal for DBP (using the same filtered signal as SBP for demonstration)
    fb_dbp = cwtfilterbank('SignalLength',signalLength,'VoicesPerOctave',12);
    cfs_dbp = abs(fb_dbp.wt(s_dbp));
    im_dbp = ind2rgb(im2uint8(rescale(cfs_dbp)), jet(128));
    imgLoc_dbp = fullfile(tempdir_dbp_scalogram, num2str(target_label_dbp));
    mkdir(imgLoc_dbp); % Create folder for the current label
    imFileName_dbp = strcat(char(num2str(target_label_dbp)), '_', num2str(1), '.jpg');
    imwrite(imresize(im_dbp, [224 224]), fullfile(imgLoc_dbp, imFileName_dbp));
    
    % Load SBP test images
    sbp_testImages = imageDatastore(tempdir_sbp_scalogram, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
    
    % Load DBP test images
    dbp_testImages = imageDatastore(tempdir_dbp_scalogram, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
    
    % Predict using trained models for both SBP and DBP
    %sbp_net
    [YPred_sbp] = predict(sbp_net, sbp_testImages)
    [YPred_dbp] = predict(dbp_net, dbp_testImages)
    sbp = [sbp, YPred_sbp(1)];
    dbp = [dbp, YPred_dbp(1)];
    bp_calculated = 1;
    ppg_for_bp = [];
end
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
      %diff(ecg_loc)
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