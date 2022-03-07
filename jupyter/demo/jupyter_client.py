
# 启动新的 Kernel ，执行 Python 代码并获取返回结果
## https://github.com/jupyter/jupyter_client/issues/358
def execute_and_get_result():
    import queue
    from jupyter_client.manager import run_kernel

    with run_kernel() as kc:
        msg_id = kc.execute("print('test print')")
        reply = kc.get_shell_msg(5)
        print(reply['content'])
        print()
        kc.shutdown()

        while True:
            try:
                io_msg = kc.get_iopub_msg(timeout=5)
                print(io_msg['content'])
            except queue.Empty:
                print('timeout kc.get_iopub_msg')
                break