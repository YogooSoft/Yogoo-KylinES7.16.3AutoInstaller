# 使用案例

## 背景
某公司有 3 个 es 相关的项目：
1. 项目 A 服务于电商部门， 他们的使用场景是做搜索加速，他们会将 mysql 的数据实时同步到 es 用作商品和订单搜索。 es 集群名叫 order_service。
2. 项目 B 服务于运维部门，他们的使用场景是做日志平台，会用到 es、logstash、kibana， es 集群名叫 logging_service。
3. 项目 C 服务于数据分析部门，他们会把数据导入到 es 做业务分析，会用到 es, kibana， es 集群名叫 data_service。

ES 团队接到 3 个项目组的需求后开始做规划: 他们需要准备一个 inventory 文件用来描述集群拓扑结构。
为了便于管理不同项目的 inventory，他们规定文件名按以下规则指定：{节点类型}-{集群名}

## 规划部署
### 项目 A
ES 团队评估现阶段只需要 3 个混合 es 节点，因此准备了以下 inventory：

*es-order_service*

```
[elasticsearch:vars]
project_name=order_service
version=6.7.2
path_base=/home/user/order_service
jvm_heap_memory=30g

[elasticsearch]
es-1  ansible_host=172.18.1.100
es-2  ansible_host=172.18.1.101
es-3  ansible_host=172.18.1.102
```
然后执行:
`ansible-playbook -i es-order_service elasticsearch-setup.yml`

随着脚本运行结束，集群已经部署完成了，终端输出了 elastic 账号的密码信息。

### 项目 B
ES 团队评估现阶段需要 3 个 es 数据节点，3 个 logstash 节点，1 个 kibana 节点

其中 logstash 的 pipeline 文件位于: http://172.18.2.100:8000/main.yml

因此准备了以下 3 个 inventory：

*es-logging_service*

```
[elasticsearch:vars]
project_name=logging_service
version=6.7.2
path_base=/home/user/logging_service
jvm_heap_memory=30g

[elasticsearch]
es-1  ansible_host=172.18.2.100
es-2  ansible_host=172.18.2.101
es-3  ansible_host=172.18.2.102
```

*logstash-logging_service*
```
[logstash:vars]
project_name=logging_service
version=6.7.2
path_base=/home/user/order_service
jvm_heap_memory=8g
pipelines_download_url=http://172.18.2.100:8000
pipelines=[{"pipeline.id":"main"}]

[logstash]
ls-1  ansible_host=172.18.2.100
ls-2  ansible_host=172.18.2.101
ls-3  ansible_host=172.18.2.102
```

*kibana-logging_service*
```
[kibana:vars]
project_name=order_service
version=6.7.2
es_hosts=['http://172.18.2.100:9200']
path_base=/home/user/order_service

[kibana]
kb  ansible_host=172.18.2.100
```

然后分别执行:
- `ansible-playbook -i es-order_service elasticsearch-setup.yml`
- `ansible-playbook -i logstash-order_service logstash-setup.yml`
- `ansible-playbook -i kibana-order_service kibana-setup.yml`

随着脚本运行结束，es、logstash 和 kibana 都完成了部署。

### 项目 C
ES 团队评估现阶段需要 3 个 es 数据节点，，1 个 kibana 节点，因此准备了以下 3 个 inventory：

*es-data_service*

```
[elasticsearch:vars]
project_name=data_service
version=6.7.2
path_base=/home/user/data_service
jvm_heap_memory=30g

[elasticsearch]
es-1  ansible_host=172.18.3.100
es-2  ansible_host=172.18.3.101
es-3  ansible_host=172.18.3.102
```

然后分别执行:
- `ansible-playbook -i es-data_service elasticsearch-setup.yml`
- `ansible-playbook -i kibana-data_service kibana-setup.yml`

随着脚本运行结束，es 和 kibana 都完成了部署。

## 集群扩容
过了一段时间，项目 A 业务量越来越大，对 ES 的搜索要求越来越高，逐渐达到了集群的性能瓶颈，因此需要进行扩容。

ES 团队评估后，决定扩容 3 个节点，因此修改了 inventory:

*es-order_service*

```
[elasticsearch:vars]
project_name=order_service
version=6.7.2
path_base=/home/user/order_service
jvm_heap_memory=30g

[elasticsearch]
es-1  ansible_host=172.18.1.100
es-2  ansible_host=172.18.1.101
es-3  ansible_host=172.18.1.102
es-4  ansible_host=172.18.1.103
es-5  ansible_host=172.18.1.104
es-6  ansible_host=172.18.1.105
```

然后执行:
`ansible-playbook -i es-order_service elasticsearch-setup.yml`

观察发现新增的节点已经加入集群

## 拆分角色

项目 B 运行一段时间后，随着数据量的增大，也有了扩容需求。

ES 团队评估后，认为引入冷热分离架构比较合适，同时加入独立的主节点和协调节点来保证集群的稳定性，因此修改了 inventory:

*es-logging_service*

```
[elasticsearch:vars]
project_name=logging_service
version=6.7.2
path_base=/home/user/logging

[elasticsearch:children]
elasticsearch-master
elasticsearch-data
elasticsearch-coordinating

[elasticsearch-master:vars]
roles=['master']
jvm_heap_memory=8g
[elasticsearch-master]
es-master-1  ansible_host=172.18.2.100 
es-master-2  ansible_host=172.18.2.101
es-master-3  ansible_host=172.18.2.102

[elasticsearch-data:vars]
roles=['data']
jvm_heap_memory=30g
[elasticsearch-data]
es-data-1  ansible_host=172.18.2.100 box_type=hot
es-data-2  ansible_host=172.18.2.101 box_type=hot
es-data-3  ansible_host=172.18.2.102 box_type=hot
es-data-4  ansible_host=172.18.2.103 box_type=warm
es-data-5  ansible_host=172.18.2.104 box_type=warm
es-data-6  ansible_host=172.18.2.105 box_type=warm

[elasticsearch-coordinating:vars]
roles=['coordinating']
jvm_heap_memory=16g
[elasticsearch-coordinating]
es-coordinating-1  ansible_host=172.18.2.100 
es-coordinating-2  ansible_host=172.18.2.101
es-coordinating-3  ansible_host=172.18.2.102
```
然后执行:
`ansible-playbook -i es-order_service elasticsearch-setup.yml -e action=restart`

等待集群重启后，发现新的角色配置已经生效，扩容的节点已经加入集群

## 集群升级

最近 ES 发布了新的版本，其中对 machine learning 功能的更新对项目 C 价值很大

经过测试后，ES 团队接到需求需要对项目 C 的 ES 进行升级，且升级过程中不能停止服务。因此 ES 团队修改了 inventory:

*es-data_service*

```
[elasticsearch:vars]
project_name=data_service
version=6.8.6
path_base=/home/user/data_service
jvm_heap_memory=30g

[elasticsearch]
es-1  ansible_host=172.18.3.100
es-2  ansible_host=172.18.3.101
es-3  ansible_host=172.18.3.102
```
然后执行:
`ansible-playbook -i es-data_service elasticsearch-setup.yml -e action=rolling-restart`

随着节点一台一台滚动升级，整个集群最终完成了升级

1. 某用户要修改 es 配置，如何操作
2. 某用户要修改 logstash 配置，如何操作
3. 某用户要重启集群，如何操作？fullrestart 和 rolling restart
