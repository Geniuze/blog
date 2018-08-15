---
layout: post
title: huaweip20 portal
category: linux
---

华为P20手机不弹PORTAL问题

<!-- more -->


# 环境

- 手机型号手：华为P20
- 软件版本：8.1
- openwrt路由器
- 无线AP


# portal原理

- 手机在连接wifi后会自动发起http请求，根据结果确定是否需要弹出PORTAL认证或者直接提示可上网

# 手机wifi质量检测
- 检测链接：http://connectivitycheck.platform.hicloud.com/generate_204
- 结果分析：
    - 204：http返回204表示该wifi可以直接上网，不需弹PORTAL认证
    - 非204：表示需要弹PORTAL认证（如果发生无法跳转，则变为不可上网）

# 跳转测试
- 使用302跳转：

    GET /generate_204 HTTP/1.1<br>
User-Agent: Dalvik/2.1.0 (Linux; U; Android 8.1.0; EML-TL00 Build/HUAWEIEML-TL00)<br>
Host: connectivitycheck.platform.hicloud.com<br>
Connection: Keep-Alive<br>
Accept-Encoding: gzip<br>

    HTTP/1.1 302 Found<br>
Location: http://192.168.0.1<br>
Content-Type: text/html; charset=utf-8<br>
Content-length: 0<br>
Cache-control: no-cache<br>
Connection: close<br>

> 结论：使用302跳转时，手机不会自动弹出PORTAL（无法自动打开http://192.168.0.1）

- 使用200OK跳转：

    GET /generate_204 HTTP/1.1<br>
User-Agent: Dalvik/2.1.0 (Linux; U; Android 8.1.0; EML-TL00 Build/HUAWEIEML-TL00)<br>
Host: connectivitycheck.platform.hicloud.com<br>
Connection: Keep-Alive<br>
Accept-Encoding: gzip<br>

    HTTP/1.1 200 OK<br>
Content-Type: text/html<br>
Content-length: 79<br>
Connection: keep-alive<br>
<br>
\<!DOCTYPE html><br>
\<script>top.self.location.href=http://192.168.0.1\</script>

> 结论：使用200跳转时，手机会自动弹出PORTAL（自动打开http://192.168.0.1页面）
