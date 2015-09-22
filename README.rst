
=======================
gtapp-ios-oc
=======================

为了方便第三方开发者快速集成微博 SDK，我们提供了以下联系方式，协助开发者进行集成。

QQ群: 487868018 (iOS) 请注明验证信息

关于SDK的Bug反馈、用户体验、以及好的建议可以在Github或QQ群提交给我们，我们会讨论合理性后会尽快跟进。

.. contents:: 目录
.. sectnum::

Screenshot
==================
.. image:: img/demo_0.png

.. image:: img/demo_1.png

.. image:: img/demo_2.png

Version
================

1.  请认真查阅开发者文档,支持iOS7以上.[*please read developer doc, and support iOS7+*]
#.  在gtapp-ios-oc项目下已经有两个版本，一个是早期版本，framework版本号为2.15.5.*之前,已经停止开发,另一个是有failback版本的,版本号为2.15.8.*之后的版本,现在持续更新和维护中。[*There are two versions of GTFramework. The latest one has the failback feature (version 2.15.8.* +). We had stopped to develop the old version. So we recommend you to use the failback version.*]
#.  failback版本在项目路径的‘gt-iOS-sdk-failback -demo’下。[*the failback version in the file 'gt-iOS-sdk-failback -demo'*]
#.  推荐failback版本！！！该版本更为安全，即使极验服务暂时不可用，网站主在相应逻辑位置写入备用验证或处理方法，即可轻松切换。[*The faiback version more safe than the old one. If gt-server is not available, you can set some handle methods.*]

gtapp-ios-oc
======================

1.	GTFramework 极验验证iOS版本的SDK，生成一个基于i386、x86_64、armv7、 armv7s、arm64的framework，支持iOS7.0＋。开发使用的Xcode版本位Xcode 7.0。[*build on i386、x86_64、armv7、 armv7s、arm64, and support iOS7+ *]
#.	gt-iOS-sdk-demo 调用sdk的演示app程序。 [*use demo to know more about GTFramework*]
#.	演示项目提供了完整的一次验证，并将客户端验证结果向示例的客户服务器上发起二次验证的完整通讯过程。[*in the demo, we use MKNetworkKit as third network*]
#.	二次验证使用MKNetworkKit用于演示，可根据网站主项目需要自行修改。[*you can change what you want in the demo*]
#.  如果使用failback版本的请下看项目路径下‘gt-iOS-sdk-failback -demo’ [*the failback version in the file 'gt-iOS-sdk-failback -demo'*]

使用以上步骤，用户可以运行Demo示例
================================================

自建项目引用
假设用户自建项目名称为：TestGT

1.	在极验官方主页www.geetest.com注册账号并申请相应的应用公钥，id:{{id}}。[*get geetest id/key from `geetest.com   <http://www.geetest.com>`__*]
#.	将gt-iOS-sdk下的GTFramework项目生成的静态库GTFramework.framework引入到项目中 [*import GTFramework to your preject*]
#.	将GTFramework.framework项目以Static Library的方式进行引用。将所需的GTFramework.framework拷贝到工程所在文件夹下。在 TARGETS->Build Phases-> Link Binary With Libaries中点击“+”按钮，在弹出的窗口中点击“Add Other”按钮，选择GTFramework.framework文件添加到工程中。[*add GTframework to 'Link Binary With Libaries'*]
     
#.	在项目标有TODO注释的地方写入网站主自已的处理代码。[*add you handle method where signed 'TODO'*]

iOS9的适配问题
==================

iOS9适配详细可跳转至`iOS9适配tips   <https://github.com/ChenYilong/iOS9AdaptationTips>`__

1. 对网络传输安全协议https的支持
    由于 iOS 9 改用更安全的https，为了能够在iOS9中正常使用http，请在"Info.plist"中进行如下配置，否则影响网络的使用。
    暂时的解决方案:
    方案A:
    强制将NSAllowsArbitraryLoads属性设置为YES，并添加到你应用的plist中

    .. code ::

    <key>NSAppTransportSecurity</key>
    <dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    </dict>

    方案B:
    建立白名单并添加到你的app的plsit中

    .. code ::

    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSExceptionDomains</key>
        <dict>
            <key>geetest.com</key>
            <dict>
                <key>NSIncludesSubdomains</key>
                <true/>
                <key>NSThirdPartyExceptionAllowsInsecureHTTPLoads</key>
                <true/>
                <key>NSThirdPartyExceptionRequiresForwardSecrecy</key>
                <false/>
            </dict>
        </dict>
    </dict>

2. bitcode
    苹果在iOS9的SDK中添加了对应用的瘦身的支持，其中就包括bitcode。我们目前也在对SDK添加对bitcode的支持。你可以用demo目录下的"GTFramework_bitcode"去掉后缀后的替换原GTFramework文件。（通过设置编译标志ENABLE_BITCODE = NO，或者修改工程的构建设置(build settings)可关闭bitcode功能）
	
回调Block及返回值
===========================

.. code ::
	
    Block：
	   ^(NSString *code, NSDictionary *result, NSString *message) {} 
	
返回值：

1.code
    成功或者失败的值（1：成功/其他：失败）
    status code, (1: success/2: fail)
2.message
    成功或者失败的信息（success/fail）
    description about you result
3.result
    详细的返回信息，用于向客户服务器提交之后的SDK二次验证信息
    if you want to finish Secondery-Validate ,you should send those result information to your server.
	
.. code ::

    {
     "geetest_challenge": "5a8c21e206f5f7ba4fa630acf269d0ec4z",
     "geetest_validate": "f0f541006215ac784859e29ec23d5b97",
     "geetest_seccode": "f0f541006215ac784859e29ec23d5b97|jordan"
     }
