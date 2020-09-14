import subprocess
import datetime


def mysql_increment(user, password, backup_dir):
    today = datetime.date.today()
    yesterday = today - datetime.timedelta(days=1)
    os.system('innobackupex --user=%s --password="%s" --no-timestamp --incremental %s --incremental-basedir %s' % (user, password, backup_dir + str(today), backup_dir + str(yesterday)))


if __name__ == "__main__":
    mysql_increment(
        user='xxx',
        password='xxx',
        backup_dir='/data/backup/'
    )