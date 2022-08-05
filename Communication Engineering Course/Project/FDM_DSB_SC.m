clear all;
clc;
close all;
pkg load signal

function plot_signal(x_axis, y_axis, graph_title, x_label, y_label)
  figure;
  plot(x_axis,y_axis);
  title(graph_title)
  xlabel(x_label)
  ylabel(y_label)
endfunction

function ym = modulate_signal(x, t, Fc)
  ym = (x)' .* cos(2 * pi * Fc * t);
endfunction

  
function yl = lpf(x, BW, Fs, order)
  [b, a] = butter(order, (BW/2)/(Fs/2));
  yl = filter(b, a, x);  
endfunction

function yb = bpf(x, BW, Fs, Fc, order)
  [b, a] = butter(order, [Fc - BW/2, Fc + BW/2] / (Fs / 2));
  yb = 2 * filter(b, a, x);  
endfunction  

# Read audio signals
[m1, Fs] = audioread('audio_file_1.wav');
m1 = resample(m1(:,1), 4, 1);

[m2, Fs] = audioread('audio_file_2.wav');
m2 = resample(m2(:,1), 4, 1);

[m3, Fs] = audioread('audio_file_3.wav');
m3 = resample(m3(:,1), 4, 1);

# Pad audio signals so that they have the same size
max_length = max([length(m1) length(m2) length(m3)]);
m1 = [m1; zeros(max_length - length(m1), 1)];
m2 = [m2; zeros(max_length - length(m2), 1)];
m3 = [m3; zeros(max_length - length(m3), 1)];
Fs = 4 * Fs;

t = linspace(0, max_length/Fs, max_length);
f = linspace(-Fs/2, Fs/2, max_length);
BW = 10 * 10^3;
Fc1 = 12 * 10^3;
Fc2 = Fc1 + 3 * BW;
Fc3 = Fc2 + 3 * BW;

plot_signal(f, abs(fftshift(fft(m1))), 'Audio 1 Original Spectrum', 'Frequency', 'Amplitude');
plot_signal(f, abs(fftshift(fft(m2))), 'Audio 2 Original Spectrum', 'Frequency', 'Amplitude');
plot_signal(f, abs(fftshift(fft(m3))), 'Audio 3 Original Spectrum', 'Frequency', 'Amplitude');

# Modulated transmitted signal
s = modulate_signal(m1, t, Fc1) + modulate_signal(m2, t, Fc2) + modulate_signal(m3, t, Fc3);
plot_signal(t, s, 'Modulated Signal in Time Domain', 'Time', 'Amplitude');
S = abs(fftshift(fft(s)));
plot_signal(f, S, 'Modulated Signal in Frequency Domain', 'Frequency', 'Amplitude');

# Apply bandpass filter to the modulated signal
m1b = bpf(s, BW, Fs, Fc1, 5);
plot_signal(f, abs(fftshift(fft(m1b))), 'Applying BPF to Audio 1', 'Frequency', 'Amplitude');
m2b = bpf(s, BW, Fs, Fc2, 5);
plot_signal(f, abs(fftshift(fft(m2b))), 'Applying BPF to Audio 2', 'Frequency', 'Amplitude');
m3b = bpf(s, BW, Fs, Fc3, 5);
plot_signal(f, abs(fftshift(fft(m3b))), 'Applying BPF to Audio 3', 'Frequency', 'Amplitude');

# Demodulation
m1d = m1b .* cos(2 * pi * Fc1 * t);
m2d = m2b .* cos(2 * pi * Fc2 * t);
m3d = m3b .* cos(2 * pi * Fc3 * t);

# Apply lowpass filter
m1f = 1.25 * lpf((m1d)', BW, Fs, 5); 
m2f = lpf((m2d)', BW, Fs, 5); 
m3f = lpf((m3d)', BW, Fs, 5);
plot_signal(f, abs(fftshift(fft(m1f))), 'Audio 1 Demodulated Spectrum', 'Frequency', 'Amplitude');
plot_signal(f, abs(fftshift(fft(m2f))), 'Audio 2 Demodulated Spectrum', 'Frequency', 'Amplitude');
plot_signal(f, abs(fftshift(fft(m3f))), 'Audio 3 Demodulated Spectrum', 'Frequency', 'Amplitude');

# Demodulation with phase difference
phi = [deg2rad(10), deg2rad(30), deg2rad(90)];
for i = 1 : 3, m2d = m2b .* cos(2 * pi * Fc2 * t + phi(i));, m2f = lpf((m2d)', BW, Fs, 5);,plot_signal(f, abs(fftshift(fft(m2f))), 'Demodulation with Phase Shift', 'Frequency', 'Amplitude'),; endfor 

# Demodulation with phase difference
freq_shift = [2, 10];
for i = 1 : 2, m2d = m2b .* cos(2 * pi * (Fc2 + freq_shift(i)) * t);, m2f = lpf((m2d)', BW, Fs, 5);,plot_signal(f, abs(fftshift(fft(m2f))), 'Demodulation with Frequency Shift', 'Frequency', 'Amplitude'),; endfor 