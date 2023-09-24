cd $USER_HOME_DIR/ECCOV4/release4
mkdir build
cd build

$ROOTDIR/tools/genmake2 -mods=../code optfile=$USER_HOME_DIR/docker_src/linux_amd64_gfortran

make -j depend
make -j 
