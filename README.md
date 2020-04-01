# Notion-to-GitHub-Pages

## Notion-to-GitHub-Pages란?

Notion에서 작성한, 특히 이미지를 포함한 페이지를 GitHub Pages 기반(jekyll) 블로그의 형식에 맞게 변환 후 자동으로 업로드해주는 shell script입니다.
Notion에서 페이지 export만 해주면, 명령어 한 번으로 이미지까지 잘 나오도록 github에 업로드가 가능합니다.

- Notion 2.0.7 버전의 export 형식에 맞춰 만들어졌습니다.

## 기능

- Notion에서 export한 markup 파일 및 이미지 폴더를 GitHub Pages의 Jekyll서비스의 post 형식에 맞게 이름 및 경로를 변환해줍니다.
    - md파일은 파일명을 *날짜-{notion note의 제목}.md*로 변환 후 *_posts* 폴더로 이동됩니다.
    - image폴더는 폴더명을 *날짜-{notion note의 제목}*로 변환 후, *assets/images* 폴더로 이동됩니다.
    - md파일 내 image 경로또한 이에 맞게 수정됩니다.
- jekyll 메타정보 중 *title, meta_date, meta_last_modified_at*를 자동으로, *subtitlem categories, tags*를 수동으로 입력받아 넣어줍니다.
- 변환된 파일을 Git에 add시켜줍니다.

## 이용방법

1. *notion_to_github_pages.sh* 파일을 다운로드하여, 본인 local PC의 GitHub Pages root 폴더(이하 *GitHub Pages root*)로 옮깁니다.

2. Notion app에서 GitHub Pages에 업로드하고자 하는 Notion 노트를 *Markdown & CSV* 형식으로 export합니다.
    ![./assets/images/2020-03-31-README/Untitled.png](./assets/images/2020-03-31-README/Untitled.png)

3. Notion에서 export한 zip 파일을 본인 local PC의 *GitHub Pages root* 경로로 옮깁니다.
    ![./assets/images/2020-03-31-README/Untitled%202.png](./assets/images/2020-03-31-README/Untitled%202.png)
    
4. Local 컴퓨터의 Shell에서 *GitHub Pages root* 경로로 이동 후, 다음을 입력하여 *notion_to_github.sh* 파일을 실행합니다.

        `bash notion_to_github_pages.sh`

5. (optional) 화면 설명에 따라 jekyll 메타정보(subtitlem categories, tags)를 차례로 입력해주면 처리가 완료됩니다.
- 메타정보를 넣고싶지 않다면 그냥 엔터를 누르시면 됩니다.
- 이 단계를 통해 *git add*까지 자동처리됩니다.
   ![./assets/images/2020-03-31-README/Untitled%201.png](./assets/images/2020-03-31-README/Untitled%201.png)


6. *git status*를 통해 상태 확인 후, *git push*를 통해 GitHub Pages 업로드합니다.

## 참고 사항(V0.1(현재) 기준)
- 기본적으로 uoneway.github.io root 경로의 *_posts*폴더로 post 파일을, *assets/images/{포스팅명}* 폴더로 image 파일을 업로드합니다.
만약 본인 블로그의 post 및 이미지 경로가 이와 상이하다면, *notion_to_github_pages.sh* 파일 내 다음부분을 수정하셔서 사용하시면 됩니다.

    `# REPLACE THIS as your github.io structure`

    `posts_folder_path='_posts'`

    `images_folder_path='assets/images'`

- 한 번에 여러 노트를 업로드하고 싶다면 각각의 노트를 개별 export하여 파일을 만들어야 합니다.
- image를 하나라도 포함하고 있는 Notion 노트(export 했을 때, *export-.../zip*으로 파일이 생성되는 경우)만 이용 가능합니다.

## 업데이트 사항

### V0.11(현재)
- bug fix: 공백을 가지고 있는 파일명의 경우에 파일명을 제대로 가져오지 못하는 문제 수정됨

### V0.2(예정)

- image를 포함하지 않고 있는 Notion 노트도 이용
- page 추가 기능
- 사용자 원하는 메타데이터 추가 기능
- 적용 전에 입력 정보를 확인할 수 있는 기능

제가 당장 쓰려고 만든거라 버그가 있을 수 있습니다. 피드백 및 문의, fork 언제나 환영합니다 :)
