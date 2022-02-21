# manylinux
Docker manylinux image for building Linux arm32 / arm64 Python wheel packages

```shell
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

docker buildx build --tag manylibux_2_24 --tag manylibux_2_24:$(date +"%Y%m%d%H") --privileged --platform linux/amd64,linux/arm64,linux/386,linux/arm/v7 --push .
```

```yaml
# yaml-language-server: $schema=https://json.schemastore.org/github-workflow
name: Build Docker Image

# 当 push 到 master 分支，或者创建以 v 开头的 tag 时触发，可根据需求修改
on:
  push:
    branches:
      - main
    tags:
      - v*

env:
  REGISTRY: ghcr.io
  IMAGE: richard-xx/manylinux

jobs:
  build-and-push-slow:
    runs-on: ubuntu-latest

    # 这里用于定义 GITHUB_TOKEN 的权限
    permissions:
      packages: write
      contents: read

    steps:
      - name: Checkout
        uses: actions/checkout@v2

      # 缓存 Docker 镜像以加速构建
      - name: Cache Docker layers
        uses: actions/cache@v2
        with:
          path: /tmp/.buildx-cache
          key: ${{ runner.os }}-buildx-${{ github.sha }}
          restore-keys: |
            ${{ runner.os }}-buildx-

      # 配置 QEMU 和 buildx 用于多架构镜像的构建
      - name: Set up QEMU
        uses: docker/setup-qemu-action@v1

      - name: Set up Docker Buildx
        id: buildx
        uses: docker/setup-buildx-action@v1

      - name: Inspect builder
        run: |
          echo "Name:      ${{ steps.buildx.outputs.name }}"
          echo "Endpoint:  ${{ steps.buildx.outputs.endpoint }}"
          echo "Status:    ${{ steps.buildx.outputs.status }}"
          echo "Flags:     ${{ steps.buildx.outputs.flags }}"
          echo "Platforms: ${{ steps.buildx.outputs.platforms }}"

      # 登录到 GitHub Packages 容器仓库
      # 注意 secrets.GITHUB_TOKEN 不需要手动添加，直接就可以用
      - name: Log in to the Container registry
        uses: docker/login-action@v1
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      # 根据输入自动生成 tag 和 label 等数据，说明见下
      - name: Extract metadata for Docker
        id: meta
        uses: docker/metadata-action@v3
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE }}
          tags: |
            type=schedule,pattern={{date 'YYYYMMDD'}}
            type=ref,event=branch
            type=ref,event=pr
            type=sha
            type=raw,value=latest,enable=${{ github.ref == format('refs/heads/{0}', github.event.repository.default_branch) }}

      # 构建并上传
      - name: Build and push
        uses: docker/build-push-action@v2
        with:
          context: .
          file: ./Dockerfile
          builder: ${{ steps.buildx.outputs.name }}
          platforms: linux/arm64,linux/arm/v7,linux/amd64,linux/386
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=local,src=/tmp/.buildx-cache
          cache-to: type=local,dest=/tmp/.buildx-cache

      - name: Inspect image
        run: |
          docker buildx imagetools inspect \
          ${{ env.REGISTRY }}/${{ env.IMAGE }}:${{ steps.meta.outputs.version }}


```