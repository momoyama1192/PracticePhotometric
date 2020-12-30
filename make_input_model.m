%% 画像の設定
N_ROW = 128; % 画像の行（縦方向）の数
N_COL = 128; % 画像の列（横方向）の数
pic_num = 10; % 作成する画像の数

%% 球の設定
radius = 48; % 球の半径
kyu_x  = 64; % 中心のx座標
kyu_y  = 64; % 中心のy座標
K_d    = 0.8;  % 球の拡散反射率

%% 出力情報
OUTPUT_DIR = "input"; % 球を出力するディレクトリ

% 設定ここまで

%% 各種初期化
sn_true = zeros(N_ROW,N_COL,3); 
S = zeros(pic_num,3);

%% 球の作成
for i = 1:N_ROW
   for j = 1:N_COL
       if (i - kyu_x) ^ 2 + (j - kyu_y) ^ 2 <= radius ^ 2
            k = sqrt(radius ^ 2 - (i - kyu_x) ^ 2 - (j - kyu_y) ^ 2);
            sn_tmp =  [i - kyu_x, j - kyu_y , k]';
            sn_tmp = sn_tmp / norm(sn_tmp);
            sn_true(i,j,:) = sn_tmp;
       end
   end
end

% check_sn = uint8((sn + 1) * 255 / 2);
% imwrite(check_sn,"true_hosen.ppm");

%% 球の作成 (ランバートと仮定)
img_output = zeros(N_ROW,N_COL);

for a = 1:pic_num
    light = [rand()-0.5, rand()-0.5, rand() / 2]';
    light = light / norm(light); % 光源ベクトル正規化
    img_output = zeros(N_ROW,N_COL);
    for i = 1:N_ROW
       for j = 1:N_COL
           sn_tmp = [sn_true(i,j,1) sn_true(i,j,2) sn_true(i,j,3)]';
           if norm(sn_tmp) > 0
               cos_theta = dot(light,sn_tmp);
               if cos_theta > 0
                   img_output(i,j) = K_d * cos_theta;
               end
           end
       end
    end
    S(a,:) = light;
    imwrite(img_output,strcat(OUTPUT_DIR,'/',num2str(a),'.pgm'));
end

save(strcat(OUTPUT_DIR,'/light_source.txt'),'S','-ascii');
save(strcat(OUTPUT_DIR,'/sn_true.mat'),'sn');