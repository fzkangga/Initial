#!/bin/bash
rm .version
# Bash Color
green='\033[01;32m'
red='\033[01;31m'
cyan='\033[01;36m'
blue='\033[01;34m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

DATE_START=$(date +"%s")

echo -e "${green}"
echo "--------------------------------------------------------"
echo "Wellcome !!!    "
echo "--------------------------------------------------------"
echo -e "${restore}"


echo -e "${blue}"
while read -p "Select defconfig

### A16C3H ###
1. lineageos_a16c3h_n_defconfig ---> nougat
2. lineageos_a16c3h_defconfig ---> oreo

### G36C1H ###
3. lineageos_rendang_n_defconfig ---> nougat
4. lineageos_rendang_defconfig ---> oreo
5. lineageos_rendang_sdfat_defconfig ---> oreo sdfat support


" echoice
do
case "$echoice" in
	1 )
		DEFCONFIG="lineageos_a16c3h_n_defconfig"
		BASE_VER="LOS-ARM-BINDER4-A16C3H-N"
		export KBUILD_BUILD_USER=a16c3h
		echo "lineageos_a16c3h_n_defconfig selected"
		break
		;;
	2 )
		DEFCONFIG="lineageos_a16c3h_defconfig"
		BASE_VER="LOS-ARM-BINDER4-A16C3H-O"
		export KBUILD_BUILD_USER=a16c3h
		echo "lineageos_a16c3h_defconfig selected"
		break
		;;
	3 )
		DEFCONFIG="lineageos_rendang_n_defconfig"
		BASE_VER="LOS-ARM-BINDER4-G36C1H-N"
		export KBUILD_BUILD_USER=g36c1h
		echo "lineageos_rendang_n_defconfig selected"
		break
		;;
	4 )
		DEFCONFIG="lineageos_rendang_defconfig"
		BASE_VER="LOS-ARM-BINDER4-G36C1H-O"
		export KBUILD_BUILD_USER=g36c1h
		echo "lineageos_rendang_defconfig selected"
		break
		;;
	5 )
		DEFCONFIG="lineageos_rendang_sdfat_defconfig"
		BASE_VER="LOS-ARM-BINDER4-SDFAT-G36C1H-O"
		export KBUILD_BUILD_USER=g36c1h
		echo "lineageos_rendang_defconfig selected"
		break
		;;

	* )
		echo
		echo "Invalid Selection try again !!"
		echo
		;;
esac
done
echo -e "${restore}"

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="zImage"

#Hyper Kernel Details
VER="-$(date +"%Y%m%d"-%H%M)-"
Devmod_VER="$BASE_VER$VER$TC"

# Vars
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_HOST=fzkdevmod

# Paths
KERNEL_DIR=`pwd`
RESOURCE_DIR="/home/fzk/Desktop/project_hy"
ANYKERNEL_DIR="$RESOURCE_DIR/hyper"
TOOLCHAIN_DIR="$RESOURCE_DIR/toolchain"
REPACK_DIR="$ANYKERNEL_DIR"
PATCH_DIR="$ANYKERNEL_DIR/patch"
MODULES_DIR="$ANYKERNEL_DIR/modules"
ZIP_MOVE="$RESOURCE_DIR/kernel_out"
ZIMAGE_DIR="$KERNEL_DIR/arch/arm/boot"

# Functions
function make_kernel {
		make $DEFCONFIG $THREAD
		make $KERNEL $THREAD
		make dtbs $THREAD
		cp -vr $ZIMAGE_DIR/$KERNEL $REPACK_DIR/zImage
}

#function make_modules {
#		cd $KERNEL_DIR
#		make modules $THREAD
#		find $KERNEL_DIR -name '*.ko' -exec cp {} $MODULES_DIR/ \;
#		cd $MODULES_DIR
#       $STRIP --strip-unneeded *.ko
#      cd $KERNEL_DIR
#}

function make_dtb {
		$KERNEL_DIR/tools/dtbToolCM -2 -o $KERNEL_DIR/arch/arm/boot/dt.img -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/
		cp -vr $KERNEL_DIR/arch/arm/boot/dt.img $REPACK_DIR/dtb
}

function make_zip {
		cd $REPACK_DIR
		zip -r `echo $Devmod_VER$TC`.zip *
		mv  `echo $Devmod_VER$TC`.zip $ZIP_MOVE
		cd $KERNEL_DIR
}

echo -e "${green}"
echo "--------------------------------------------------------"
echo "Initiatig To Compile $Devmod_VER    "
echo "--------------------------------------------------------"
echo -e "${restore}"

echo -e "${cyan}"
while read -p "Plese Select Desired Toolchain for compiling Kernel

LINARO4.9 (ARM)---->(1)

GNU-8.2 (ARM)---->(2)


" echoice
do
case "$echoice" in
	1 )
		export CROSS_COMPILE=$TOOLCHAIN_DIR/linaro/arm/arm-eabi/bin/arm-eabi-
		export LD_LIBRARY_PATH=$TOOLCHAIN_DIR/linaro/arm/arm-eabi/lib/
		STRIP=$TOOLCHAIN_DIR/linaro/arm/arm-eabi/bin/arm-eabi-strip
		TC="LN"
		rm -rf $MODULES_DIR/*
		rm -rf $ZIP_MOVE/*
		rm -rf $KERNEL_DIR/arch/arm/boot/dt.img
		cd $ANYKERNEL_DIR
		rm -rf zImage
		rm -rf dtb
		cd $KERNEL_DIR
		make clean && make mrproper
		echo "cleaned directory"
		echo "Compiling Kernel Using LINARO-4.9 Toolchain"
		break
		;;
	2 )
		export CROSS_COMPILE=$TOOLCHAIN_DIR/gnu/arm/arm-linux-gnueabi/bin/arm-linux-gnueabi-
		export LD_LIBRARY_PATH=$TOOLCHAIN_DIR/gnu/arm/arm-linux-gnueabi/lib/
		STRIP=$TOOLCHAIN_DIR/gnu/arm/arm-linux-gnueabi/bin/arm-linux-gnueabi-strip
		TC="GNU"
		rm -rf $MODULES_DIR/*
		rm -rf $ZIP_MOVE/*
		rm -rf $KERNEL_DIR/arch/arm/boot/dt.img
		cd $ANYKERNEL_DIR
		rm -rf zImage
		rm -rf dtb
		cd $KERNEL_DIR
		make clean && make mrproper
		echo "cleaned directory"
		echo "Compiling Kernel Using GNU-8.2 Toolchain"
		break
		;;

	* )
		echo
		echo "Invalid Selection try again !!"
		echo
		;;
esac
done
echo -e "${restore}"

echo
while read -p "Do you want to start Building Kernel ?

Yes Or No ? 

Enter Y for Yes Or N for No
" dchoice
do
case "$dchoice" in
	y|Y )
		make_kernel
		make_dtb
		make_zip
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid Selection try again !!"
		echo
		;;
esac
done
echo -e "${green}"
echo $Devmod_VER$TC.zip
echo "------------------------------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo " "
