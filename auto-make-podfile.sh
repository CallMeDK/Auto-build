CURRENT_URL=`pwd`
TARGETNAME=$1   # target Name: 应用对应的 target 名 （传入）
#添加common
cat ${CURRENT_URL}/podfiles/podfile-common > Podfile

# 添加某个target的
echo "--------copy ${opt}文件到podfile文件中--------\n\n"
cat ${CURRENT_URL}/podfiles/podfile-${TARGETNAME} >> Podfile

echo "-----------自动生成的 Podfile文件 --------------:"
cat podfile
echo "-----------自动生成的 Podfile文件完成------------"
