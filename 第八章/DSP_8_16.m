clear;
close all;
clc

%%  ���ݳ�ʼ��
M = 10;                         % ��Ԫ��
lamd = 2;                       % ����
d = lamd / 2;                   % ��λ��� 
Array = (0 : d : M - 1);        % ���нṹ
DOA = [-10 40];                 % �ź������
K = length(DOA);
SNR_dB = [10 20];               % ����ȣ���λ:dB
N =100;                         % ������
noise_power  = 1;               % ��������
amp = sqrt(noise_power * 10 .^(SNR_dB / 10));      % �źŷ�ֵ     
A = zeros(M, K);              
step = 0.01;                    % �������Ĳ���
DOA_grid = (-90 : step : 90);   % �Ƕ�����
P_MUSIC = zeros(1, length(DOA_grid));
P_MVDR = zeros(1, length(DOA_grid));
DOA_RootMUSIC = zeros(1, K);
DOA_ESPRIT = zeros(1, K);

%%  ���������źž���
S = diag(amp) / sqrt(2) * ( randn(K, N) + 1i * randn(K, N) );  % �źž���
V = sqrt(noise_power / 2) * ( randn(M, N) + 1i * randn(M, N));
for k = 1 : K                   % ���㷽�����
    A(:, k) = exp(-1i * (0 : M - 1) * 2 * pi * d * ...
    sin(DOA(k) * pi / 180) / lamd);
end
X = A * S + V;                   % �����źž���

%%  (1)MUSIC �㷨����DOA
R = X * X' / N;
[V, D] = eig(R);
[Y, I] = sort(diag(D), 'descend');
G = V(:, I(K + 1 : end));                       % �����ӿռ�

for m = 1 : length(DOA_grid) 
    a = exp(-1i * (0 : M - 1) * 2 * pi * d * ...
        sin(DOA_grid(m) * pi / 180) / lamd).';
    P_MUSIC(m) = 1 / (a' * G * G' * a);
end

% ����MUSIC��ͼ
P_MUSIC =  abs(P_MUSIC) / max(abs(P_MUSIC));      % ��һ��MUSIC��
P_MUSIC_dB = 10 * log10(P_MUSIC);
figure;
plot(DOA_grid , P_MUSIC_dB);
set(gca, 'XTick', (-90 : 10 : 90));
xlim([-90 90]);
xlabel('DOA/degree');
ylabel('��һ��MUSIC��/dB');
title('MUSIC�㷨�����ź�DOA');

%%  (2)Root-MUSIC �㷨����DOA
syms z;
a_zz = z .^(0 : M -1);
a_z = z .^(-(0 : M -1)).'; 
P_RootMUSIC = a_zz * G * G' * a_z;          % �������ʽ

z_root = roots(sym2poly(z .^(M - 1) * P_RootMUSIC));   % ���
[t, Index] = sort(abs(abs(z_root) - 1));
for k = 1 : K
    DOA_RootMUSIC(k) = asin(angle(z_root(Index(2 * k - 1))) ...
        * lamd / (2 * pi * d)) * 180 / pi;
end

disp('Root-MUSIC�㷨, DOA:');
sort(DOA_RootMUSIC)

%%  (3)ESPRIT �㷨����DOA
S = V(:, I(1 : K));                    % �ź��ӿռ�
S1 = S(1 : M - 1, :);
S2 = S(2 : M, :);
fai = S1 \ S2;

[~, D_fai] = eig(fai);
D_fai = diag(D_fai);
for k = 1 : K
    DOA_ESPRIT(k) = asin(-angle(D_fai(k)) * lamd / (2 * pi * d)) * 180 / pi;
end

disp('ESPRIT�㷨, DOA:');
sort(DOA_ESPRIT)

%% (4)MVDR �㷨����DOA

for m = 1 : length(DOA_grid) 
    a = exp(-1i * (0 : M - 1) * 2 * pi * d * ...
        sin(DOA_grid(m) * pi / 180) / lamd).';
    P_MVDR(m) = 1 / (a' * inv(R) * a);
end

% ����MVDR��ͼ
P_MVDR =  abs(P_MVDR) / max(abs(P_MVDR));      % ��һ��MUSIC��
P_MVDR_dB = 10 * log10(P_MVDR);
figure;
plot(DOA_grid , P_MVDR_dB);
set(gca, 'XTick', (-90 : 10 : 90));
xlim([-90 90]);
xlabel('DOA/degree');
ylabel('��һ��MVDR��/dB');
title('MVDR�㷨�����ź�DOA');

%% (5)F-SAPES �㷨����DOA
P = 6;                               
L = M + 1 - P;                       
Rf = zeros(L, L);
for i = 1 : P
    Rf = Rf + X(i : i + L -1, :) * X (i : i + L - 1, :)' / N;
end
Rf = Rf / P;                        
n1 = 0 : P - 1;
n2 = 0 : L - 1;
cc = [1 zeros(1, L - 1)];
for n3 = -90 : 0.5 : 90
    fy = exp(1i * pi * sin(n3 / 180 * pi));
    tt = [(fy .^(n1')).' zeros(1, M - P)];
    Tfy = toeplitz(cc, tt);            
    GfTheta = 1 ./ (P ^2) * Tfy * R * Tfy'; 
    Qf = Rf - GfTheta;                      
    aTheta = fy .^(-n2');
    Wof = ((inv(Qf)) * aTheta) ./ (aTheta' * inv(Qf) * aTheta); 
    sigma2sTheta(((n3 + 90) / .5 + 1)) = Wof' * GfTheta * Wof;
end

figure;
sigma2sTheta = abs(sigma2sTheta) / max(abs(sigma2sTheta));
sigma2sTheta_dB = 10 * log10(sigma2sTheta);
x_angle = linspace(-90 , 90, length(sigma2sTheta));
plot(x_angle, sigma2sTheta_dB);
xlim([-90 90]);
set(gca, 'XTick', -90 : 10 : 90);
xlabel('DOA/degree');
ylabel('��һ��F-SAPES��/dB');
title('F-SAPES�㷨�����ź�DOA');

