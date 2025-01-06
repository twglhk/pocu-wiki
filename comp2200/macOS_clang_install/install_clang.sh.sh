#!/usr/bin/env bash
#
# install_clang.sh
# ----------------
# 이 스크립트는 현재 디렉토리에 있는 Clang/LLVM( bin, include, lib, libexec, share )을
# /usr/local/llvm로 복사하고, 사용자의 셸 설정 파일에 PATH를 등록합니다.
# ----------------

### 1) 권한 체크 (root 또는 sudo 사용)
if [[ $EUID -ne 0 ]]; then
  echo "❗️  관리자 권한(sudo)으로 다시 실행해 주세요."
  echo "    예) sudo ./install_clang.sh"
  exit 1
fi

### 2) 현재 디렉토리에 필요한 폴더가 있는지 확인
REQUIRED_DIRS=("bin" "include" "lib")
MISSING="false"
for d in "${REQUIRED_DIRS[@]}"; do
  if [[ ! -d "$d" ]]; then
    echo "❗️  현재 디렉토리에 '$d' 폴더가 없습니다. 이 스크립트를 Clang을 다운받은 디렉토리에서 실행하세요."
    MISSING="true"
  fi
done

if [[ "$MISSING" = "true" ]]; then
  echo "스크립트를 종료합니다."
  exit 1
fi

echo "✅ 필요한 폴더가 모두 확인되었습니다."

### 3) /usr/local/llvm 폴더 생성 (없으면)
INSTALL_DIR="/usr/local/llvm"
echo "ℹ️  설치 경로: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

### 4) 폴더 복사
# libexec, share 폴더가 있으면 함께 복사
for d in bin include lib libexec share; do
  if [[ -d "$d" ]]; then
    echo "➡️  복사 중: $d -> $INSTALL_DIR"
    cp -R "$d" "$INSTALL_DIR/"
  fi
done

### 5) 사용자 셸 설정 파일 찾아서 PATH 등록
# macOS 기본 셸은 zsh이지만, bash 사용 가능성도 고려.
# 우선 현재 로그인 셸을 확인하고, 없으면 zshrc에 추가하는 식으로 처리.
CURRENT_SHELL_NAME=$(basename "$SHELL")
if [[ "$CURRENT_SHELL_NAME" == "zsh" ]]; then
  SHELL_RC="$HOME/.zshrc"
elif [[ "$CURRENT_SHELL_NAME" == "bash" ]]; then
  # bash의 경우 ~/.bash_profile 또는 ~/.bashrc를 쓸 수 있음
  # macOS 기본 로그인 셸은 ~/.bash_profile를 주로 사용
  SHELL_RC="$HOME/.bash_profile"
else
  # 그 외 셸이면, 그냥 ~/.zshrc에 추가
  SHELL_RC="$HOME/.zshrc"
fi

echo "✅ 셸 설정 파일: $SHELL_RC"

# 이미 등록되어 있는지 확인
grep "/usr/local/llvm/bin" "$SHELL_RC" &> /dev/null
if [[ $? -eq 0 ]]; then
  echo "ℹ️  이미 $INSTALL_DIR/bin 이(가) PATH에 추가되어 있습니다."
else
  echo "➡️  $SHELL_RC에 PATH 추가(등록) 중..."
  echo "" >> "$SHELL_RC"
  echo "# [LLVM/Clang 설치 스크립트에 의해 추가됨]" >> "$SHELL_RC"
  echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >> "$SHELL_RC"
  echo "" >> "$SHELL_RC"
  echo "✅ 추가 완료. 새로운 터미널을 열거나, 'source $SHELL_RC' 명령을 실행하세요."
fi

### 6) 설치 확인 안내
echo "-------------------------------------------------"
echo "✅ 설치가 완료되었습니다!"
echo "다음 명령어로 버전을 확인해보세요."
echo "  source $SHELL_RC"
echo "  which clang"
echo "  clang --version"
echo "-------------------------------------------------"

