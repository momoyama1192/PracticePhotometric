import math
import numpy as np
import cv2
import random

# 設定ここから

## 画像設定 (make_input_model.pyの設定と同じにすること)
N_ROW  = 128 # 画像の行 (縦方向) の数
N_COL  = 128 # 画像の列 (横方向) の数
pic_num = 10 # 作成した画像の数

## 入力ディレクトリ (最後の / は不要)
INPUT_DIR = "input"; 
## 出力先ディレクトリ (最後の / は不要)
OUTPUT_DIR = "output"; 


# 設定ここまで

## 各種初期化
sn_es = np.zeros([N_ROW, N_COL, 3])

LOAD_S_DIR = INPUT_DIR + "/light_source.txt"
S  = np.loadtxt(LOAD_S_DIR)
img_pixel_value = np.zeros([N_ROW,N_COL,pic_num])

## 画像読み込み
for a in range(0,pic_num):
    LOAD_IMG_DIR = INPUT_DIR + "/" +  str(a + 1) + ".pgm"
    img_pixel_value[:,:,a] = cv2.imread(LOAD_IMG_DIR, cv2.IMREAD_GRAYSCALE)

## 推定
for i in range(0,N_ROW):
    for j in range(0,N_COL):
        intensity = np.array([img_pixel_value[i,j,:]]).T # 縦ベクトルを作成するため
        sn_tmp = np.dot(np.linalg.pinv(S),intensity) # 計算のときだけ縦ベクトルに
        if np.linalg.norm(sn_tmp) > 0:
            sn_tmp = sn_tmp / np.linalg.norm(sn_tmp)
            sn_es[i,j,:] = sn_tmp.T # 計算後は横ベクトルに戻す
     

## 誤差の評価
# 画像による確認 (定性的評価)
check_sn = (sn_es + 1) * 255 / 2
check_sn_bgr = check_sn[:, :, [2, 1, 0]] # CV2はBGRの順に認識されるため 
cv2.imwrite(OUTPUT_DIR + "/result.ppm", check_sn_bgr) 

# 数値による確認 (定量的評価)
error_sn = np.zeros([N_ROW, N_COL])

LOAD_SNTRUE_DIR = INPUT_DIR + "/sn_true.npy"
sn_true = np.load(LOAD_SNTRUE_DIR)

count_pixel = 0
sum_error = 0

for i in range(0,N_ROW):
    for j in range(0,N_COL):
        sn_true_tmp = sn_true[i,j,:]
        sn_es_tmp = sn_es[i,j,:]
        if np.linalg.norm(sn_true_tmp) > 0:
            error_rad = np.arccos(np.dot(sn_es_tmp,sn_true_tmp))
            error_deg = math.degrees(error_rad)

            error_sn[i,j] = error_deg / 90 * 255
            sum_error += error_deg
            count_pixel += 1

ave_sn_error = sum_error / count_pixel
print(ave_sn_error)

cv2.imwrite(OUTPUT_DIR + "/error.pgm", error_sn)