for i in `cat $1`
do

aws rds  --profile default modify-db-instance --db-instance-identifier $i  --ca-certificate-identifier rds-ca-2019 --apply-immediately
done

