# summer03 - 今風 OpenGL の使い方（第６回 視点の移動）サンプルプログラム

## 1. 概要

このプログラムは、OpenGL の **GLSL バーテックスシェーダ** と **uniform 変数** を用いて、ビュー変換（カメラパラメータに基づくビュー変換行列 `lookAt`）と透視投影変換行列（`perspectiveMatrix`）を合成した行列をシェーダに渡し、3次元空間内の折れ線図形を描画する手順を学ぶための、学生向けのサンプルプログラムです。本プログラムは、以下のブログ記事の解説に沿って学習を進めるための雛形として提供されています。

- [第６回 視点の移動](https://tokoik.github.io/blog/今風%20opengl%20の使い方/2009/09/02/glsl.html)

OpenGL 3.0 以降で廃止された `gluLookAt()` を使わず、視点位置・目標点・上方向ベクトルから自前でビュー変換行列を計算し、投影変換行列と乗算（`multiplyMatrix`）した上で `glUniformMatrix4fv()` でシェーダへ転送する手法を学習します。

## 2. 対応環境

- **Windows**: Windows 10 / 11, Visual Studio 2022 (MSVC C++17)
- **macOS**: macOS 12 Monterey 以降, Xcode 14 以降 / Command Line Tools
- **Linux**: Ubuntu 22.04 LTS 以降, GCC / Clang (C++17 対応コンパイラ)
- **ビルドツール**: CMake 3.22 以降

## 3. ビルド手順

このプログラムは [CMake](https://cmake.org/) を用いてビルド環境を整備します。各 OS とも、ソースコードが置かれているディレクトリにターミナル（またはコマンドプロンプト）で移動してから、以下の手順を実行してください。なお、プログラムをビルドするためのバイナリディレクトリは、バージョン管理ファイル（.gitignore）の設定に合わせて **build** という名前にします。

> cmake-gui で設定することも可能です。その際は、`Source code path` にはプロジェクトのフォルダを指定し、`Build path` にはプロジェクトのフォルダの中に作った build というフォルダを指定してください。その後、`Configure` → `Generate` の順にクリックした後、`Open Project` をクリックすれば、開発環境が起動します。

### 3.1 Windows (Visual Studio 2022 の場合)

1. コマンドプロンプトまたは PowerShell を開き、このプロジェクトのディレクトリに移動します。
2. 以下のコマンドを実行してビルドディレクトリを作成し、CMake で構成を行います。

   ```bat
   mkdir build
   cd build
   cmake .. -G "Visual Studio 17 2022"
   ```

3. 生成された build フォルダ内の `summer03.sln` を Visual Studio で開きます。
4. ソリューションエクスプローラーで **summer03** プロジェクトを右クリックし、「スタートアップ プロジェクトに設定」を選択します。
5. 「ローカル Windows デバッガー」をクリックするか、F5 キーを押してビルドおよび実行します。

### 3.2 macOS (Xcode の場合)

1. ターミナルを開き、このプロジェクトのディレクトリに移動します。
2. 以下のコマンドを実行してビルドディレクトリを作成し、Xcode 用のプロジェクトを生成します。

   ```sh
   mkdir build
   cd build
   cmake .. -G Xcode
   ```

3. 生成された `build/summer03.xcodeproj` を Xcode で開きます。
4. 左上のスキーム選択（再生ボタンの横）が **summer03** になっていることを確認します。
5. 「Run」ボタン（再生ボタン）をクリックするか、Command + R を押してビルドおよび実行します。

### 3.3 Ubuntu Linux

1. ターミナルを開き、このプロジェクトのディレクトリに移動します。
2. 必要なパッケージ（freeglut3-dev など）がインストールされていることを確認し、以下のコマンドでビルドします。

   ```sh
   mkdir build
   cd build
   cmake ..
   make
   ```

## 4. 起動方法

各 OS とも、ビルド後に生成されるバイナリディレクトリ (build) やそのサブフォルダから起動します。

- **Windows**

  Visual Studio 上で「ローカル Windows デバッガー」をクリックして実行するか、またはコマンドプロンプトから以下のコマンドで起動します。

  ```cmd
  cd build\Debug
  summer03.exe
  ```

- **macOS**

  Xcode 上で左上の「Run（再生ボタン）」をクリックして実行します。アプリケーションバンドルを直接起動する場合は、Finder から `build/Debug/summer03.app` を開くか、ターミナルから `open build/Debug/summer03.app` を実行します。

- **Ubuntu Linux**

  ターミナルから以下のコマンドで実行ファイル（バイナリ）を直接起動します。

  ```sh
  cd build
  ./summer03
  ```

## 5. 操作方法

- 視点位置 `(4.0, 5.0, 6.0)` から原点 `(0.0, 0.0, 0.0)` を見下ろす形で、折れ線図形が3次元的に透視投影表示されます。

## 6. プログラムの解説

### 6.1 ビュー変換行列の算出 (lookAt)

```cpp
void lookAt(float ex, float ey, float ez,
  float tx, float ty, float tz,
  float ux, float uy, float uz,
  GLfloat* matrix)
{
  float l;

  /* z 軸 = e - t */
  tx = ex - tx;
  ty = ey - ty;
  tz = ez - tz;
  l = sqrtf(tx * tx + ty * ty + tz * tz);
  matrix[2] = tx / l;
  matrix[6] = ty / l;
  matrix[10] = tz / l;

  /* x 軸 = u x z 軸 */
  tx = uy * matrix[10] - uz * matrix[6];
  ty = uz * matrix[2] - ux * matrix[10];
  tz = ux * matrix[6] - uy * matrix[2];
  l = sqrtf(tx * tx + ty * ty + tz * tz);
  matrix[0] = tx / l;
  matrix[4] = ty / l;
  matrix[8] = tz / l;

  /* y 軸 = z 軸 x x 軸 */
  matrix[1] = matrix[6] * matrix[8] - matrix[10] * matrix[4];
  matrix[5] = matrix[10] * matrix[0] - matrix[2] * matrix[8];
  matrix[9] = matrix[2] * matrix[4] - matrix[6] * matrix[0];

  /* 平行移動 */
  matrix[12] = -(ex * matrix[0] + ey * matrix[4] + ez * matrix[8]);
  matrix[13] = -(ex * matrix[1] + ey * matrix[5] + ez * matrix[9]);
  matrix[14] = -(ex * matrix[2] + ey * matrix[6] + ez * matrix[10]);

  /* 残り */
  matrix[3] = matrix[7] = matrix[11] = 0.0f;
  matrix[15] = 1.0f;
}
```

### 6.2 行列の乗算とシェーダへの転送

```cpp
/* 透視投影変換行列を求める */
GLfloat perspective[16];
perspectiveMatrix(-1.0f, 1.0f, -1.0f, 1.0f, 7.0f, 11.0f, perspective);

/* ビュー変換行列を求める */
GLfloat viewing[16];
lookAt(4.0f, 5.0f, 6.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, viewing);

/* ビュー変換行列と投影変換行列の積を projectionMatrix に入れる */
multiplyMatrix(viewing, perspective, projectionMatrix);

/* uniform 変数 projectionMatrix の場所を得る */
projectionMatrixLocation = glGetUniformLocation(gl2Program, "projectionMatrix");
```
