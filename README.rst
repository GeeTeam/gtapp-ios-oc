
=======================
gtapp-ios-oc
=======================

为了方便第三方开发者快速集成微博 SDK，我们提供了以下联系方式，协助开发者进行集成。
QQ群: 487868018 (iOS)
关于SDK的Bug反馈、用户体验、以及好的建议可以在Github或QQ群提交给我们，我们会讨论合理后会尽快跟进。

.. contents:: 目录
.. sectnum::

Version
================

1.  请认真查阅开发者文档.
2.  在gtapp-ios-oc项目下已经有两个版本，一个是早期版本，framework版本号为2.15.5.*之前,已经停止开发,另一个是有failback版本的,版本号为2.15.8.*之后的版本,现在持续更新和维护中。
3.  There are two versions of GTFramework. The latest one has the failback feature (version 2.15.8.* +). 
4.  failback版本在项目路径的‘gt-iOS-sdk-failback -demo’下。
5.  推荐failback版本！！！该版本更为安全，即使极验服务暂时不可用，网站主在相应逻辑位置写入备用验证或处理方法，即可轻松切换。

gtapp-ios-oc
======================

1.	gt-iOS-sdk 极验验证iOS版本的SDK，生成一个基于i386、x86_64、armv7、 armv7s、arm64的Static Library，支持iOS7.0＋。开发使用的Xcode版本位Xcode 6.3.1。
#.	gt-iOS-sdk-demo 调用sdk的演示app程序。
#.	直接运行gt-iOS-sdk下的GTFramework项目，选择GTAggregate为Target，在GTFramework/Products目录下生成模拟器、真机可用的GTFramework.framework静态库。
#.	在gt-iOS-sdk-demo下TestGT项目倒入生成的GTFramework.framework静态库，即可运行TestGT项目。
#.	演示项目提供了完整的一次验证，并将客户端验证结果向示例的客户服务器上发起二次验证的完整通讯过程。
#.	二次验证使用MKNetworkKit用于演示，可根据网站主项目需要自行修改。
#.  如果使用failback版本的请

使用以上步骤，用户可以运行Demo示例
================================================

自建项目引用
假设用户自建项目名称为：TestGT

1.	在极验官方主页www.geetest.com注册账号并申请相应的应用公钥，id:{{id}}
#.	将gt-iOS-sdk下的GTFramework项目生成的静态库GTFramework.framework引入到项目中
#.	将GTFramework.framework项目以Static Library的方式进行引用。将所需的GTFramework.framework拷贝到工程所在文件夹下。在 TARGETS->Build Phases-> Link Binary With Libaries中点击“+”按钮，在弹出的窗口中点击“Add Other”按钮，选择GTFramework.framework文件添加到工程中。
     
#.	在项目三处TODO中替换成用户自已的处理代码。
	
回调Block及返回值
===========================

.. code ::
	
    Block：
	   ^(NSString *code, NSDictionary *result, NSString *message) {} 
	
返回值：

1.code
    成功或者失败的值（1：成功/其他：失败）
2.message
    成功或者失败的信息（success/fail）
3.result
    详细的返回信息，用于向客户服务器提交之后的SDK二次验证信息
	
.. code ::

    {
     "geetest_challenge": "5a8c21e206f5f7ba4fa630acf269d0ec4z",
     "geetest_validate": "f0f541006215ac784859e29ec23d5b97",
     "geetest_seccode": "f0f541006215ac784859e29ec23d5b97|jordan"
     }
