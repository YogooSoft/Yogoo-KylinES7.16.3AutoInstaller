# ansible-playbook

## role development
```
  ansible-galaxy init {ROLE_NAME}
```

# Role definition
- elasticsearch
    - 作用
    - 任务
    - 场景
- logstash
    - 作用 
    - 任务
    - 场景
- kibana
    - 作用
    - 任务
    - 场景
    
# Choosable variables    
| 变量            | 可选项                             | 类型   | 说明                                | 默认值    |
| --------------- | ---------------------------------- | ------ | ----------------------------------- | --------- |
| skip_steps      | system<br />install<br />configure | 数组   | 跳过不执行的步骤                    | 空数组    |
| action          | full-restart<br />rolling-restart  | 字符串 | 执行的动作，不定义则不执行          | undefined |
| skip_action_api | true<br />false                    | 字符串 | 是否跳过执行 action 阶段的 api 请求 | false     |
| xpack_security  | true<br />false                    | 字符串 | 开启 xpack 安全功能                 | false     |

