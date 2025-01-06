#!/usr/bin/env bash
#
# install_clang.sh
# ----------------
# 이 스크립트는 현재 디렉토리에 있는 Clang/LLVM( bin, include, lib, libexec, share )을
# /usr/local/llvm로 복사하고, macOS SDK 경로를 셸 설정에 추가,
# 그리고 Quarantine 속성을 제거해 매번 보안 경고가 뜨지 않도록 설정해 줍니다.
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
CURRENT_SHELL_NAME=$(basename "$SHELL")
if [[ "$CURRENT_SHELL_NAME" == "zsh" ]]; then
  SHELL_RC="$HOME/.zshrc"
elif [[ "$CURRENT_SHELL_NAME" == "bash" ]]; then
  SHELL_RC="$HOME/.bash_profile"
else
  SHELL_RC="$HOME/.zshrc"
fi

echo "✅ 셸 설정 파일: $SHELL_RC"

# PATH 등록 여부 확인
grep "$INSTALL_DIR/bin" "$SHELL_RC" &> /dev/null
if [[ $? -eq 0 ]]; then
  echo "ℹ️  이미 $INSTALL_DIR/bin 이(가) PATH에 추가되어 있습니다."
else
  echo "➡️  $SHELL_RC에 PATH 추가(등록) 중..."
  echo "" >> "$SHELL_RC"
  echo "# [LLVM/Clang 설치 스크립트에 의해 추가됨]" >> "$SHELL_RC"
  echo "export PATH=\"$INSTALL_DIR/bin:\$PATH\"" >> "$SHELL_RC"
  echo "" >> "$SHELL_RC"
  echo "✅ PATH 추가 완료."
fi

### 6) macOS SDK 경로 설정 (SDKROOT)
# Xcode Command Line Tools나 Xcode가 설치되어 있어야 xcrun --show-sdk-path가 작동함
SDK_PATH="$(xcrun --show-sdk-path 2>/dev/null)"
if [[ -n "$SDK_PATH" ]]; then
  # 이미 .zshrc/.bash_profile 등에 SDKROOT 설정이 있는지 확인
  grep "export SDKROOT=" "$SHELL_RC" &> /dev/null
  if [[ $? -eq 0 ]]; then
    echo "ℹ️  이미 SDKROOT 설정이 있습니다. 업데이트는 직접 확인해 주세요."
  else
    echo "➡️  macOS SDK 경로($SDK_PATH)를 $SHELL_RC에 등록합니다."
    echo "" >> "$SHELL_RC"
    echo "# [LLVM/Clang 설치 스크립트에 의해 추가됨]" >> "$SHELL_RC"
    echo "export SDKROOT=\"$SDK_PATH\"" >> "$SHELL_RC"
    echo "" >> "$SHELL_RC"
    echo "✅ SDKROOT 추가 완료."
  fi
else
  echo "⚠️  xcrun --show-sdk-path를 통해 SDK 경로를 찾을 수 없습니다."
  echo "    Xcode Command Line Tools 또는 Xcode가 설치되어 있는지 확인해 주세요."
fi

### 7) Quarantine 속성 해제 (Gatekeeper)
# /usr/local/llvm 폴더에 대해 재귀적으로 com.apple.quarantine 속성을 제거.
echo "➡️  Quarantine 속성 제거 중..."
xattr -rd com.apple.quarantine "$INSTALL_DIR" 2>/dev/null
echo "✅ Quarantine 속성 제거 완료."

### 8) 설치 후 안내
echo "-------------------------------------------------"
echo "✅ 설치가 완료되었습니다!"
echo "1) 새로운 터미널을 열거나 'source $SHELL_RC' 명령을 실행하세요."
echo "2) 'which clang' 실행 시 $INSTALL_DIR/bin/clang 이 나오면 OK."
echo "3) macOS SDK 경로가 등록되었으므로, 시스템 헤더도 인식 가능:"
echo "   clang -isysroot \$SDKROOT main.c  (또는 필요 시 자동 인식)"
echo "-------------------------------------------------"
