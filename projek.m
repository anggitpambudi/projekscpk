%Proses membaca data latih dari excel
filename = 'curahujan.xlsx';
sheet = 1;
xlRange = 'D21:P32';%data latih

Data = xlsread(filename,sheet,xlRange);
data_latih = Data(:,1:12)';
target_latih = Data(:,13)';
[m,n] = size(data_latih);

%Pembuatan JST
net = newff(minmax(data_latih),[10 1],{'logsig','purelin'},'traingdx');

% Memberikan nilai untuk mempengaruhi proses pelatihan
net.performFcn = 'mse';
net.trainParam.goal = 0.001;
net.trainParam.show = 20;
net.trainParam.epochs = 1000;
net.trainParam.mc = 0.95;
net.trainParam.lr = 0.1;
 
% Proses training
[net_keluaran,tr,Y,E] = train(net,data_latih,target_latih);
 
% Hasil setelah pelatihan
bobot_hidden = net_keluaran.IW{1,1};
bobot_keluaran = net_keluaran.LW{2,1};
bias_hidden = net_keluaran.b{1,1};
bias_keluaran = net_keluaran.b{2,1};
jumlah_iterasi = tr.num_epochs;
nilai_keluaran = Y;
nilai_error = E;
error_MSE = (1/n)*sum(nilai_error.^2);
 
save net.mat net_keluaran
 
% Hasil prediksi-
hasil_latih = sim(net_keluaran,data_latih);
max_data = 2590;
min_data = 0;

%mengubah data agar kembali ke bentuk data semula(tidak normalisasi)
hasil_latih = ((hasil_latih-0.1)*(max_data-min_data)/0.8)+min_data;

% Performansi hasil prediksi
filename = 'curahujan.xlsx';
sheet = 1;
xlRange = 'E6:P6';
 
target_latih_asli = xlsread(filename, sheet, xlRange);

%grafik keluaran jst-
figure,
plotregression(target_latih_asli,hasil_latih,'Regression')
 
figure,
plotperform(tr)
 
figure,
plot(hasil_latih,'bo-')
hold on
plot(target_latih_asli,'ro-')
hold off
grid on
title(strcat(['Grafik Keluaran JST vs Target dengan nilai MSE = ',...
num2str(error_MSE)]))
xlabel('Pola ke-')
ylabel('Curah Hujan')
legend('Keluaran JST','Target','Location','Best')

% load jaringan yang sudah dibuat pada proses pelatihan
load net.mat
 
% Proses membaca data uji dari excel
filename = 'curahujan.xlsx';
sheet = 1;
xlRange = 'D39:P50';
 
Data = xlsread(filename, sheet, xlRange);
data_uji = Data(:,1:12)';
target_uji = Data(:,13)';
[m,n] = size(data_uji);
 
% Hasil prediksi
hasil_uji = sim(net_keluaran,data_uji);
nilai_error = hasil_uji-target_uji;
 
max_data = 2590;
min_data = 0;

%merubah ke bentuk semula(tidak normalisasi)
hasil_uji = ((hasil_uji-0.1)*(max_data-min_data)/0.8)+min_data;
 
% Performansi hasil prediksi
error_MSE = (1/n)*sum(nilai_error.^2);
 
filename = 'curahujan.xlsx';
sheet = 1;
xlRange = 'E7:P7';
 
target_uji_asli = xlsread(filename, sheet, xlRange);
 
figure,
plot(hasil_uji,'bo-')
hold on
plot(target_uji_asli,'ro-')
hold off
grid on
title(strcat(['Grafik Keluaran JST vs Target dengan nilai MSE = ',...
num2str(error_MSE)]))
xlabel('Pola ke-')
ylabel('Curah Hujan')
legend('Keluaran JST','Target','Location','Best')