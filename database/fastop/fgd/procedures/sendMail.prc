create or replace PROCEDURE sendMail(P_SENDER    IN VARCHAR2
                                   , P_RECIPIENT IN VARCHAR2
                                   , P_SUBJECT   IN VARCHAR2
                                   , P_MESSAGE   IN VARCHAR2)
IS
    mailhost VARCHAR2(30) := 'smtpmail.cec.eu.int';
    l_sender  VARCHAR2(200) := 'automated-notifications@nomail.ec.europa.eu';

    mail_conn UTL_SMTP.connection;
    crlf      VARCHAR2(2) := CHR(13) || CHR(10);
    msg       VARCHAR2(4000);
BEGIN
    mail_conn := UTL_SMTP.open_connection(mailhost, 25);
    msg       :=
                'Date: '
            || TO_CHAR(SYSDATE, 'dd Mon yy hh24:mi:ss')
            || crlf
            || 'From: '
            || l_sender
            || '>'
            || crlf
            || 'Subject: '
            || P_SUBJECT
            || crlf
            || 'To: '
            || P_RECIPIENT
            || crlf
            || crlf
            || P_MESSAGE;
    UTL_SMTP.helo(mail_conn, mailhost);
    UTL_SMTP.mail(mail_conn, l_sender);
    UTL_SMTP.rcpt(mail_conn, P_RECIPIENT);
    UTL_SMTP.data(mail_conn, msg);
    UTL_SMTP.quit(mail_conn);
    NULL;
END SendMail;