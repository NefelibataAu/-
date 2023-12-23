clear; 
close all;
clc;

%% ���ݳ�ʼ��
M = 8;                                    % ��Ԫ��
N = 100;                                  % ������
NN = 1000;
theta_grid = linspace(-90, 90, NN);       % �����ĽǶ�
lamd = 2;                                 % ����
d = lamd / 2;                             % ��λ���
Array = (0 : M -1) * d;                   % ���нṹ
F = zeros(1, NN);                         % ��ʼ������ͼ
 
theta = 0;
theta_dst1 = -60;
theta_dst2 = 50;
SNR = 0;
SNR_dst1 = 40;
SNR_dst2 = 20;
f = 0.15;
f_dst1 = 0.1;
f_dst2 = 0.2;

%%  �����ź�������ź�
sigma_square = 1;
noise = sqrt(sigma_square / 2) * (randn(M, N) + 1i *randn(M, N));
amp = sqrt(sigma_square *10^(SNR / 10));
amp_dst1 = sqrt(sigma_square *10^(SNR_dst1 / 10));
amp_dst2 = sqrt(sigma_square *10^(SNR_dst2 / 10));

signal = amp * exp(1i * 2 * pi * f * (0 : N - 1) + 1i * 2 * pi * rand);   % �����ź�
signal_dst1 = amp_dst1 * exp(1i * 2 * pi * f_dst1 * (0 : N - 1) + 1i * 2 * pi * rand); % �����ź�1
signal_dst2 = amp_dst2 * exp(1i * 2 * pi * f_dst2 * (0 : N - 1) + 1i * 2 * pi * rand); % �����ź�2

%%  ���н����ź�
a = exp(-1i * 2 * pi * (0 : M - 1) *d * sin(theta * pi / 180) /lamd).';
a_dst1 = exp(-1i * 2 * pi * (0 : M - 1) *d * sin(theta_dst1 * pi / 180) /lamd).';
a_dst2 = exp(-1i * 2 * pi * (0 : M - 1) *d * sin(theta_dst2 * pi / 180) /lamd).';

x = a * signal + a_dst1 * signal_dst1 + a_dst2 * signal_dst2 + noise;

%% MVDR �㷨��������Ȩ����
R = x * x' /N;
w = inv(R) * a / (a' * inv(R) * a);

%% ���㷽��ͼ����ͼ
for k = 1 : NN
    a_grid = exp(-1i * 2 * pi * (0 : M - 1) * d * sin(theta_grid(k) * pi / 180) / lamd).';
    F(k) = abs(w' * a_grid);
end

F = F / max(F);                       % ��һ������ͼ
F_dB = 20 * log10(F);                 % ȡ����

figure;
plot(theta_grid, F_dB);
xlim([-90 90]);
xlabel('DOA/degree');
ylabel('��һ������ͼ/dB');
title('MVDR�㷨');

