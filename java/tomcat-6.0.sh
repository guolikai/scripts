#!/bin/sh
##################################################
#Name:        tomcat-6.0.sh
#Version:     v5.3.2
#Create_Date: 2017-4-25
#Author:      GuoLikai(glk73748196@sina.com)
#Description: "安装管理Tomcat 6.0.45"
##################################################

App=apache-tomcat-6.0.45
AppName=tomcat
AppOptBase=/App/opt/OPS
AppOptDir=$AppOptBase/$AppName
AppInstallBase=/App/install/OPS
AppInstallDir=$AppInstallBase/$App
AppConfBase=/App/conf/OPS
AppConfDir=$AppConfBase/$AppName
AppLogBase=/App/log/OPS
AppLogDir=$AppLogBase/$AppName
AppDataDir=/App/data/$AppName
AppSrcBase=/App/src/OPS
AppTarBall=$App.tar.gz
AppBuildBase=/App/build/OPS
AppBuildDir=$(echo "$AppBuildBase/$AppTarBall" | sed -e 's/.tar.*$//' -e 's/^.\///')
AppStartup=$AppOptDir/bin/startup.sh

source /etc/profile

# 获取PID
fpid()
{
    AppPid=$(ps ax | grep "$AppName/" | grep -v "grep" | awk '{print $1}' 2> /dev/null)
}

# 查询状态
fstatus()
{
    fpid

    if [ ! -f "$AppStartup" ]; then
            echo "$AppName 未安装"
    else
        echo "$AppName 已安装"
        if [ -z "$AppPid" ]; then
            echo "$AppName 未启动"
        else
            echo "$AppName 正在运行"
        fi
    fi
}

# 删除
fremove()
{
    fpid

    if [ -z "$AppPid" ]; then
        if [ -d "$AppInstallDir" ]; then
            rm -rf $AppInstallDir
            if [ $? -eq 0 ]; then
                echo "删除 $AppName"
            fi
        else
            echo "$AppName 未安装"
        fi
    else
        echo "$AppName 正在运行" && exit 1
    fi
}

# 备份
fbackup()
{
    Day=$(date +%Y-%m-%d)
    BackupFile=$App.$Day.tgz

    if [ -d "$AppInstallDir" ]; then
        cd $AppInstallBase
        tar zcvf $BackupFile --exclude=logs/* --exclude=work/* --exclude=temp/* --exclude=webapps/* $App
        [ $? -eq 0 ] && echo "$AppName 备份成功" || echo "$AppName 备份失败"
    else
        echo "$AppName 未安装"
    fi
}

# 安装
finstall()
{
    test -d "$AppInstallDir" && echo "$AppName 已安装" && exit 1
    fupdate && fsymlink && fcpconf
}

#创建软连接
fsymlink()
{
	[ -L $AppOptDir ] && rm -f $AppOptDir
    [ -L $AppConfDir ] && rm -f $AppConfDir
    [ -L $AppLogDir ] && rm -f $AppLogDir
    ln -s $AppInstallDir       $AppOptDir
    ln -s $AppInstallDir/conf  $AppConfDir
	ln -s $AppInstallDir/logs  $AppLogDir
}

# 拷贝配置
fcpconf()
{
    cp -vf --backup=numbered $ScriptDir/server.xml $AppConfDir
}

# 更新
fupdate()
{
    fbackup
    test -f "$AppStartup" && echo "$AppName 已安装"
    cd $AppSrcBase
    test -d "$AppSrcDir" && rm -rf $AppSrcDir

    tar zxf $AppSrcBase/$AppTarBall -C $AppBuildBase || tar jxf $AppSrcBase/$AppTarBall  -C $AppBuildBase
    mv $AppBuildDir $AppInstallDir

    if [ $? -eq 0 ]; then
        echo "$AppName 安装成功"
        rm -rf $AppInstallDir/webapps/*
    else
        echo "$AppName 安装失败"
        exit
    fi
}


# 启动
fstart()
{
    fpid

    if [ -n "$AppPid" ]; then
        echo "$AppName 正在运行"
    else
        rm -rf $AppInstallDir/work/* $AppInstallDir/temp/*
        $AppStartup
        if [ $? -eq 0 ]; then
            echo "启动 $AppName"
        else
            echo "$AppName 启动失败"
        fi
    fi
}

# 重启
frestart()
{
    fpid
    test -n "$AppPid" && fstop && sleep 1
    fstart
}

# 停止
fstop()
{
    fpid

    if [ -n "$AppPid" ]; then
        echo "$AppPid" | xargs kill -9
        if [ $? -eq 0 ]; then
            echo "终止 $AppName 进程"
        else
            echo "终止 $AppName 进程失败"
            exit
        fi
    else
        echo "$AppName 进程未运行"
    fi
}

# 切割日志
fcutlog()
{
    fpid

    Time=$(date +'%Y-%m-%d %H:%M:%S')
    Day=$(date -d '-1 days' +'%Y-%m-%d')
	SaveDays=30

    echo "$Time"
	find $AppLogDir -type f -mtime +$SaveDays -exec rm -f {} \;
    mv -vf --backup=numbered $AppLogBase/tomcat/catalina.out $AppLogBase/tomcat/catalina.$Day.out && echo "切割 $AppName 日志"
    frestart
}

ScriptDir=$(cd $(dirname $0); pwd)
ScriptFile=$(basename $0)
case "$1" in
    "install"   ) finstall;;
    "update"    ) fupdate;;
    "reinstall" ) fremove && finstall;;
    "remove"    ) fremove;;
    "backup"    ) fbackup;;
    "start"     ) fstart;;
    "stop"      ) fstop;;
    "restart"   ) frestart;;
    "status"    ) fstatus;;
    "cpconf"    ) fcpconf;;
    "cutlog"    ) fcutlog;;
    *           )
    echo "$ScriptFile install              安装 $AppName"
    echo "$ScriptFile update               更新 $AppName"
    echo "$ScriptFile reinstall            重装 $AppName"
    echo "$ScriptFile remove               删除 $AppName"
    echo "$ScriptFile backup               备份 $AppName"
    echo "$ScriptFile start                启动 $AppName"
    echo "$ScriptFile stop                 停止 $AppName"
    echo "$ScriptFile restart              重启 $AppName"
    echo "$ScriptFile status               查询 $AppName 状态"
    echo "$ScriptFile cpconf               拷贝 $AppName 配置"
    echo "$ScriptFile cutlog               切割 $AppName 日志"
    ;;
esac
