# GbFoundry

## 配置

配置inventory

配置yaml

## 安装
1. 下载 gbfoundry：

```bash
mkdir -p /data/nova
cd /data/nova
git clone -b master https://nova-robot:Gb123456@git@10.100.11.110:nova/gbfoundry.git
```
2. 安装依赖
```shell
sh online-deploy.sh deps
```

3. 安装k8s
```shell
sh online-deploy.sh infra
```
4. 安装服务（基础服务及业务mes等）
```shell
sh online-deploy.sh product
```

至此整套系统就安装好了。

上面的步骤都是可以重复执行的，如果哪里有改动，可以在改动后再运行一遍相应的步骤。

## 更新
#### 更新某一组件的实例

查看组件的实例的名称：

```bash
helmfile list
```

(可选) 若想销毁某个组件的实例，可以先 destroy：

```bash
cd /data/nova/gbfoundry && helmfile -l name=mes-default destroy
```

更新某个组件的实例：

```bash
cd /data/nova/gbfoundry && helmfile -l name=mes-default sync
```

更多命令请参考 `helmfile --help`。
