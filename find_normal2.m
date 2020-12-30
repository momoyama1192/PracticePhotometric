% 設定ここから

%% 画像設定 (make_input_model.pyの設定と同じにすること)
N_ROW  = 256;  % 画像の行（縦方向）の数
N_COL  = 256;  % 画像の列（横方向）の数
pic_num = 15;  % 作成した画像の数

%% 入力ディレクトリ (最後の / は不要)
INPUT_DIR = "input";

%% 出力先ディレクトリ (最後の / は不要)
OUTPUT_DIR = "output";

% S = importdata(strcat(INPUT_DIR,'/light_source.txt'));
%S = a;
img_pixel_value = zeros(N_ROW,N_COL,pic_num);

sn_es = zeros(N_ROW,N_COL,3);

%% 画像読み込み
for a = 1:pic_num
    LOAD_IMG = strcat(INPUT_DIR,'/save_gazo_hishatai',num2str(a),'.png');
    img_pixel_value(:,:,a) = imread(LOAD_IMG);
end

%% 法線推定
for i = 1:N_ROW
   for j = 1:N_COL
      intensity = reshape(img_pixel_value(i,j,:),[pic_num,1]);
      non_zero_index = find(intensity > 0); % 輝度が0じゃないindexについて
      
      intensity_n0 = intensity(non_zero_index);
      S_n0 = S(non_zero_index,:);
      if numel(intensity_n0) >= 3
          sn_tmp = pinv(S_n0) * intensity_n0;
      else
          sn_tmp = pinv(S) * intensity; % 有効な光源数なくてもとりあえず求める
      end
 
      if norm(sn_tmp) > 0
         sn_tmp = sn_tmp / norm(sn_tmp); 
      end
      sn_es(i,j,:) = sn_tmp;
   end
end

%% 誤差の評価
% 画像による確認 (定性的評価)
check_sn = (sn_es + 1) / 2;
imwrite(check_sn,strcat(OUTPUT_DIR,'/result2.ppm'));

% 数値による確認 (定量的評価)
error_sn = zeros(N_ROW,N_COL);
load(strcat(INPUT_DIR,'/sn_true.mat'));

count_pixel = 0;
sum_error = 0;

for i = 1:N_ROW
   for j = 1:N_COL
       sn_true_tmp = [sn_true(i,j,1) sn_true(i,j,2) sn_true(i,j,3)]';
       sn_es_tmp = [sn_es(i,j,1) sn_es(i,j,2) sn_es(i,j,3)]';
       
       if norm(sn_true_tmp) > 0
           error_rad = acos(dot(sn_true_tmp,sn_es_tmp));
           error_deg = rad2deg(error_rad);
           
           error_sn(i,j) = error_deg / 90;
           sum_error = sum_error + error_deg;
           count_pixel = count_pixel + 1;
       end
   end
end

ave_sn_error = sum_error / count_pixel
imwrite(error_sn,strcat(OUTPUT_DIR,'/error2.pgm'));