defmodule App.Auth.FacebookTest do
  alias App.Auth
  import Mock

  describe "App.Auth.Facebook" do
    test "get_access_token" do
      with_mock Facebook, [accessToken: fn(_, _, _, _) -> App.FacebookMock.get_access_token(:success) end] do
        assert {:ok, opts} = Auth.Facebook.get_access_token_by_code(%{"code" => "123456"})
        assert %{"access_token" => _} = opts
      end
    end

    test "get_access_token fail" do
      with_mock Facebook, [accessToken: fn(_, _, _, _) -> App.FacebookMock.get_access_token(:failure) end] do
        assert {:error, opts} = Auth.Facebook.get_access_token_by_code(%{"code" => "123456"})
        assert {:unauthorized, %{code: _}} = opts
      end
    end

    test "get_email" do
      with_mock Facebook, [me: fn(_, _) -> App.FacebookMock.get_email(:success) end] do
        assert {:ok, opts} = Auth.Facebook.get_email_by_access_token({:ok, %{"access_token" => "ACCESS_TOKEN"}})
        assert %{"email" => "MOCK_USER@EMAIL.COM"} = opts
      end
    end

    test "get_email fail" do
      with_mock Facebook, [me: fn(_, _) -> App.FacebookMock.get_email(:failure) end] do
        assert {:error, opts} = Auth.Facebook.get_email_by_access_token({:ok, %{"access_token" => "ACCESS_TOKEN"}})
        assert {:unauthorized, %{access_token: _}} = opts
      end
    end

    test "get_email passes along error" do
      error = {:error, "error message"}
      assert  error == Auth.Facebook.get_email_by_access_token(error)
    end
  end
end
