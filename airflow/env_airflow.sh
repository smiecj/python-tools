source /etc/profile
export AIRFLOW_HOME=~/.airflow
airflow_version=2.1.2
python3_version="$(python3 --version | cut -d " " -f 2 | cut -d "." -f 1-2)"
requirement_url="https://raw.githubusercontent.com/apache/airflow/constraints-$airflow_version/constraints-$python3_version.txt"

airflow_webserver_port=8072

airflow_username=airflow
airflow_password=airflow123