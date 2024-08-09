clc;clear;close all;

image = imread('Slanted Edge MTF.bmp');
image = double(rgb2gray(image));
image = imgaussfilt(image, 4);% 模糊处理
% figure,imshow(image);
[rows, cols] = size(image);

% 对每一行进行三次样条插值
new_cols = 2 * cols;
interp_image = zeros(rows, new_cols);
for i = 1:rows
    x = 1:cols; 
    y = double(image(i, :)); 
    
    xq = linspace(1, cols, new_cols); % 插值后的列索引
    interp_image(i, :) = interp1(x, y, xq, 'spline'); % 三次样条插值
end
interp_image = uint8(interp_image);

% 边缘点检测，并记录其坐标
image_edge = edge(interp_image,"prewitt");
% figure,imshow(image_edge);
edgePoints_row = [];
edgePoints_col = [];
for i = 1: rows
    for j = 1:new_cols
        if image_edge(i,j)==1
            edgePoints_row(end + 1) = i;
            edgePoints_col(end + 1) = j;
            break
        end
    end
end
clear i j

% 以边缘点为中心，将每行前25个和后25个灰度值绘制ESF曲线
figure,
hold on
for i = 50:149 % 取中间100行，避免前后25个灰度值超出索引范围
    curveLine = interp_image(i, edgePoints_col(i)-25 : edgePoints_col(i)+25);
    plot(1:51, curveLine);
end
hold off
clear i

% 将曲线取平均
ESF_matrix = zeros(100, 51);
for i = 1:100
    ESF_matrix(i, :) = interp_image(i+49, edgePoints_col(i+49)-25 : edgePoints_col(i+49)+25);
end
clear i
ESF_mean = mean(ESF_matrix,1);
figure,plot(1:51, ESF_mean),title('ESF');

% 对ESF_mean求导
LSF = diff(double(ESF_mean));
LSF = [0, LSF];
LSF = smooth(1:51, LSF, 0.1,'loess'); %平滑处理
figure, plot(1:51, LSF),title('LSF');

% 对LSF做傅里叶变换
MTF = abs(fftshift(fft2(LSF)));
MTF = MTF / max(MTF(:));
MTF = MTF(26:end, 1)';
figure, plot(linspace(0,1,4), MTF(1,1:4)),title('MTF');% 已截止频率进行归一化








