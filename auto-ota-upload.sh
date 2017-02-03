# 将生成的 ipa 文件上传

if [ "$target_name" == "DK_Phone" ] && [ "$current_branch"=="feature/ci-autopackage" ]; then

	echo "=========== 上传到公司发布平台 ==========="

	target_name=$1      # 当前分支名
	ipa_file_path=$2    # 生成的包路径
	build_ipa_name=$3   # 最终包名
	current_branch=$4   # 当前分支名

	echo "当前分支名:$1"
	echo "生成的包路径:$2"
	echo "最终包名:$3"
	echo "当前分支名:$4"

# Test: 先在 标准版、 feature/ci-autopackage 上测试上传到 OTA
# if [ "$target_name" == "DK_Phone" ] && [ "$current_branch"=="feature/ci-autopackage" ]; then
    echo "start upload..."
    pwd
    ls ./$ipa_file_path/
    scp ./$ipa_file_path/$build_ipa_name.ipa DK@192.168.1.1:/app-store/data/app.ipa
    echo "end success"
fi
