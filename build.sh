
#~ * $0 ����������൱��c/c++�е�argv[0]
#~ * $1 ����һ������.
#~ * $2, $3, $4 ... ����2��3��4���������������ơ�
#~ * $#  �����ĸ����������������
#~ * $@ ������������б�Ҳ�����������
#~ * $* ����$@��ͬ����"$*" �� "$@"(������)����ͬ��"$*"�����еĲ������ͳ�һ���ַ�������"$@"��һ���������顣
    
### Process arguments

#Variable list
## LUA, ANDROID

#default 
Lua=lua

#process arguments
while [ -n "$1" ]
do
  case "$1" in
    -?|-h)
	return;;
    -L)
      Lua="$2"
      shift 2;;
    -N)
      NDK="$2"
      shift 2;;
    -A)
      NDKABI="$2"
      shift 2;;
    -V)
      NDKVER="$2"
      shift 2;;
    -P)
      NDKP="$2"
      shift 2;;
    -X)
      shift 2;
      EXTRAS="$*"
      break
      ;;
 esac
done

#check 
echo "$Lua $NDK $NDKABI $NDKVER $EXTRAS"

if [ "$NDK" == "" ]
then
  cd $Lua
  make $EXTRAS
else
 
#  NDK=/e/tools/android/android-ndk-r15c
  if [  "$NDKABI" == ""  ]
  then
    NDKABI=19
  if

  #NDKVER=$NDK/toolchains/arm-linux-androideabi-4.9
  if [ "$NDKVER" == "" ]
  then
    NDKVER=$NDK/toolchains/arm-linux-androideabi-4.9
  fi
  
  #NDKP=$NDKVER/prebuilt/windows-x86_64/bin/arm-linux-androideabi-
  if [ "$NDKP" == "" ]
  then
    echo Please given  NDKP follow by -V
    return
  fi  
  NDKF="--sysroot=$NDK/platforms/android-$NDKABI/arch-arm"

  if [ "$Lua" == "lua" ]
  then
    CC=${NDKP}gcc
    AR="${NDKP}ar rcu"
    RANLIB=${NDKP}ranlib
    CFLAGS="-I$NDK/platforms/android-$NDKABI/arch-arm/usr/include -L$NDK/platforms/android-$NDKABI/arch-arm/usr/lib"
    cd $lua
    make CC=$CC AR="$AR" CFLAGS="$CFLAGS -D\"lua_getlocaledecpoint()='.'\"" RANLIB=$RANLIB $EXTRAS
  else
    cd $Lua
    make HOST_CC="gcc -m32" CROSS=$NDKP TARGET_FLAGS="$NDKF" TARGET_SYS=LINUX  $EXTRAS
  fi
  fi
fi

# build wluajit
#~ LUAJIT_SRC=../luajit/src/src
#~ BIN_DIR=../../bin/mingw32
#~ windres luajit.rc luajit.o
#~ gcc -O2 -s -static-libgcc wmain.c luajit.o $LUAJIT_SRC/luajit.c -o $BIN_DIR/wluajit.exe -mwindows -llua51 -I$LUAJIT_SRC -L$BIN_DIR
#~ rm luajit.o