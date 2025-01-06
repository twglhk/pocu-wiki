# Mac에서 LLVM 설치하기

## 설치 방법

1. mac용 설치 파일을 다운로드
[다음 링크(2025년 기준, 18.1.8)](https://github.com/llvm/llvm-project/releases/tag/llvmorg-18.1.8)에서 LLVM mac용 릴리즈 파일을 다운로드합니다.

  <img width="410" alt="image" src="https://github.com/user-attachments/assets/f822a826-929c-4a1a-833e-db05a526b364" />

2. 다운로드한 파일의 압축을 해제합니다.

  <img width="382" alt="image" src="https://github.com/user-attachments/assets/e786f79e-a8aa-4f20-bd68-9f13134a3462" />

3. 여기에 있는 [install_clang.sh](https://github.com/twglhk/pocu-wiki/blob/main/comp2200/macOS_clang_install/install_clang.sh.sh)을 다운로드 합니다.

4. 압축푼 디렉토리에 sh 파일을 넣습니다.

5. 해당 디렉토리에서 터미널을 열고 다음 명령어를 입력하여 sh 파일을 실행합니다.
```
sudo sh install_clang.sh.sh
```

6. 설치를 확인하려면 아래 명령어들을 입력해보세요
```
source /Users/sinjongha/.zshrc
which clang
clang --version
```
  이렇게 뜨면 성공입니다.
<img width="1046" alt="image" src="https://github.com/user-attachments/assets/35e08d91-ef97-41c9-986e-18c6504abd73" />
