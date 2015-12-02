====================================
iOS-Dev
====================================

.. contents:: 目录
.. sectnum::


概述
===================

1.	 gt-iOS-sdk 极验验证iOS版本的SDK，生成一个基于i386、x86_64、armv7、 armv7s、arm64的Static Library，支持iOS7.0＋。开发使用的Xcode版本位Xcode 6.3.1。
#.	 gt-iOS-sdk-demo 调用sdk的演示app程序。
#.	直接运行gt-iOS-sdk下的GTFramework项目，选择GTAggregate为Target，在GTFramework/Products目录下生成模拟器、真机可用的GTFramework.framework静态库。
#.	在gt-iOS-sdk-demo下TestGT项目倒入生成的GTFramework.framework静态库，即可运行TestGT项目。
#.	演示项目提供了用户服务器的预处理以及完整的一次验证，并将客户端验证结果向示例的客户服务器上发起二次验证的完整通讯过程。
#.	二次验证使用MKNetworkKit，可根据项目需要自行修改。
#.  最新的端sdk搭配最新的服务器sdk后，会自动获取用户服务器发送的验证ID。
#.  iOS端sdk必须与服务器部署代码配套使用，否者无法完成二次验证。`服务器部署代码请移步官网安装文档   <http://www.geetest.com>`__


搭建Demo
=================================================

自建项目引用
假设用户自建项目名称为：TestGT

1.	在极验官方主页www.geetest.com注册账号并申请相应的应用公钥，id:{{id}}
#.	将gt-iOS-sdk下的GTFramework项目生成的静态库GTFramework.framework引入到项目中
#.	将GTFramework.framework项目以Static Library的方式进行引用。
        将所需的GTFramework.framework拷贝到工程所在文件夹下。在 TARGETS->Build Phases-> Link Binary With Libaries中点击“+”按钮，在弹出的窗口中点击“Add Other”按钮，选择GTFramework.framework文件添加到工程中。
#.	在项目中有4处标注'TODO'的位置，请网站主根据提示写入用户自已的处理代码。
#.	在项目中有4处标注'TODO'的位置，请网站主根据提示写入用户自已的处理代码。
#.	在项目中有4处标注'TODO'的位置，请网站主根据提示写入用户自已的处理代码。


通讯流程图
============
具体见官网安装文档 `官网   <http://www.geetest.com>`__




采集设备静态信息
========================

mobileInfo里面的具体字段描述表
-------------------------------------------------------------------

.. image:: img/mobile-info.png

_mobileInfo   手机静态信息举例 Code Sample
-----------------------------------------------------

.. code::

    _mobileInfo = [@{@"mType" : [GTData osType],
                         @"mScreen" : [GTData screen],
                         @"osType" : @"ios",
                         @"osVerRelease" : [GTData systemVersion],
                         @"osVerInt" : [GTData systemVersion],
                         @"hAppVerCode" : [GTData buildVersion],
                         @"hAppVerName" : [GTData buildVersionRelease],
                         @"gsdkVerCode" : @"2.15.8.7.1",
                         @"imei" : @"000000000000000" } mutableCopy];

	
回调Block及返回值
==============================

.. code::
	
    Block：
	   ^(NSString *code, NSDictionary *result, NSString *message) {} 
	
返回值：

1.code
    成功或者失败的值（1：成功/其他：失败）（success/fail）
2.message
    成功或者失败的信息（some description）
3.result
    详细的返回信息，用于向客户服务器提交之后的SDK二次验证信息
	
.. code::

    {
     "geetest_challenge": "5a8c21e206f5f7ba4fa630acf269d0ec4z",
     "geetest_validate": "f0f541006215ac784859e29ec23d5b97",
     "geetest_seccode": "f0f541006215ac784859e29ec23d5b97|jordan"
     }


gt验证SDK Header暴露的方法
=============================
客户端向网站主服务器发起验证请求
-------------------------------

获取并且解析用于验证的关键数据,并且自动配置验证

 @param askCustomServerForGTestURL 客户端向用户服务端发起验证请求的链接(api_1)
 @return 只有当网站主服务器可用时，返回customRetDict，否则返回nil

.. code::
	{
     "challenge": "12ae1159ffdfcbbc306897e8d9bf6d06" ,
     "gt"       : "ad872a4e1a51888967bdb7cb45589605" ,
     "success"  : 1 
    }

.. code::
    
    - (NSDictionary *)requestCustomServerForGTest:(NSURL *)requestCustomServerForGTestURL;


使用id和challenge配置验证
--------------------------

此方法提供给不使用或不便于使用默认failback功能而自己搭建failback机制的用户

@param captcha_id   在官网申请的captcha_id
@param gt_challenge 从geetest服务器获取的challenge
@return YES可开启验证，NO则客户端与geetest服务端之间连接不通畅
.. code::

	- (BOOL)requestGTest:(NSString *)captcha_id withChallenge:(NSString *)gt_challenge;
 

测试服务是否可用(仅限debugMode)
------------------------------

@param captcha_id 分配的captcha_id
@return YES则服务可用；NO则不可用
..code::
    
    - (BOOL)serverStatusWithCaptcha_id:(NSString *)captcha_id;

验证完成回调block
------------------

.. code::

    typedef void(^GTCallFinishBlock)(NSString *code, NSDictionary *result, NSString *message);

验证关闭block
----------------

.. code::

    typedef void(^GTCallCloseBlock)(void);


<!>展示验证<!>
---------------

验证最核心的方法，在此之前必须先配置好验证

实现方式 直接在 keyWindow 上添加遮罩视图、极验验证的UIWebView视图
极速验证UIWebView通过JS与SDK通信

@param finish 验证返回结果
@param close  关闭验证

.. code::
    
    - (void)openGTViewAddFinishHandler:(GTCallFinishBlock)finish closeHandler:(GTCallCloseBlock)close;

提前关闭gt验证
----------------

关闭正在显示的验证界面

.. code::
    
    - (void)closeGTViewIfIsOpen;


开启debugMode
------------------

在此开启debugMode用于debug

.. code::

	- (void)debugModeEnable:(BOOL)debugEnalbe;

参考资料
=========

OC与JS通信参考(< iOS 7 && > iOS 7的不同实现)
------------------------------------------------------------------------------

UIWebView 中JavaScript 与 Objective-C 通信 `参考页面   <http://www.bkjia.com/Androidjc/935794.html>`__


