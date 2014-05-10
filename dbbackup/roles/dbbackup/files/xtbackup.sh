DB=$1
IID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
INAME=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$IID" --output text --region=us-east-1 |awk '{print $NF}')
TBLST=/tmp/tables2backup
destination=${destination:='/mnt/data'}
full_backup_dir=$destination/full
[ -d $full_backup_dir ] || mkdir -p $full_backup_dir
processor_count=$(cat /proc/cpuinfo | grep processor | wc -l)
log="/tmp/$(/usr/bin/basename $0).$$.tmp"
S3B=mybackups

mysql -Ns -e 'show tables' $DB > $TBLST
sed -i "s/^/${DB}./" $TBLST
for i in $(cat /root/bin/tables2exclude); do sed -i "/$i/d" $TBLST; done

ionice -c 2 -n 7 \
       nice -n 15 \
       innobackupex \
       --rsync \
       --parallel=$processor_count \
       --tables-file=$TBLST \
       $full_backup_dir > $log 2>&1

cd $full_backup_dir
for i in $(ls $full_backup_dir); do
    tar --create --file ${INAME}_${i}.tar --directory $full_backup_dir --remove-files ${i} && pbzip2 ${INAME}_${i}.tar
    aws s3 cp ${INAME}_${i}.tar.bz2 s3://${S3B}/${DB}/ && rm -f ${INAME}_${i}.tar.bz2
done

OLD=$(aws s3 ls s3://${S3B}/${DB}/ |grep ${INAME}_$(date +%F -d  '3 day ago') |awk '{print $NF}')
aws s3 rm s3://${S3B}/${DB}/$OLD

exit 0
