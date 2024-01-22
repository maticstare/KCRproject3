%Author: Matic Stare

%baseline eyes open: S020R01.edf
%baseline eyes closed: S020R02.edf
%task1: S020R03.edf
%task1: S020R07.edf
%task1: S020R11.edf
n_of_freq_bands = 10;

[baselineOpen, tm] = read_data('eegmmidb/S020/S020R01.edf');
%[baselineClosed, tm] = read_data('eegmmidb/S020/S020R02.edf');
[task11, ~] = read_data('eegmmidb/S020/S020R03.edf');
[task12, ~] = read_data('eegmmidb/S020/S020R07.edf');
[task13, ~] = read_data('eegmmidb/S020/S020R11.edf');

size_of_baseline = size(baselineOpen, 1);

task = zeros(size_of_baseline, 64, 3);
task(:, :, 1) = task11(1:size_of_baseline, :);
task(:, :, 2) = task12(1:size_of_baseline, :);
task(:, :, 3) = task13(1:size_of_baseline, :);

mean_of_task = mean(task, 3);

freq_bands_of_task = split_freq_bands(mean_of_task, n_of_freq_bands);

r_squared = zeros(64, n_of_freq_bands);
for i = 1:64
    for j = 1:n_of_freq_bands
        r_squared(i, j) = r2(baselineOpen(:, i), freq_bands_of_task(:, i, j));
    end
end

figure
heatmap(r_squared);
title('Mape značilk na osnovi kriterija R kvadrat')
xlabel('Frekvenčni pas')
ylabel('Kanal elektrode')

figure
plot(tm, freq_bands_of_task(:, 64, 10).^2);
title('Moč signala 64. kanala 10. frekvenčnega pasu v odvisnosti od časa')
xlabel('Čas')
ylabel('Moč signala')


%functions
function [sigs, tm] = read_data(path)
    [sigs,~,tm] = rdsamp(path);
    sigs = sigs(:, 1:64);
end

function out = split_freq_bands(sigs, n_of_bands)
    len_of_sigs = size(sigs, 1);
    size_of_each_band = round(len_of_sigs / n_of_bands);
    fourier = fft(sigs);
    freq_split = zeros(len_of_sigs, 64, n_of_bands);

    for i = 1 : n_of_bands
        firstI = (i-1) * size_of_each_band + 1;
        lastI = firstI + size_of_each_band - 1;
        freq_split(firstI:lastI, :, i) = fourier(firstI:lastI, :);
    end

    out = zeros(len_of_sigs, 64, n_of_bands);
    for i = 1 : n_of_bands
        out(:, :, i) = ifft(freq_split(:, :, i));
    end
    out = real(out);
end

function out = r2(x, y)
    lin_model = fitlm(x, y);
    out = lin_model.Rsquared.Ordinary;
end
