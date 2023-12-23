clear;
close all;
clc

%%  ���ݳ�ʼ��
M = 8;                         % ��Ԫ��
lamd = 2;                       % ����
d = lamd / 2;                   % ��λ��� 
Array = (0 : d : M - 1);        % ���нṹ
DOA = 10;                 % �ź������
K = length(DOA);
SNR_dB = 20;               % ����ȣ���λ:dB
N =1000;                         % ������
noise_power  = 1;               % ��������
amp = sqrt(noise_power * 10 .^(SNR_dB / 10));      % �źŷ�ֵ     
A = zeros(M, K);              
step = 0.01;                    % �������Ĳ���
DOA_grid = (-90 : step : 90);   % �Ƕ�����
P_MUSIC = zeros(1, length(DOA_grid));
W = zeros(M, M);

%%  ���������źž���
S = diag(amp) / sqrt(2) * ( randn(K, N) + 1i * randn(K, N) );  % �źž���
V = sqrt(noise_power / 2) * ( randn(M, N) + 1i * randn(M, N));
for k = 1 : K                   % ���㷽�����
    A(:, k) = exp(-1i * (0 : M - 1) * 2 * pi * d * ...
    sin(DOA(k) * pi / 180) / lamd);
end
X = A * S + V;                   % �����źž���

%% ��һ�������γɾ���
B = M;
m = 0;
aa = exp(- 1i * pi);
for k = 0 : M - 1
    W(:, k + 1) = aa .^((0 : M - 1) * k * (2 / M));
end
T = 1 / sqrt(M) * W(:, m + 1 : m + B);

%%  �ڲ����ռ�Ӧ��MUSIC�㷨ʵ��DOA����
y = T' * X;
R = y * y' / N;
[V, D] = eig(R);
[Y, I] = sort(diag(D));
G = V(:, I(B - K : -1 : 1));

for m = 1 : length(DOA_grid) 
    a1 = exp(-1i * (0 : M - 1) * 2 * pi * d * ...
        sin(DOA_grid(m) * pi / 180) / lamd).';
    a2 = T' * a1;
    P_MUSIC(m) = 1 / (a2' * G * G' * a2);
end

%% ����MUSIC��ͼ
P_MUSIC =  abs(P_MUSIC) / max(abs(P_MUSIC));      % ��һ��MUSIC��
P_MUSIC_dB = 10 * log10(P_MUSIC);
figure;
plot(DOA_grid , P_MUSIC_dB);
set(gca, 'XTick', (-90 : 10 : 90));
xlim([-90 90]);
xlabel('DOA/degree');
ylabel('��һ��MUSIC��/dB');
title('�ڲ����ռ�Ӧ��MUSIC�㷨ʵ��DOA����');

