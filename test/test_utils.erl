-module(test_utils).

-export([unique_email/0,
         api_request/3,
         api_request/4,
         api_request/5,
         create_user/0,
         delete_user/1]).

unique_email() ->
    erlang:list_to_binary("test_user" ++ ktn_random:string(5) ++ "@example.com").

api_request(Method, AccessToken, Path) ->
    api_request(Method, AccessToken, Path, <<"">>, []).

api_request(Method, AccessToken, Path, Data) ->
    api_request(Method, AccessToken, Path, Data, []).

api_request(Method, public, Path, Data, Options) ->
    api_request_internal(Method, [], Path, Data, Options);
api_request(Method, AccessToken, Path, Data, Options) ->
    Headers = [{<<"Authorization">>, <<"Bearer ", AccessToken/binary>>}],
    api_request_internal(Method, Headers, Path, Data, Options).

api_request_internal(Method, Headers, Path, Data, Options) ->
    %% TODO make url configurable
    Port = erlang:integer_to_list(hp_config:get(port)),
    Url = "http://localhost:" ++ Port ++ Path,
    Body = hp_json:encode(Data),
    AllHeaders = [{<<"Content-Type">>, <<"application/json">>} | Headers],
    case hackney:request(Method, Url, AllHeaders, Body, [with_body | Options]) of
        {ok, _, _, <<"">>} = Res -> Res;
        {ok, Status, ResHeaders, ResBody} -> {ok, Status, ResHeaders, hp_json:decode(ResBody)}
    end.

create_user() ->
    Email = unique_email(),
    Password = <<"S3cr3t!!">>,
    Body = #{
      email => Email,
      name => <<"John Doe">>,
      password => Password,
      country => <<"argentina">>
     },
    {ok, 201, _, _} = api_request(post, public, "/api/users", Body),
    Body.

delete_user(Email) ->
    %% FIXME delete user via API, not db
    db_user:delete(Email).