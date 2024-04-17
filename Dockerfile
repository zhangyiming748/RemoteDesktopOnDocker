# alpine-vnc - A basic, graphical alpine workstation
# includes xfce, vnc, ssh
# last update: May/29/2022
FROM alpine:3.19
# 设置环境变量ENV '$HOME/.ashrc'，用于初始化非登录shell的文件。
ENV ENV '$HOME/.ashrc'
# 设置默认屏幕分辨率为1280x800x24。
ENV XRES 1280x800x24
# 设置默认时区为Asia/Shanghai
ENV TZ Asia/Shanghai
# 修改apk源地址为清华大学的镜像源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
# 更新系统并升级软件包
RUN apk update && apk upgrade
# 安装sudo、supervisor、openssh-server、nano、tzdata等软件包
RUN apk add sudo supervisor openssh-server openssh nano tzdata wqy-zenhei bash font-adobe-100dpi font-noto ttf-dejavu
#安装xvfb和x11vnc，用于支持VNC服务。
RUN apk add xvfb x11vnc
# 安装xfce4桌面环境和相关插件
RUN apk add xfce4 xfce4-terminal xfce4-xkb-plugin mousepad adwaita-icon-theme
# 添加一个名为alpine的主用户
RUN adduser -D alpine
# 修改root和alpine用户的密码，并赋予alpine用户sudo权限
RUN 	echo "root:alpine" | /usr/sbin/chpasswd \
    && 	echo "alpine:alpine" | /usr/sbin/chpasswd \
    && 	echo "alpine ALL=(ALL) ALL" >> /etc/sudoers
# 创建/run/sshd目录，并生成SSH密钥对
RUN 	mkdir /run/sshd \
	&& 	ssh-keygen -A
# 将自定义的配置文件添加到/etc目录下
ADD etc /etc
# 为alpine用户设置别名，并将其添加到.profile文件中
RUN 	echo "alias ll='ls -l'" > /home/alpine/.ashrc \
	&& 	echo "alias lla='ls -al'" >> /home/alpine/.ashrc \
	&& 	echo "alias llh='ls -hl'" >> /home/alpine/.ashrc \
	&& 	echo "alias hh=history" >> /home/alpine/.ashrc \
	#
	# ash personal config file for login shell mode
	&& cp /home/alpine/.ashrc /home/alpine/.profile
# 将自定义的xfce4终端配置文件添加到指定位置
ADD config/xfce4/terminal/terminalrc /home/alpine/.config/xfce4/terminal/terminalrc
# 将自定义的xfce4桌面壁纸配置文件添加到指定位置
ADD config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml  \
	/home/alpine/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
# 更改/home/alpine目录的所有者为alpine用户
RUN chown -R alpine:alpine /home/alpine/
# 字体缓存
RUN fc-cache -f -v
# 暴露22和5900端口，分别用于SSH和VNC服务
EXPOSE 22 5900
# 设置容器启动时默认执行的命令为运行supervisord进程管理器
CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
