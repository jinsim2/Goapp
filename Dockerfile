# 베이스 이미지를 작성하고 AS 절에 단계 이름을 지정한다.
FROM golang:1.15-alpine3.12 AS gobuilder-stage

# 작성자와 설명을 작성한다.
MAINTAINER "jakang <jskang@itwillbs.co.kr>"
LABEL "purpose"="Service Deployment using Multi-stage builds."

# /usr/src/goapp 경로로 이동한다.
WORKDIR /usr/src/goapp

# 현재 디렉터리의 goapp.go 파일을 이미지 내부의 현재 경로에 복사한다.
COPY goapp.go .

# Go 언어 환경 변수를 지정하고 /usr/local/bin 경로에 gostart 실행 파일을 생성한다.
# CGO_ENABLED=0 : cgo 비활성화. 스크래치(scratch) 이미지에는 C 바이너리가 없기 때문에
# cgo를 비활성화한 후 빌드해야 한다.
# GOOS=linux GOARCH=amd64 : OS와 아키텍처 설정
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /usr/local/bin/gostart

# 두 번째 단계. 두 번째 Dockerfile을 작성한 것과 같다. 베이스 이미지를 작성한다.
# 마지막 컨테이너로 실행되는 단계이므로 일반적으로 단계명을 명시하지 않는다.
FROM scratch AS runtime-stage

# 첫 번째 단계의 이름을 --from 옵션에 넣으면 해당 단계로부터 파일을 가져와서 복사한다.
COPY --from=gobuilder-stage /usr/local/bin/gostart /usr/local/bin/gostart

# 컨테이너 실행 시 파일을 실행한다.
CMD ["/usr/local/bin/gostart"]
