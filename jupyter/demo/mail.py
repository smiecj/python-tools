# -*- coding: UTF-8 -*-
## send mail demo

from email.header import Header
from email.mime.text import MIMEText
from email.utils import parseaddr, formataddr
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase

def send_mail(receiver,subject,context):
    global msg
    sender = 'sender_mail'
    psd = 'sender_smtp_pwd'
    mail_host = 'smtp.exmail.qq.com'
    to_addrs = receiver.split(',')
    # create mail
    msg = MIMEMultipart()
    msg['Subject'] = Header(subject, 'utf-8')
    msg['from'] = Header(sender, 'utf-8')
    msg['To'] = ",".join(to_addrs)
    # msg['Cc'] = ",".join(cc_addrs)
    msg.attach(MIMEText(context, 'plain', 'utf-8'))
    ## create mail with attachment
    # att1 = MIMEText(open(file_path, 'rb').read(), 'base64', 'utf-8')
    # att1.add_header('Content-Disposition', 'attachment', filename=filename)
    # att1.add_header('Content-ID', '<0>')
    # att1.add_header('X-Attachment-Id', '0')
    # msg.attach(att1)
    try:
        smtp = smtplib.SMTP_SSL(mail_host,465)
        smtp.login(sender, psd)
        smtp.sendmail(sender, to_addrs, msg.as_string())
        smtp.quit()
        print('send success')
    except Exception as result:
        print('send fail, please check: {}'.format(result))

send_mail('receiver_mail', 'mail_title', 'mail_content')