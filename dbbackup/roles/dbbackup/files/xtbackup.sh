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
BKNAME=$(basename $(awk "/Backup created in directory/{split(\$0, p, \"'\"); print p[2]}" $log))
tar --create --file ${INAME}_${BKNAME}.tar --directory $full_backup_dir --remove-files ${BKNAME} && pbzip2 ${INAME}_${BKNAME}.tar
aws s3 cp ${INAME}_${BKNAME}.tar.bz2 s3://${S3B}/adwords/ && rm -f ${INAME}_${BKNAME}.tar.bz2

OLD=$(aws s3 ls s3://${S3B}/${DB}/ |grep ${INAME}_$(date +%F -d  '3 day ago') |awk '{print $NF}')
[ -z "$OLD" ] || aws s3 rm s3://${S3B}/${DB}/$OLD

exit 0
