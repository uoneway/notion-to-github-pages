#!/bin/bash

# Author: Kim Hangil(uoneway). 
# URL: https://github.com/uoneway/Notion-to-GitHub-Pages
# Contact: uoneway@gmail.com


# REPLACE THIS as your github.io structure
posts_folder_path='_posts' # 여기서 /을 앞에 넣으면 안됨. 이미지 경로 할때는 앞에 / 넣어줘야 url상에서 image폴더 찾을 수 있지만 로컬에서 실행할때는 루트로 들어가기에...
images_folder_path='assets/images'

# Name regexp of exported zip file from Notion
exported_zip_reg="Export-*.zip"


echo "##### Welcome to Notion-to-GitHub-Pages! #####"


# exported_zip_reg 규칙에 맞는 zip파일 이름 목록 가져오기. 
# https://stackoverflow.com/questions/23356779/how-can-i-store-the-find-command-results-as-an-array-in-bash
unzd() {
    if [[ $# != 1 ]]; then echo I need a single argument, the name of the archive to extract; return 1; fi
    target="${1%.zip}"
    if [ -d "$target" ]; then # 압축 풀린 폴더가 존재할 경우, 
        echo "There are folder have same name. So we don't do unzip"
    else
        unzip -qq "$1" -d "${target##*/}" # -qq outputting 없이 수행
    fi
}

exported_foldername_array=()
while IFS=  read -r -d $'\0'; do
    unzd "$REPLY"
    exported_foldername_array+=($(basename "${REPLY%.*}")) # 앞에 ./와 뒤 확장자 제거
done < <(find . -maxdepth 1 -name "$exported_zip_reg" -print0 )

if [ ${#exported_foldername_array[*]} -lt 1 ]; then  # exported_zip_reg 규칙에 맞는 zip파일이 없다면 프로그램 종료
    echo -e "ERROR: There are no zip file named 'Export...'. \nExport zip file from Notion and move it to your local github page root folder."
    exit 100
fi


# Exported folder 별로 다음을 시행
for exported_foldername in ${exported_foldername_array[*]}; do
    
    # 적용안함 : 파일명에 공백있는 경우: 문제가 생길 수 있으므로 파일명에 있는 공백을 '_'로 바꿔줌
    #for f in $exported_foldername/*\ *
    #do mv "$f" "${f// /_}"; done

    # exported_filename 추출하기
    exported_filename=""
    for entry in ./$exported_foldername/*.md
        do exported_filename=$(basename "${entry%.*}"); done #여기서 ""안해주면 파일명에 공백있을경우 앞만 받아옴. 꼭 해주기

    exported_file_path="$exported_foldername/$exported_filename.md"

    # title값 추출하기(첫번째 줄에 #으로 시작하는 문자열이 있는 경우, title로 인식)
    meta_title=$(head -n 1 "$exported_file_path")
    if [[ $meta_title != "# "* ]]; then  # 맨 앞이 #으로 되어있는지 확인해서 아니면, 직접 입력받기
    	echo -n "Enter a title of the post:"
        read  meta_title
    fi
    meta_title=$(echo "$meta_title" | sed 's/# //g')
    
    echo "For the \"$meta_title\" post..."

    # Title값은 URL에 사용될 것이므로 기호가 포함되어 있다면 변환해줌. 
    # 일반 URL encoding써도 되지만 한글도 모두 변환되어 버리기에 임의로 기호를 바꿔줌
    meta_title_encoded=$(echo "$meta_title" | sed 's/[][\\^*+=,!?.:;&@()$-]/-/g' | sed 's/# //g' | sed 's/ /-/g' | sed 's/--/-/g')


    # Jekyll에서 사용되는 meta 정보 추가하기
    echo -n "Enter a subtitle: "
    read  meta_subtitle
    echo -n "Enter categories: "
    read  meta_categories
    echo -n "Enter tags: "
    read  meta_tags

    meta_date="$(date +%Y)-$(date +%m)-$(date +%d) $(date +%H):$(date +%M):$(date +%S) +0000"
    meta_last_modified_at="$(date +%Y)-$(date +%m)-$(date +%d) $(date +%H):$(date +%M):$(date +%S) +0000"

    # 한 줄씩 추가하기(한 번에 하려고 했더니 /n 줄바꿈이 문자열 그대로 md에 입력되어 한줄씩 추가로 수정)
    # OS X ships with BSD sed, where the suffix for the -i option(changes made to the file) is mandatory. Try sed -i ''
    # https://stackoverflow.com/questions/16745988/sed-command-with-i-option-in-place-editing-works-fine-on-ubuntu-but-not-mac
    sed -i '' "1s|.*|---|" "$exported_file_path"
    sed -i "" -e $'1 a\\\n'"title: $meta_title" "$exported_file_path" #title은 Notion 제목값으로 자동 입력
    sed -i "" -e $'2 a\\\n'"subtitle: $meta_subtitle" "$exported_file_path" # https://unix.stackexchange.com/questions/52131/sed-on-osx-insert-at-a-certain-line
    sed -i "" -e $'3 a\\\n'"categories: $meta_categories" "$exported_file_path"
    sed -i "" -e $'4 a\\\n'"tags: $meta_tags" "$exported_file_path"
    sed -i "" -e $'5 a\\\n'"date: $meta_date" "$exported_file_path"
    sed -i "" -e $'6 a\\\n'"last_modified_at: $meta_last_modified_at" "$exported_file_path"
    sed -i "" -e $'7 a\\\n'"---" "$exported_file_path"


    # Making a post file name
    fixed_filename="$(date +%Y)-$(date +%m)-$(date +%d)-$meta_title_encoded"

    # Changing a image path in exported_filename.md
    exported_filename_for_images_path=$(echo "$exported_filename" | sed 's/ /%20/g') # 파일명에 공백있는 경우: %20으로 수정. 추후 md 내 이미지 경로에 이용
    sed -i '' "s|"$exported_filename_for_images_path"/Untitled|/$images_folder_path/$fixed_filename/Untitled|g" "$exported_file_path"


    # Changing a file name and move
    # If directories not exist, make it. 
    mkdir -p $posts_folder_path
    mkdir -p $images_folder_path

    mv -i -v "$exported_file_path" "$posts_folder_path/$fixed_filename.md"
    mv -i -v "$exported_foldername/$exported_filename" "$images_folder_path/$fixed_filename"

    # git add
    git add "$posts_folder_path/$fixed_filename.md"
    git add "$images_folder_path/$fixed_filename"
    git commit -m "$fixed_filename is uploaded"

    rm -r "$exported_foldername"
    rm -r "$exported_foldername.zip"

    echo -e "Work for the $meta_title post is completed!\n"
done


# git push
