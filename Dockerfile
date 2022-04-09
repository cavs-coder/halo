#使用jdk8作为基础镜像
#FROM java:11
FROM adoptopenjdk:11-jre-hotspot as builder
#指定作者
MAINTAINER fgw
#这里的 /tmp 目录就会在运行时自动挂载为匿名卷，任何向 /data 中写入的信息都不会记录进容器存储层
VOLUME /tmp
#暴漏容器的18090端口
EXPOSE 18090
#应用构建成功后的jar文件被复制到镜像内，名字也改成了halo.jar
ADD /target/halo-1.0.0-SNAPSHOT.jar halo.jar
#RUN新建立一层，在其上执行这些命令，执行结束后， commit 这一层的修改，构成新的镜像。
RUN bash -c 'touch /halo.jar'
#设置时区
ENV JVM_XMS="256m" \
    JVM_XMX="256m" \
    JVM_OPTS="-Xmx256m -Xms256m" \
    TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
#相当于在容器中用cmd命令执行jar包  指定外部配置文件
ENTRYPOINT java -Xms${JVM_XMS} -Xmx${JVM_XMX} ${JVM_OPTS} -Djava.security.egd=file:/dev/./urandom -server -jar halo.jar