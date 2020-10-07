-module(hp_email).

-export([send/4,
         send_html/4,
         send_email_verification/2,
         send_password_reset/2]).

send(ToEmails, FromEmail, Subject, Body) when not is_list(ToEmails)->
  send([ToEmails], FromEmail, Subject, Body);
send(ToEmails, FromEmail, Subject, Body) ->
  lager:debug(<<"Sending emails: ~p ~p">>, [Subject, ToEmails]),
  FullBody = add_footer(Body),

  case hp_config:get(email_enabled) of
    true ->
      MailSender = email_sender(hp_config:get(email_provider)),
      lists:foreach(fun(Email) ->
                        MailSender:send_email(Email, FullBody, Subject, FromEmail, [])
                    end, ToEmails);
    _ ->
      ok
  end.

send_html(ToEmails, FromEmail, Subject, Body) ->
  send(ToEmails, FromEmail, Subject, [{html, Body}]).

send_email_verification(Email, Code) ->
  From = <<"HolidayPinger <reminder@holidaypinger.com>">>,
  Subject = <<"HolidayPinger email confirmation">>,
  Link = <<"https://holidaypinger.com/register/confirm/code?code=", Code/binary,
           "&email=", Email/binary>>,
  Body = <<"<p>Hey there!</p>"
           "<p>Thanks for choosing HolidayPinger, "
           "Please click on <a href=\"", Link/binary, "\">this link</a>"
           " to finish the registration process.</p>"
           "<p>The HolidayPinger team</p">>,

  send_html(Email, From, Subject, Body).

send_password_reset(Email, Code) ->
  From = <<"HolidayPinger <reminder@holidaypinger.com>">>,
  Subject = <<"HolidayPinger password reset">>,
  Link = <<"https://holidaypinger.com/password/code?code=", Code/binary,
           "&email=", Email/binary>>,
  Body = <<"<p>Hey there!</p>"
           "Please click on <a href=\"", Link/binary, "\">this link</a>"
           " to reset your password.</p>"
           "<p>The HolidayPinger team</p">>,

  send_html(Email, From, Subject, Body).

%%% internal

add_footer([{html, Body}]) ->
  HolidayLink = <<"<a href=\"https://holidaypinger.com\">HolidayPinger</a>">>,
  AbuseLink = <<"<a href=\"mailto:reminder@holidaypinger.com\">Report abuse</a>">>,
  [{html, <<Body/binary,
            "<p><br/><small>Mail sent by ", HolidayLink/binary,
            " | ", AbuseLink/binary, "</small></p>">>}];
add_footer(Body) ->
  add_footer([{html, <<"<p>", Body/binary, "</p>">>}]).

email_sender(mailgun) -> mailgun;
email_sender(aws) -> erlcloud_ses.
