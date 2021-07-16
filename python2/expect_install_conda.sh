#!/usr/bin/expect 
## test method: ./expect_install_conda.sh Miniconda2-latest-Linux-x86_64.sh /usr/local/miniconda2
set conda_install_script_name [lindex $argv 0];
set conda_install_path [lindex $argv 1];
puts "Starting install conda ..." 
spawn sh $conda_install_script_name
puts "Begins exec!"
expect -re {
"^((?!.*>>>).)*" { send "\r"; exp_continue}
".*>>>.*" { send "\r" } # 当前怀疑: 这个没有执行
}
puts "enter finish!"
# 这些执行了
send "\n"
send "\n"
send "\n"
send "\n"
send "\n"
send "\n"
send "\n"
send "\n"
send "\n"
send "\n"
send "\n"
send "\n"
send "\n"
send "\n"
send "\n"
expect -re {
"^((?!Please answer).)*" { send "\r"; exp_continue}
"^Please answer.*" { send "$yes\r" }
}
puts "Answer finish!"
expect -re {
"^((?!.*>>>).)*" { send "\n"; exp_continue}
".*>>>.*" { send "$conda_install_path\n" }
}
expect -re {
"^((?!.*>>>).)*" { send "\n"; exp_continue}
".*>>>.*" { send "yes\n" }
}
puts "Done!"