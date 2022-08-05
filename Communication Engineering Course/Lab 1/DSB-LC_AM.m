function plot_signal(x_axis, y_axis, graph_title, x_label, y_label)
  figure;
  plot(x_axis,y_axis);
  title(graph_title)
  xlabel(x_label)
  ylabel(y_label)
endfunction

[temp,Fs] = wavread('audio_file.wav');
x = temp(:,1);

# Audio Signal in Time Domain
t = linspace(0, length(x)/Fs, length(x));
plot_signal(t, x, 'Time Domain', 'Time', 'Audio Signal');
#################################################################

# Audio Signal in Frequency Domain
f = linspace(-Fs/2, Fs/2, length(x));
X = fft(x, length(x));
#################################################################

# Amplitude of Audio Signal in Frequency Domain
amplitude_X = abs(X);
plot_signal(f(1:length(x)),amplitude_X(1:length(x)),'Frequency Domain', 'Frequency', 'Signal Amplitude');
#################################################################

# Phase of Audio Signal in Frequency Domain
phase_X = angle(X);
plot_signal(f(1:length(x)), phase_X(1:length(x)), 'Frequency Domain', 'Frequency', 'Signal Phase');
#################################################################

# Modulated Signal in Time Domain (Modulation Process)
u = 0.5
Ac = max(abs(x)) / u
Fc = Fs
y = (x + Ac) .* transpose(cos(2 * Fc * t));
plot_signal(t, y, 'Time Domain', 'Time', 'Modulated Signal');
#################################################################

# Amplitude of Modulated Signal in Frequency Domain
Y = fft(y, length(x));
amplitude_Y = abs(Y);
plot_signal(f(1:length(x)),amplitude_Y(1:length(x)), 'Frequency Domain', 'Frequency', 'Modulated Signal Amplitude');
#################################################################

# Phase of Modulated Signal in Frequency Domain
phase_Y = angle(Y);
plot_signal(f(1:length(x)),phase_Y(1:length(x)), 'Frequency Domain', 'Frequency', 'Modulated Signal Phase');
#################################################################

# Demodulation Process
pkg load signal 
e = y .* transpose(cos(2 * Fc * t));
order = 25;
lpf_cutoff_frequency = 0.5;
[b,a] = butter(order, lpf_cutoff_frequency); 
e = filter(b, a, e);
e = (2 * e) - Ac;
audiowrite('demod_file.wav', e, Fs);
plot_signal(t, e, 'Time Domain', 'Time', 'Demodulated Audio Signal');
#################################################################

# Demodulated Signal in Frequency Domain
E = fft(e, length(x));
#################################################################

# Amplitude of Audio Signal in Frequency Domain
amplitude_E = abs(E);
plot_signal(f(1:length(x)),amplitude_E(1:length(x)),'Frequency Domain', 'Frequency', 'Demodulated Signal Amplitude');
#################################################################

# Phase of Audio Signal in Frequency Domain
phase_E = angle(E);
plot_signal(f(1:length(x)),phase_X(1:length(x)),'Frequency Domain', 'Frequency', 'Demodulated Signal Phase');
#################################################################