### 项目用途

本项目实现个人的目的：

1. 实践infrastructure as code。
2. 基于infrastructure as code的基础上，搭建个人的VPN服务器。
3. VPN服务器按需创建，按需停止。灵活计费。

### 技术堆栈
1. terraform
2. packer
3. ansible
4. docker
5. ikev2的VPN协议

### 实现思路
1. 使用packer，构建自定义的镜像。（安装了docker,并用docker运行一个ikev2的容器)
2. 使用terraform，在阿里云创建自定义的服务器，并生成ikev2所用的文件，自动下载至本地（ikev2-vpn.mobileconfig)
3. 本地双击ikev2-vpn.mobileconfig，自动配置实现VPN连接。

### 文件介绍

<pre>
├── README.md
├── ansible
│   ├── ansible.cfg
│   ├── compose
│   ├── fact_files
│   ├── ikev2-packer-custom-image.yml   ##terraform使用ansible 作为provisioner的文件
│   ├── ikev2-packer-image-build.yml  ##packer使用ansible 作为provisioner的文件
│   ├── ikv2-all-in-one.yml ## 不使用packer的，直接terraform构建的文件。
│   ├── inventory.ini ## ansible默认配置文件
│   └── roles ## ansible用到的roles，可以不用下载。
├── main.tf ## terraform主文件
├── outputs.tf ## terraform输出控制文件
├── packer-alicloud-image.json ## packer的配置文件
└── variables.tf ## terraform的变量，最主要的配置文件。
</pre>

### 执行步骤
1. 拥有阿里云帐号，并获取到access_key和secret_key.
2. 本地拥有密钥对。默认是~/.ssh/id_rsa和~/.ssh/id_rsa.pub.
3. 初始化变量文件

	```bash
    cp variables.tf.example variables.tf
	```

4. 运行packer构建镜像

	```bash
	## 这个过程可能持续十分钟左右
	packer build packer-alicloud-image.json
	## 上述命令执行完之后，随后会出现如下字样，冒号后面就是image_id.使用这个值替换variables.tf文件中的image_id的default值。
	## us-west-1: m-xxkdas
	```

5. 配置terraform
	
	> 使用上述步骤中获取的image_id，替换variables.tf中的image_id的default值。
	> 使用本地~/.ssh/id_rsa.pub中的内容，替换variables.tf中的public_key的default值。

6. 执行terraform，这个命令做了如下事情：

	```bash
	terraform plan
	terraform apply
	```
      - 在阿里云创建一台按量付费的机器，机器开放端口22，500，4500，机器配置为1C1G,上面使用docker运行一个ikev2的服务端。
	- 调用ansibe/ikev2-packer-custom-image.yml文件，在服务器端生成配置文件，并下载到本地的~/Downloads/ikev2-vpn.mobileconfig



7. 上述命令执行完成后，会在~/Downloads下出现ikev2-vpn.mobileconfig文件，双击运行。

	> 这个文件路径可以在ansible/ikev2-packer-custom-image.yml最后一行进行修改。


8. 销毁机器，会释放阿里云机器，不在计费。

	```bash
	terraform destroy
	```

### 感悟
	1. 只写了一些ansible的一些脚本。其他实现都是基于配置文件实现。
	2. 对infrastructure as code有了实践之后的认知。
	3. 准备阅读terraform代码，并给一些第三方的provisioner做点贡献。
	4. 突破自己的想象力。我猜测在世界范围内，我可能是基于这种玩法的第一人。
	5. 其实折腾这么多，主要是为了扫清学习kubernetes遇到的一些网络方面的障碍。虽然我翻墙技术还不错，但是kubernetes需要的相关资源，还是只能走纯粹的VPN方式。
