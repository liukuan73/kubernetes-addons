用于k8s集群日志采集的fluentd镜像的构建和部署文件
build目录用于在该目录下进行镜像构建：docker build -t liukuan73/fluentd:0.14.25 .
k8s-yamls目录中是用于将fluentd部署到k8s环境所需的yaml文件

