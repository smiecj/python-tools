source /etc/profile
export AIRFLOW_HOME=~/.airflow
airflow_version=2.1.2
python3_version="$(python3 --version | cut -d " " -f 2 | cut -d "." -f 1-2)"
requirement_url="https://raw.githubusercontent.com/apache/airflow/constraints-$airflow_version/constraints-$python3_version.txt"

airflow_webserver_port=8072

airflow_default_user_name=airflow
airflow_default_user_password=airflow123
airflow_default_user_firstname=Peter
airflow_default_user_lastname=Parker
airflow_default_user_email=spiderman@superhero.org

airflow_admin_role=Admin
airflow_admin_username=admin
airflow_admin_password=admin123

airflow_log_home=/var/log/airflow
airflow_log_webserver=$airflow_log_home/webserver.log
airflow_log_scheduler=$airflow_log_home/scheduler.log