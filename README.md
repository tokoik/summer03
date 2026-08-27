# summer03 - 今風 OpenGL の使い方（第６回 視点の移動）サンプルプログラム

## 1. 概要

このプログラムは、OpenGL の **GLSL バーテックスシェーダ** と **uniform 変数** を用いて、自前で算出したビュー変換行列（`lookAt`）と投影変換行列（平行投影変換 `orthogonalMatrix` / 透視投影変換 `perspectiveMatrix`）を行列の積（`multiplyMatrix`）で合成し、視点移動と透視投影変換を行って図形を描画する手順を学ぶための、学生向けのサンプルプログラムです。本プログラムは、以下のブログ記事の解説に沿って学習を進めるための雛形として提供されています。

- [第６回 視点の移動](https://tokoik.github.io/blog/glsl/2009/09/02/glsl.html)

OpenGL 3.0 以降で廃止された `gluLookAt()` や `glMultMatrixf()` を使わず、CPU 側で視点座標系の基底ベクトルと平行移動からビュー変換行列を計算し、シェーダに渡す手法を学習します。

## 2. ビルド方法

このプログラムは [CMake](https://cmake.org/) を用いてビルド環境を整備します。各OSとも、ソースコードが置かれているディレクトリにターミナル（またはコマンドプロンプト）で移動してから、以下の手順を実行してください。なお、プログラムをビルドするためのバイナリディレクトリは、バージョン管理ファイル（.gitignore）の設定に合わせて **build** という名前にします。

### 2.1 Windows (Visual Studio 2022 の場合)

1. コマンドプロンプトまたは PowerShell を開き、このプロジェクトのディレクトリに移動します。
2. 以下のコマンドを実行してビルドディレクトリを作成し、CMake で構成を行います。

   ```bat
   mkdir build
   cd build
   cmake .. -G "Visual Studio 17 2022"
   ```

3. 生成された build フォルダ内の summer03.sln を Visual Studio で開きます。
4. ソリューションエクスプローラーで **summer03** プロジェクトを右クリックし、「スタートアップ プロジェクトに設定」を選択します。
5. 「ローカル Windows デバッガー」をクリックするか、F5 キーを押してビルドおよび実行します。

### 2.2 macOS (Xcode の場合)

1. ターミナルを開き、このプロジェクトのディレクトリに移動します。
2. 以下のコマンドを実行してビルドディレクトリを作成し、Xcode 用のプロジェクトを生成します。

   ```sh
   mkdir build
   cd build
   cmake .. -G Xcode
   ```

3. 生成された build/summer03.xcodeproj を Xcode で開きます。
4. 左上のスキーム選択（再生ボタンの横）が **summer03** になっていることを確認します。
5. 「Run」ボタン（再生ボタン）をクリックするか、Command + R を押してビルドおよび実行します。

### 2.3 Ubuntu Linux

1. ターミナルを開き、このプロジェクトのディレクトリに移動します。
2. 必要なパッケージ（freeglut3-dev など）がインストールされていることを確認し、以下のコマンドでビルドします。

   ```sh
   mkdir build
   cd build
   cmake ..
   make
   ```

## 3. 使い方

### 3.1 プログラムの起動方法

- **Windows**: `build\Debug\summer03.exe`
- **macOS**: `open build/Debug/summer03.app` または Xcode 上で Run
- **Ubuntu Linux**: `cd build && ./summer03`

### 3.2 操作方法

- 視点位置 (4, 5, 6) から目標点 (0, 0, 0) を見下ろすように透視投影変換された折れ線図形が表示されます。

## 4. 解説

### 4.1 ビュー変換行列の算出 (lookAt)

```cpp
void lookAt(float ex, float ey, float ez,
            float tx, float ty, float tz,
            float ux, float uy, float uz,
            GLfloat *matrix)
{
  /* 視線逆方向ベクトル z' */
  float zx = ex - tx, zy = ey - ty, zz = ez - tz;
  float lz = sqrtf(zx * zx + zy * zy + zz * zz);
  zx /= lz; zy /= lz; zz /= lz;

  /* 右方向ベクトル x' = u × z' */
  float xx = uy * zz - uz * zy, xy = uz * zx - ux * zz, xz = ux * zy - uy * zx;
  float lx = sqrtf(xx * xx + xy * xy + xz * xz);
  xx /= lx; xy /= lx; xz /= lx;

  /* 上方向ベクトル y' = z' × x' */
  float yx = zy * xz - zz * xy, yy = zz * xx - zx * xz, yz = zx * xy - zy * xx;

  matrix[ 0] = xx; matrix[ 4] = xy; matrix[ 8] = xz; matrix[12] = -(xx * ex + xy * ey + xz * ez);
  matrix[ 1] = yx; matrix[ 5] = yy; matrix[ 9] = yz; matrix[13] = -(yx * ex + yy * ey + yz * ez);
  matrix[ 2] = zx; matrix[ 6] = zy; matrix[10] = zz; matrix[14] = -(zx * ex + zy * ey + zz * ez);
  matrix[ 3] = 0.0f; matrix[ 7] = 0.0f; matrix[11] = 0.0f; matrix[15] = 1.0f;
}
```

### 4.2 行列の積の算出 (multiplyMatrix)

```cpp
void multiplyMatrix(const GLfloat *m0, const GLfloat *m1, GLfloat *matrix)
{
  for (int i = 0; i < 4; ++i) {
    for (int j = 0; j < 4; ++j) {
      matrix[i + j * 4] = m0[i + 0] * m1[0 + j * 4]
                        + m0[i + 4] * m1[1 + j * 4]
                        + m0[i + 8] * m1[2 + j * 4]
                        + m0[i + 12] * m1[3 + j * 4];
    }
  }
}
```
