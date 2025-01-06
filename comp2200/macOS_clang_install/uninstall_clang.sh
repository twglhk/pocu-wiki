#!/usr/bin/env bash
#
# uninstall_clang.sh
# ------------------
# 1. /usr/local/llvm 폴더 삭제
# 2. .zshrc 또는 .bash_profile 등에서 PATH/SDKROOT 관련 라인 삭제
# 3. (심볼릭 링크 사용 중이었다면) 링크 삭제
# ------------------

### 1) 관리자 권한 체크
if [[ $EUID -ne 0 ]]; then
  echo "❗️  관리자 권한(sudo)으로 다시 실행해 주세요."
  echo "    예) sudo ./uninstall_clang.sh"
  exit 1
fi

INSTALL_DIR="/usr/local/llvm"

echo "-------------------------------------------------"
echo "🗑️ 1) 설치된 Clang/LLVM 폴더 삭제: $INSTALL_DIR"
if [[ -d "$INSTALL_DIR" ]]; then
  rm -rf "$INSTALL_DIR"
  echo "✅ $INSTALL_DIR 삭제 완료."
else
  echo "ℹ️  $INSTALL_DIR 폴더가 없습니다. 이미 삭제된 것 같습니다."
fi

echo "-------------------------------------------------"
echo "🔎 2) PATH/SDKROOT 관련 설정 삭제"
# 현재 로그인 셸 확인
CURRENT_SHELL_NAME=$(basename "$SHELL")
if [[ "$CURRENT_SHELL_NAME" == "zsh" ]]; then
  SHELL_RC="$HOME/.zshrc"
elif [[ "$CURRENT_SHELL_NAME" == "bash" ]]; then
  SHELL_RC="$HOME/.bash_profile"
else
  # 기본적으로 zshrc로 처리 (원하는 파일로 수정 가능)
  SHELL_RC="$HOME/.zshrc"
fi

echo "   셸 설정 파일: $SHELL_RC"

if [[ -f "$SHELL_RC" ]]; then

  # 백업 파일 만들기
  BACKUP_FILE="$SHELL_RC.backup.$(date +%Y%m%d_%H%M%S)"
  cp "$SHELL_RC" "$BACKUP_FILE"
  echo "   백업 생성: $BACKUP_FILE"

  # sed를 이용해, 이전에 스크립트가 추가한 부분(# [LLVM/Clang 설치 스크립트에 의해 추가됨])을 찾아 제거
  # 주석 라인을 포함해 export PATH=... 또는 export SDKROOT=... 라인 등을 지움
  sed -i '' '/# \[LLVM\/Clang 설치 스크립트에 의해 추가됨\]/d' "$SHELL_RC"
  sed -i '' "/export PATH=\"\/usr\/local\/llvm\/bin:\$PATH\"/d" "$SHELL_RC"
  sed -i '' "/export SDKROOT=/d" "$SHELL_RC"

  # 만약 사용자가 직접 기입했거나 다른 형식으로 추가했을 가능성이 있다면, 수동 확인 필요.
  echo "✅ $SHELL_RC 에서 PATH/SDKROOT 관련 라인을 제거했습니다."
  echo "   (혹시 다른 형식으로 작성한 부분이 있다면 직접 확인하세요.)"

else
  echo "ℹ️  $SHELL_RC 파일이 없습니다. 이미 제거되었거나 다른 설정 파일을 사용 중일 수 있습니다."
fi

echo "-------------------------------------------------"
echo "🔗 3) 심볼릭 링크 제거 (필요한 경우만)"

# 혹시 /usr/local/bin/clang 형태로 링크를 만들어두었다면 제거
if [[ -L "/usr/local/bin/clang" ]]; then
  rm "/usr/local/bin/clang"
  echo "✅ /usr/local/bin/clang 링크 삭제 완료."
fi

if [[ -L "/usr/local/bin/clang++" ]]; then
  rm "/usr/local/bin/clang++"
  echo "✅ /usr/local/bin/clang++ 링크 삭제 완료."
fi

echo "-------------------------------------------------"
echo "✅ 모든 작업이 완료되었습니다!"
echo "   - /usr/local/llvm 제거"
echo "   - .zshrc / .bash_profile에서 PATH/SDKROOT 제거"
echo "   - (심볼릭 링크 제거)"
echo ""
echo "이제 터미널을 다시 열거나 'source $SHELL_RC' 명령을 실행하면, 더 이상 /usr/local/llvm/bin/clang 을 사용하지 않게 됩니다."
echo "-------------------------------------------------"

