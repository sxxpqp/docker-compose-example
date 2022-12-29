#!/bin/bash
#获取当前时间
date_now=$(date "+%Y%m%d_%H%M%S")
#定义备份目录
backUpFolder=/database/mysql/baotou
#创建目录
if [ ! -d "$backUpFolder"  ];then
  mkdir $backUpFolder
else
  echo "${backUpFolder} exist"
fi
#定义数据库用户名
username="root"
#定义数据库密码
password="Iot@123456"
#定义数据库连接地址
host="10.10.10.24"
port="3306"
#定义需要备份的数据库库名列表,库名用空格隔开
db_names=(turingcloudx turingcloudx_ac turingcloudx_config turingcloudx_daily turingcloudx_dataanalysis turingcloudx_device turingcloudx_job turingcloudx_video turingcloudx_visual)
#db_names=(turingcloudx turingcloudx_ac turingcloudx_config turingcloudx_video turingcloudx_visual turingcloudx_daily)
for db_name in ${db_names[*]}; do
  #定义备份文件名
  fileName="${db_name}_${date_now}.sql"
  #定义备份文件目录
  backUpFileName="${backUpFolder}/${fileName}"
  echo "starting backup mysql ${db_name} at ${date_now}."
  docker exec  turingcloud-mysql mysqldump -u${username} -p${password} -h${host} -P${port} --single-transaction --databases ${db_name} > ${backUpFileName}
  date_end=$(date "+%Y%m%d-%H%M%S")
  echo "finish backup mysql database ${db_name} at ${date_end} dir_path ${backUpFolder}"
  #进入到备份文件目录
  cd ${backUpFolder}
  #压缩备份文件
  tar zcvf ${fileName}.tar.gz ${fileName}
  rm -f ${fileName}
done

#删除30天以前的数据库文件
find /database/mysql/baotou/ -mtime +30 -name "*.*" -exec rm -rf {} \;
