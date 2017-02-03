# 自动打包说明
#  1. 需要 yml 中动态指定的打包参数：
#       TARGET_NAME：    应用的名对应的 iOS 项目中 Target，默认使用 DK_Phone
#       Mobile_Provision_File_Name: 打包证书的描述文件的文件名,默认使用 测试证书 xxx(描述文件名称)
#       buildConfig：打包方式,默认为 DailyBuild
#     需要从 yml 文件中，执行此 auto-package.sh 时传入
#  2. 传入的 打包证书的描述文件的文件名 Mobile_Provision_File_Name，必须此证书在 打包的 Mac 机上安装过一次
#  3. 设置交易的 H5 仓库为本仓库的 submodule, 目前依赖的的 H5 仓库路径是
#       git@gitlab.。。。。
#     设置成功后，会在项目目录下生成  DK_h5(设置 submodule 时指定的) 目录
#     注： 此动作只需要在项目创建时执行一次，以后每次打包时，不需要再处理

# 应用名对应的 iOS 项目中 Target eg: DK_Phone
# 注： 默认使用 标准版 DK_Phone

# 分支名 eg:  ZXJT_Phone
T_NAME=$1

# 打包证书的描述文件的文件名
# 注： 默认使用 测试证书 xxx(描述文件名称)
Mobile_Provision_File_Name=$2
# 打包方式,默认为DailyBuild
# 注：可选 Release, DailyBuild, Debug
buildConfig=$3
# 当前的分支
branch=$4

# 中文应用名
Production_Chinese="undefine_target";

# Shell函数定义的变量默认是global的，其作用域从“函数被调用时执行变量定义的地方”开始，
# 到shell结束或被显示删除处为止。函数定义的变量可以被显示定义成local的，
# 其作用域局限于函数内。但请注意，函数的参数是local的。
function getTargetNameAndProductionChinese() {
    T_NAME="$1"
    TARGET_NAME="undefine_target_name"
    Production_Chinese="undefine_target"

    case $T_NAME in
        DK_Phone)
        TARGET_NAME="DK_Phone"
	Customer="DK"
        Production_Chinese="相关名称"
            ;;

        ZXJT_Phone)
        TARGET_NAME="ZhongXinJianTou_Phone"
	Customer="zxjt"
        Production_Chinese="相关名称"
            ;;
        *)
        TARGET_NAME="DK_Phone"
	Customer="xxx"
        Production_Chinese="undefine_target"
            ;;
    esac
}

getTargetNameAndProductionChinese $T_NAME

echo ============== 1. 自动打包参数： =============
echo target name: $TARGET_NAME
echo 描述文件: $Mobile_Provision_File_Name
echo 打包方式： $buildConfig
echo 当前分支： $branch

# 检验参数是否为空，为空直接退出

if [[ $# < 4 ]]; then
    echo "\n\nerror:打包参数缺少,请看上方输出\n\n"
    exit 1
fi

# 记录当前工作路径
CURRENT_WORK_PATH=`pwd`

if [ -z "$TARGET_NAME" ]; then
    echo "打包应用未指定，默认打包标准版 DK_Phone"
    TARGET_NAME="DK_Phone"
fi

# pod file UTF8 问题
source ~/.profile

echo ============= 2. 下载交易 H5 源码并编译 =============
# 更新 submodule
git submodule update --init --recursive

# submodule 生成的交易 H5 文件路径（在设置 submodule 时指定的目录名）
TRADE_H5_SOURCE_FILE_PATH="DK_h5"

# 要打开的文件
H5_NEED_CD_FILE_PATH="./FILE_NOT_HAVE_PATH"  # 赋值给一个默认不存在的

# 2.将 H5 编译生成的文件放入项目中
function getRelateWebOriginResource() {
    TARGET_NAME="$1"
    TRADE_H5_FILE_DIRECTORY="$2"
    local webType="$3"

    if [[ "$webType" == "DK" ]];then
        # 编译后生成的交易 H5 文件所在目录
        # 注：DK519 在 h5 仓库的 build.sh 中定义，并且，和 iOS 项目中放交易 H5 文件的目录名一致
        # iOS 项目中交易 h5 文件的路径
        # 注： 此路径目前是固定在 DK_Phone/Projects 目录下，各个应用对应的目录下的 DK519 目录
        if [[ "$TARGET_NAME" == "ZhongXinJianTou_Phone" ]]; then
            H5_NEED_CD_FILE_PATH="./${TRADE_H5_SOURCE_FILE_PATH}/H5-zxjt"
        elif [[ "$TARGET_NAME" == "ShiJiZhengQuan_Phone" ]]; then
            H5_NEED_CD_FILE_PATH="./${TRADE_H5_SOURCE_FILE_PATH}/H5-sjzq"
        elif [[ "$TARGET_NAME" == "DaTongZhengQuan_Phone" ]]; then
            H5_NEED_CD_FILE_PATH="./${TRADE_H5_SOURCE_FILE_PATH}/H5-dtzq"
        elif [[ "$TARGET_NAME" == "GuoYuan_Phone" ]]; then
            H5_NEED_CD_FILE_PATH="./${TRADE_H5_SOURCE_FILE_PATH}/H5-gyzq2016"
        else
            H5_NEED_CD_FILE_PATH="./${TRADE_H5_SOURCE_FILE_PATH}/H5"
        fi

        if [ -d ${H5_NEED_CD_FILE_PATH} ]; then
            cd ${H5_NEED_CD_FILE_PATH}
        else
            echo "找不到${H5_NEED_CD_FILE_PATH}下的相关应用h5文件, 请验证gitmoudules是否有改动过"
            exit 1
        fi
    elif [[ "$webType" == "xinguF10" ]]; then
        H5_NEED_CD_FILE_PATH="./${TRADE_H5_SOURCE_FILE_PATH}/XinGuNewsF10"
        if [ -d ${H5_NEED_CD_FILE_PATH} ]; then
            cd ${H5_NEED_CD_FILE_PATH}
        else
            echo "找不到${H5_NEED_CD_FILE_PATH}下的相关应用h5文件, 请验证gitmoudules是否有改动过"
            exit 1
        fi
    else
        H5_NEED_CD_FILE_PATH="./${TRADE_H5_SOURCE_FILE_PATH}/f10News"
        if [ -d ${H5_NEED_CD_FILE_PATH} ]; then
            cd ${H5_NEED_CD_FILE_PATH}
        else
            echo "找不到${H5_NEED_CD_FILE_PATH}下的相关应用h5文件, 请验证gitmoudules是否有改动过"
            exit 1
        fi
    fi

    if [ "$branch" == "master" ]; then
        git pull origin  master
    else
        git pull origin  develop
    fi

    sh ./build.sh  # 如果是华龙的话，会生成DKF10目录。国元新股资讯生成XinGuNewsF10

    if [[ "$webType" == "DK" ]]; then
        echo "::相关项目 目录迁移"
        cp -fr ${TRADE_H5_FILE_DIRECTORY} ${CURRENT_WORK_PATH}/DK_Phone/Projects/$TARGET_NAME/.
        rm -fr $TRADE_H5_FILE_DIRECTORY
        cd $CURRENT_WORK_PATH
    elif [[ "$webType" == "xinguF10" ]]; then
        echo "相关项目::XinGuNewsF10目录迁移"
        mkdir ${CURRENT_WORK_PATH}/DK_Phone/Projects/$TARGET_NAME/XinGuNewsF10 #创建目录
        cp -a ${TRADE_H5_FILE_DIRECTORY}/. ${CURRENT_WORK_PATH}/DK_Phone/Projects/$TARGET_NAME/XinGuNewsF10/
        rm -fr $TRADE_H5_FILE_DIRECTORY
        cd $CURRENT_WORK_PATH
    else
        echo "相关项目::DKF10目录迁移"
        mkdir ${CURRENT_WORK_PATH}/DK_Phone/Projects/$TARGET_NAME/f10News #创建目录
        cp -a ${TRADE_H5_FILE_DIRECTORY}/. ${CURRENT_WORK_PATH}/DK_Phone/Projects/$TARGET_NAME/f10News/
        rm -fr $TRADE_H5_FILE_DIRECTORY
        cd $CURRENT_WORK_PATH
    fi
}

function getGuoYuanOTCResource() {
    OTC_FILE_DIRECTORY="$1"
    echo "相关项目 把otc的第三方资源文件www拷贝到对应目录下"
    OTC_NEED_CD_FILE_PATH="./iOS_lib/gyzq_otc"
    if [ -d ${OTC_NEED_CD_FILE_PATH} ]; then
        cd ${OTC_NEED_CD_FILE_PATH}
    else
        echo "找不到${OTC_NEED_CD_FILE_PATH}下的国元项目OTC资源文件, 请验证gitmoudules是否有改动过"
        exit 1
    fi
    git pull origin GuoYuanOTCFiles #拉取国元OTC子模块资源文件 --> www
    echo "otc资源(www文件夹)目录迁移"
    cp -fr ${OTC_FILE_DIRECTORY} ${CURRENT_WORK_PATH}/DK_Phone/Projects/$TARGET_NAME/.
    rm -fr $OTC_FILE_DIRECTORY
    cd $CURRENT_WORK_PATH
}

getRelateWebOriginResource $TARGET_NAME "DK519" "DK"

if [[ "$TARGET_NAME" == "HuaLong_Phone" ]];then
    getRelateWebOriginResource $TARGET_NAME "DKF10" "news"
fi

if [[ "$TARGET_NAME" == "GuoYuan_Phone" ]];then
    getRelateWebOriginResource $TARGET_NAME "XinGuNewsF10" "xinguF10"
    getGuoYuanOTCResource "www"
fi

echo ============= 3. 执行 iOS 打包脚本 =============
# 3. 执行 iOS 打包脚本，传入应用名、打包证书描述文件名 等参数
# 打包生成的 ipa 文件目录名
# 注： yml 中取最终生成的安装包，也必须是此路径下
PRODUCT_FILE_PATH="PackedFiles"

# 此处入参顺序必须和 autobuild.sh 一致
# 依次传入 target name、PRODUCT_FILE_PATH、打包方式、证书描述文件名
sh ./auto-build.sh ${TARGET_NAME} $PRODUCT_FILE_PATH $buildConfig $Mobile_Provision_File_Name

if [ "$?" -ne "0" ]
then
    echo "构建 stop"
    exit 1
fi

echo ============= 4. 将生成的安装包移动到下载服务器 =============

# 拼接生成的 ipa 文件名
TIME=`date "+%F   %H:%M"`
NOW=`date +%G%m%d%H%M`
git_version=`git log --oneline -1|cut -c1-7`
production_version=`cat ${CURRENT_WORK_PATH}/DK_Phone/Projects/$TARGET_NAME/$TARGET_NAME-Info.plist |grep -A 1   "ShortVersionString"|grep "string"|cut -c10-14`
if [[ "$branch" == "master" ]]; then
    build_name=${Customer}-phone-${production_version}-${NOW}-online-enterprise-${git_version}
elif [[ "$branch" == "develop" ]]; then
    build_name=${Customer}-phone-${production_version}-${NOW}-online-enterprise-${git_version}-dv
elif [[ "$branch" == "release" ]]; then
    build_name=${Customer}-phone-${production_version}-${NOW}-online-enterprise-${git_version}-rc
else
    build_name=${Customer}-phone-${production_version}-${NOW}-online-enterprise-${git_version}-dv
fi
cd ${CURRENT_WORK_PATH}
mv ./$PRODUCT_FILE_PATH/${TARGET_NAME}.ipa ./${build_name}.ipa

ssh root@192.168.1.1 "[ -d /DK/build/auto-client/iOS/$Production_Chinese ]" || (mkdir $Production_Chinese && scp -r $Production_Chinese root@192.168.10.110:/DK/build/auto-client/iOS/)
if [ "$branch" == "master" ]||[ "$branch" == "release" ]||[ "$branch" == "develop" ]; then
    scp ./${build_name}.ipa   root@192.168.1.1:/DK/build/auto-client/iOS/$Production_Chinese/.
    echo ================ 生成的 ipa 包在 ftp 上的路径为： ==================
    echo smb://192.168.10.110:/DK/build/auto-client/iOS/$Production_Chinese/${build_name}.ipa
else
    echo ================ 当前打包应用为 $Production_Chinese ==================
    echo '非 develop、master、release 分支打包出的 ipa 文件不会被备份到 ftp ，请在页面右上角下载处取用'
fi

# 上传到 ota 下载页面
sh ./auto-ota-upload.sh $TARGET_NAME $PRODUCT_FILE_PATH $build_name $branch

# 移除iOS项目中的 h5 源码
rm -fr ./DK_Phone/Projects/${TARGET_NAME}/$TRADE_H5_FILE_DIRECTORY
