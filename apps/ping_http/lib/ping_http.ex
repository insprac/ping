defmodule Ping.HTTP do
  @type url :: String.t
  @type method :: :get | :post | :put | :delete | :option
  @type response :: tuple

  @spec ping(url) :: :ok | :error
  def ping(url) do
    case get(url) do
      {:ok, {{_protocol, 200, _status}, _headers, _body}} ->
        :ok
      response ->
        :error
    end
  end

  @spec get(url) :: response
  def get(url), do: request(:get, url)

  @spec request(method, url) :: response
  def request(method, url) do
    :httpc.request(method, {parse_url(url), []}, [], [])
  end

  @spec parse_url(any) :: url
  def parse_url(url) when is_list(url), do: url
  def parse_url(url), do: to_charlist(url)
end
